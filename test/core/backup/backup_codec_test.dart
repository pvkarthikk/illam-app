import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/backup/backup_codec.dart';
import 'package:nm_flat/core/backup/file_format.dart';

void main() {
  const fast = KdfParams(memKiB: 16384, t: 1, p: 1);
  final vaultId = List.filled(32, 'a').join();

  test('round trip encode and decode returns matching json and header', () async {
    final plain = Uint8List.fromList(utf8.encode('{"homeName":"Iyer Home"}'));
    final file = await BackupCodec.encode(
      snapshotJson: plain,
      password: 'correct horse',
      vaultId: vaultId,
      kind: 'full',
      kdf: fast,
      createdAt: 1763600000000,
    );

    expect(file.sublist(0, 5), [0x4E, 0x4D, 0x42, 0x4B, 1]);

    // Ensure plaintext does not leak into encrypted bytes.
    final needle = utf8.encode('Iyer');
    var foundPlain = false;
    for (var i = 0; i <= file.length - needle.length; i++) {
      var eq = true;
      for (var j = 0; j < needle.length; j++) {
        if (file[i + j] != needle[j]) {
          eq = false;
          break;
        }
      }
      if (eq) {
        foundPlain = true;
        break;
      }
    }
    expect(foundPlain, isFalse);

    final res = await BackupCodec.decode(file, 'correct horse');
    expect(res.json, plain);
    expect(res.header.kind, 'full');
    expect(res.header.vaultId, vaultId);
    expect(res.header.createdAt, 1763600000000);
  });

  test('wrong password throws BackupError.wrongPassword', () async {
    final file = await BackupCodec.encode(
      snapshotJson: Uint8List.fromList(utf8.encode('{}')),
      password: 'secret',
      vaultId: vaultId,
      kind: 'data',
      kdf: fast,
      createdAt: 1763600000000,
    );

    await expectLater(
      () => BackupCodec.decode(file, 'wrong'),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.error,
          'error',
          BackupError.wrongPassword,
        ),
      ),
    );
  });

  test('flipping a body byte throws damaged', () async {
    final file = await BackupCodec.encode(
      snapshotJson: Uint8List.fromList(utf8.encode('{"ok":true}')),
      password: 'secret',
      vaultId: vaultId,
      kind: 'data',
      kdf: fast,
      createdAt: 1763600000000,
    );
    final tampered = Uint8List.fromList(file);
    tampered[tampered.length - 20] ^= 0x01;

    await expectLater(
      () => BackupCodec.decode(tampered, 'secret'),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.error,
          'error',
          BackupError.damaged,
        ),
      ),
    );
  });

  test('rejects low-memory header before Argon2id runs', () async {
    final header = BackupHeader(
      vaultId: vaultId,
      snapshotId: List.filled(32, 'b').join(),
      kind: 'full',
      createdAt: 1763600000000,
      bodySize: 100,
      kdf: const KdfParams(memKiB: 8192, t: 1, p: 1),
      salt: Uint8List(16),
      nonce: Uint8List(24),
    );
    final prefix = encodePrefix(header);
    final file = Uint8List.fromList([...prefix, ...List<int>.filled(100, 0)]);

    final sw = Stopwatch()..start();
    await expectLater(
      () => BackupCodec.decode(file, 'secret'),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.error,
          'error',
          BackupError.newerOrDamaged,
        ),
      ),
    );
    sw.stop();
    expect(sw.elapsed, lessThan(const Duration(seconds: 1)));
  });
}
