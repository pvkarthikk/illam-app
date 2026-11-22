import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/file_format.dart';
import 'package:nm_flat/core/backup/retention.dart';

RemoteBackupFile _file(String vault8, int minuteOffset, String snap8) {
  final ts = DateTime.utc(2026, 11, 20, 10, minuteOffset).millisecondsSinceEpoch;
  final name = backupFileName(
    vaultId: vault8 + List.filled(24, '0').join(),
    snapshotId: snap8 + List.filled(24, '0').join(),
    createdAtMs: ts,
  );
  return RemoteBackupFile(name, 1024, ts);
}

void main() {
  test('6 files for vault aaaaaaaa with keep 5 returns only the oldest', () {
    final files = [for (var i = 0; i < 6; i++) _file('aaaaaaaa', i, '0000000$i')];
    final del = namesToDelete(files, vault8: 'aaaaaaaa', keep: 5);
    expect(del, [files.first.name]);
  });

  test('ignores files belonging to other vaults', () {
    final files = [
      for (var i = 0; i < 6; i++) _file('aaaaaaaa', i, '0000000$i'),
      for (var i = 0; i < 6; i++) _file('bbbbbbbb', i, '1111111$i'),
    ];
    final del = namesToDelete(files, vault8: 'aaaaaaaa', keep: 5);
    expect(del, [files.first.name]);
    expect(del.any((n) => n.contains('bbbbbbbb')), isFalse);
  });

  test('7 files with keep 5 and protect=oldest deletes only second-oldest', () {
    final files = [for (var i = 0; i < 7; i++) _file('aaaaaaaa', i, '0000000$i')];
    final del = namesToDelete(
      files,
      vault8: 'aaaaaaaa',
      keep: 5,
      protect: files[0].name,
    );
    expect(del, [files[1].name]);
  });

  test('keep 30 with 3 files deletes nothing', () {
    final files = [for (var i = 0; i < 3; i++) _file('aaaaaaaa', i, '0000000$i')];
    expect(namesToDelete(files, vault8: 'aaaaaaaa', keep: 30), isEmpty);
  });
}
