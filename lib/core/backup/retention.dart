import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/file_format.dart';

/// Selects old backups for [vault8] beyond the newest [keep], never deleting [protect].
List<String> namesToDelete(
  List<RemoteBackupFile> files, {
  required String vault8,
  required int keep,
  String? protect,
}) {
  final matched = <({String name, String time})>[];
  for (final f in files) {
    final m = backupNameRe.firstMatch(f.name);
    if (m == null || m.group(1) != vault8) continue;
    matched.add((name: f.name, time: m.group(2)!));
  }
  matched.sort((a, b) {
    final cmp = b.time.compareTo(a.time);
    return cmp != 0 ? cmp : b.name.compareTo(a.name);
  });

  if (matched.length <= keep) return const [];
  return [
    for (var i = keep; i < matched.length; i++)
      if (matched[i].name != protect) matched[i].name,
  ];
}
