import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/kdf.dart';

/// Thrown when authenticated decryption fails or ciphertext is malformed.
class AeadError implements Exception {
  const AeadError();
}

/// Authenticated encryption primitives (ChaCha20-Poly1305 and XChaCha20-Poly1305).
abstract final class Aead {
  static final _chacha = Chacha20.poly1305Aead();
  static final _xchacha = Xchacha20.poly1305Aead();

  /// Seals [plain] under [key] and caller-supplied 12-byte [nonce].
  ///
  /// Returns `cipherText || 16-byte tag`.
  static Future<Uint8List> chachaSeal(
    List<int> key,
    List<int> nonce,
    List<int> plain, {
    List<int> aad = const [],
  }) async {
    final box = await _chacha.encrypt(
      plain,
      secretKey: SecretKey(key),
      nonce: nonce,
      aad: aad,
    );
    return concatBytes([box.cipherText, box.mac.bytes]);
  }

  /// Opens [sealed] (`cipherText || 16-byte tag`) under [key] and [nonce].
  static Future<Uint8List> chachaOpen(
    List<int> key,
    List<int> nonce,
    List<int> sealed, {
    List<int> aad = const [],
  }) async {
    if (sealed.length < 16) throw const AeadError();
    final split = sealed.length - 16;
    final box = SecretBox(
      sealed.sublist(0, split),
      nonce: nonce,
      mac: Mac(sealed.sublist(split)),
    );
    try {
      final plain = await _chacha.decrypt(
        box,
        secretKey: SecretKey(key),
        aad: aad,
      );
      return Uint8List.fromList(plain);
    } on SecretBoxAuthenticationError {
      throw const AeadError();
    }
  }

  /// Seals [plain] under [key] with a fresh 24-byte random nonce and XChaCha20-Poly1305.
  ///
  /// Returns `nonce || cipherText || 16-byte tag`.
  static Future<Uint8List> xSeal(
    List<int> key,
    List<int> plain, {
    List<int> aad = const [],
  }) async {
    final nonce = randomBytes(24);
    final box = await _xchacha.encrypt(
      plain,
      secretKey: SecretKey(key),
      nonce: nonce,
      aad: aad,
    );
    return concatBytes([nonce, box.cipherText, box.mac.bytes]);
  }

  /// Opens [sealed] (`24-byte nonce || cipherText || 16-byte tag`) under [key].
  static Future<Uint8List> xOpen(
    List<int> key,
    List<int> sealed, {
    List<int> aad = const [],
  }) async {
    if (sealed.length < 40) throw const AeadError();
    final split = sealed.length - 16;
    final box = SecretBox(
      sealed.sublist(24, split),
      nonce: sealed.sublist(0, 24),
      mac: Mac(sealed.sublist(split)),
    );
    try {
      final plain = await _xchacha.decrypt(
        box,
        secretKey: SecretKey(key),
        aad: aad,
      );
      return Uint8List.fromList(plain);
    } on SecretBoxAuthenticationError {
      throw const AeadError();
    }
  }
}

/// Anonymous public-key sealed box using X25519 + HKDF-SHA256 + XChaCha20-Poly1305.
abstract final class SealedBox {
  static final _x25519 = X25519();
  static final _info = utf8.encode('illam/seal/v1');

  /// Encrypts [plain] to an X25519 public key [recipientPub].
  static Future<Uint8List> seal(List<int> recipientPub, List<int> plain) async {
    final eph = await _x25519.newKeyPair();
    final ephPub = (await eph.extractPublicKey()).bytes;
    final shared = await _x25519.sharedSecretKey(
      keyPair: eph,
      remotePublicKey: SimplePublicKey(recipientPub, type: KeyPairType.x25519),
    );
    final key = await hkdfSha256(
      ikm: await shared.extractBytes(),
      salt: concatBytes([ephPub, recipientPub]),
      info: _info,
    );
    final enc = await Aead.xSeal(key, plain);
    return concatBytes([ephPub, enc]);
  }

  /// Decrypts [sealed] using the recipient's X25519 key pair [me].
  static Future<Uint8List> open(SimpleKeyPair me, List<int> sealed) async {
    if (sealed.length < 32) throw const AeadError();
    final ephPub = sealed.sublist(0, 32);
    final myPub = (await me.extractPublicKey()).bytes;
    final shared = await _x25519.sharedSecretKey(
      keyPair: me,
      remotePublicKey: SimplePublicKey(ephPub, type: KeyPairType.x25519),
    );
    final key = await hkdfSha256(
      ikm: await shared.extractBytes(),
      salt: concatBytes([ephPub, myPub]),
      info: _info,
    );
    return Aead.xOpen(key, sealed.sublist(32));
  }
}
