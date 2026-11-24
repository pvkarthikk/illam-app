import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';

import 'package:nm_flat/core/backup/file_format.dart';
import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/util/ids.dart';

/// Encrypts and decrypts `.nmbak` backup archives using gzip + Argon2id + XChaCha20-Poly1305.
abstract final class BackupCodec {
  static const KdfParams strong = KdfParams(memKiB: 65536, t: 3, p: 1);
  static const KdfParams light = KdfParams(memKiB: 16384, t: 3, p: 1);

  static Future<SecretKey> _key(
    String password,
    List<int> salt,
    KdfParams k,
  ) => DartArgon2id(
    parallelism: k.p,
    memory: k.memKiB,
    iterations: k.t,
    hashLength: 32,
  ).deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);

  static Future<String> _keyCheck(SecretKey key) async {
    final mac = await Hmac.sha256().calculateMac(
      utf8.encode('nmbak-key-check'),
      secretKey: key,
    );
    return base64Encode(mac.bytes);
  }

  /// Compresses and encrypts [snapshotJson] inside a background isolate.
  static Future<Uint8List> encode({
    required Uint8List snapshotJson,
    required String password,
    required String vaultId,
    required String kind,
    required KdfParams kdf,
    required int createdAt,
  }) => Isolate.run(() async {
    final rng = Random.secure();
    Uint8List rand(int n) =>
        Uint8List.fromList(List<int>.generate(n, (_) => rng.nextInt(256)));

    final salt = rand(16);
    final nonce = rand(24);
    final snapshotId = Ids.hex(rand(16));
    final body = Uint8List.fromList(const GZipEncoder().encode(snapshotJson));
    final key = await _key(password, salt, kdf);
    final keyCheck = await _keyCheck(key);
    final header = BackupHeader(
      vaultId: vaultId,
      snapshotId: snapshotId,
      kind: kind,
      createdAt: createdAt,
      bodySize: body.length + 16,
      kdf: kdf,
      salt: salt,
      nonce: nonce,
      keyCheck: keyCheck,
    );
    final prefix = encodePrefix(header);
    final box = await Xchacha20.poly1305Aead().encrypt(
      body,
      secretKey: key,
      nonce: nonce,
      aad: prefix,
    );
    return concatBytes([prefix, box.cipherText, box.mac.bytes]);
  });

  /// Verifies header limits, derives key, authenticates/decrypts, and gunzips [file].
  static Future<({BackupHeader header, Uint8List json})> decode(
    Uint8List file,
    String password,
  ) => Isolate.run(() async {
    final parsed = parseHeader(file, fileLength: file.length);
    final header = parsed.header;
    final body = file.sublist(parsed.bodyOffset);
    if (body.length < 16) {
      throw const BackupFormatException(BackupError.damaged);
    }
    final split = body.length - 16;
    final box = SecretBox(
      body.sublist(0, split),
      nonce: header.nonce,
      mac: Mac(body.sublist(split)),
    );
    final key = await _key(password, header.salt, header.kdf);
    if (header.keyCheck != null && header.keyCheck != await _keyCheck(key)) {
      throw const BackupFormatException(BackupError.wrongPassword);
    }
    final List<int> compressed;
    try {
      compressed = await Xchacha20.poly1305Aead().decrypt(
        box,
        secretKey: key,
        aad: parsed.aad,
      );
    } on SecretBoxAuthenticationError {
      throw BackupFormatException(
        header.keyCheck != null
            ? BackupError.damaged
            : BackupError.wrongPassword,
      );
    }

    final cap = min(1 << 30, 20 * header.bodySize);
    try {
      final json = const GZipDecoder().decodeBytes(
        compressed,
        verify: true,
        maxOutputSize: cap,
      );
      if (json.length >= cap) {
        throw const BackupFormatException(BackupError.damaged);
      }
      return (header: header, json: json);
    } on BackupFormatException {
      rethrow;
    } on Object {
      throw const BackupFormatException(BackupError.damaged);
    }
  });
}
