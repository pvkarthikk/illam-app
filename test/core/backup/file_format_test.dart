import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/backup/file_format.dart';

BackupHeader _validHeader({int bodySize = 100}) => BackupHeader(
  vaultId: List.filled(32, 'a').join(),
  snapshotId: List.filled(32, 'b').join(),
  kind: 'full',
  createdAt: 1763600000000,
  bodySize: bodySize,
  kdf: const KdfParams(memKiB: 16384, t: 1, p: 1),
  salt: Uint8List.fromList(List<int>.generate(16, (i) => i)),
  nonce: Uint8List.fromList(List<int>.generate(24, (i) => i + 20)),
);

Uint8List _prefixWithRawJson(Map<String, Object?> jsonMap, {int? overrideLen}) {
  final jb = utf8.encode(jsonEncode(jsonMap));
  final len = ByteData(4)..setUint32(0, overrideLen ?? jb.length);
  return (BytesBuilder(copy: false)
        ..add(const [0x4E, 0x4D, 0x42, 0x4B, 1])
        ..add(len.buffer.asUint8List())
        ..add(jb))
      .toBytes();
}

void main() {
  test('round trip encodePrefix and parseHeader', () {
    final h = _validHeader();
    final prefix = encodePrefix(h);
    expect(prefix.sublist(0, 5), [0x4E, 0x4D, 0x42, 0x4B, 1]);

    final parsed = parseHeader(prefix, fileLength: prefix.length + 100);
    expect(parsed.bodyOffset, prefix.length);
    expect(parsed.aad, prefix);
    expect(parsed.header.vaultId, h.vaultId);
    expect(parsed.header.snapshotId, h.snapshotId);
    expect(parsed.header.kind, 'full');
    expect(parsed.header.createdAt, h.createdAt);
    expect(parsed.header.bodySize, 100);
    expect(parsed.header.kdf.memKiB, 16384);
    expect(parsed.header.kdf.t, 1);
    expect(parsed.header.kdf.p, 1);
    expect(parsed.header.salt, h.salt);
    expect(parsed.header.nonce, h.nonce);
  });

  test('untrusted header limits throw expected BackupError', () {
    final h = _validHeader();
    final prefix = encodePrefix(h);

    final badMagic = Uint8List.fromList(prefix)..setRange(0, 4, utf8.encode('ABCD'));
    expect(
      () => parseHeader(badMagic),
      throwsA(isA<BackupFormatException>().having((e) => e.error, 'error', BackupError.notABackup)),
    );

    final badVer = Uint8List.fromList(prefix)..[4] = 2;
    expect(
      () => parseHeader(badVer),
      throwsA(isA<BackupFormatException>().having((e) => e.error, 'error', BackupError.newerOrDamaged)),
    );

    final badCases = <Uint8List>[
      for (final m in [8192, 262145])
        _prefixWithRawJson({...h.toJson(), 'kdf': {'alg': 'argon2id', 'm': m, 't': 1, 'p': 1}}),
      for (final t in [0, 11])
        _prefixWithRawJson({...h.toJson(), 'kdf': {'alg': 'argon2id', 'm': 16384, 't': t, 'p': 1}}),
      _prefixWithRawJson({...h.toJson(), 'kdf': {'alg': 'argon2id', 'm': 16384, 't': 1, 'p': 5}}),
      _prefixWithRawJson({...h.toJson(), 'kdf': {'alg': 'scrypt', 'm': 16384, 't': 1, 'p': 1}}),
      _prefixWithRawJson({...h.toJson(), 'salt': base64Encode(List.filled(15, 1))}),
      _prefixWithRawJson({...h.toJson(), 'nonce': base64Encode(List.filled(23, 2))}),
      _prefixWithRawJson({...h.toJson(), 'bodySize': 200 * 1024 * 1024 + 1}),
      _prefixWithRawJson(h.toJson(), overrideLen: 5000),
    ];

    for (final c in badCases) {
      expect(
        () => parseHeader(c),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.error,
            'error',
            BackupError.newerOrDamaged,
          ),
        ),
      );
    }

    expect(
      () => parseHeader(prefix, fileLength: prefix.length + 99),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.error,
          'error',
          BackupError.damaged,
        ),
      ),
    );
    expect(parseHeader(prefix, fileLength: prefix.length + 100).header.bodySize, 100);
  });

  test('backupFileName, backupNameRe, and formatBackupSize', () {
    final ts = DateTime.utc(2026, 11, 20, 5, 3, 9).millisecondsSinceEpoch;
    final name = backupFileName(
      vaultId: 'a1b2c3d4${List.filled(24, '0').join()}',
      snapshotId: 'ffee0011${List.filled(24, '0').join()}',
      createdAtMs: ts,
    );
    expect(name, 'Illam_a1b2c3d4_20261120-050309Z_ffee0011.nmbak');

    final match = backupNameRe.firstMatch(name);
    expect(match, isNotNull);
    expect(match!.group(1), 'a1b2c3d4');
    expect(match.group(2), '20261120-050309');
    expect(match.group(3), 'ffee0011');
    expect(backupNameRe.hasMatch('$name.part'), isFalse);

    expect(formatBackupSize(2516582), '2.4 MB');
    expect(formatBackupSize(1500), '2 KB');
  });
}
