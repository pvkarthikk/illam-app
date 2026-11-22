import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import 'package:nm_flat/core/notify/notifications.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/util/device_model.dart';
import 'package:nm_flat/core/util/ids.dart';

/// Forks local home data into a brand-new standalone home that never syncs with the old one.
class SeparateCopy {
  const SeparateCopy(this.read);

  final Reader read;

  Future<String> make(
    String oldHomeId, {
    required String newHomeName,
    String? fallbackMemberId,
    String? fallbackName,
  }) async {
    final db = read(dbProvider);
    final prefs = read(prefsProvider);
    final registry = read(registryProvider);

    final incRows = await db
        .customSelect(
          "SELECT DISTINCT tbl, field FROM ops WHERE home_id = ? AND kind = 'inc'",
          variables: [Variable.withString(oldHomeId)],
        )
        .get();
    final counterCols = <String, Set<String>>{};
    for (final r in incRows) {
      final tbl = r.data['tbl'] as String?;
      final field = r.data['field'] as String?;
      if (tbl != null && field != null) {
        (counterCols[tbl] ??= <String>{}).add(field);
      }
    }

    final myMemberId = prefs.memberId ?? fallbackMemberId ?? prefs.deviceId;
    final memberRow =
        await (db.select(db.members)
              ..where((m) => m.homeId.equals(oldHomeId) & m.id.equals(myMemberId)))
            .getSingleOrNull();
    var creatorName = memberRow?.fullName ?? '';
    if (creatorName.isEmpty) {
      creatorName = fallbackName ?? '';
    }
    if (creatorName.isEmpty) {
      creatorName = 'Me';
    }

    final copiedRows =
        <({String tbl, String id, Map<String, Object?> fields})>[];
    for (final table in registry.tables) {
      final tbl = table.actualTableName;
      if (tbl == 'homes' || tbl == 'members' || tbl == 'backup_status') {
        continue;
      }
      final spec = registry.spec(tbl);
      final sqlRows = await db
          .customSelect(
            'SELECT * FROM $tbl WHERE home_id = ? AND deleted = 0',
            variables: [Variable.withString(oldHomeId)],
          )
          .get();
      for (final r in sqlRows) {
        final id = r.data['id'] as String?;
        if (id == null || id.isEmpty) continue;
        final fields = <String, Object?>{};
        for (final col in spec.columns.keys) {
          if (col == 'deleted') continue;
          final v = registry.fromSql(tbl, col, r.data[col]);
          if (v != null) fields[col] = v;
        }
        copiedRows.add((tbl: tbl, id: id, fields: fields));
      }
    }

    await read(homeEraserProvider).erase(oldHomeId);
    await prefs.setText('provisionalRestore_$oldHomeId', null);
    await prefs.setText('provisionalRestoreAt_$oldHomeId', null);
    await prefs.setText('recoverDead_$oldHomeId', null);

    final keys = await read(deviceKeysProvider.future);
    final newHomeId = await read(homeRepoProvider).createHome(
      creatorName: creatorName,
      homeName: newHomeName,
      keys: keys,
      createdAt: read(clockProvider).nowMs,
      nonceB64: base64Encode(Ids.randomBytes(16)),
      model: await deviceModel(),
    );

    final changes = read(changesProvider);
    for (var i = 0; i < copiedRows.length; i += 200) {
      final end = min(i + 200, copiedRows.length);
      final chunk = copiedRows.sublist(i, end);
      await changes.write('Separate copy', (c) {
        for (final row in chunk) {
          c.set(row.tbl, row.id, 'deleted', false);
          final tblCounters = counterCols[row.tbl] ?? const <String>{};
          for (final entry in row.fields.entries) {
            final col = entry.key;
            final val = entry.value;
            if (col == 'deleted' || val == null) continue;
            if (tblCounters.contains(col)) {
              final delta = (val as num).toInt();
              if (delta != 0) c.inc(row.tbl, row.id, col, delta);
            } else {
              c.set(row.tbl, row.id, col, val);
            }
          }
        }
      }, homeId: newHomeId);
    }

    await prefs.setCurrentHomeId(newHomeId);
    return newHomeId;
  }
}
