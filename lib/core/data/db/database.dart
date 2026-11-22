import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:nm_flat/core/data/db/tables/dev_notes.dart';
import 'package:nm_flat/core/data/db/tables/homes.dart';
import 'package:nm_flat/core/data/db/tables/members.dart';
import 'package:nm_flat/core/data/db/tables/ops.dart';
import 'package:nm_flat/core/data/db/tables/staff.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Ops, FieldClocks, DevNotes, Homes, Members, Staff, Visits, Leaves])
class NestDatabase extends _$NestDatabase {
  NestDatabase(super.e);

  factory NestDatabase.open() =>
      NestDatabase(driftDatabase(name: 'nestmojo'));

  NestDatabase.forTesting(QueryExecutor e)
    : super(DatabaseConnection(e, closeStreamsSynchronously: true));

  @override
  int get schemaVersion => 3; // raise by 1 for every table change

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // DEV ONLY: start fresh on schema change (until release)
      for (final t in allTables.toList().reversed) {
        await m.deleteTable(t.actualTableName);
      }
      await m.createAll();
    },
  );

  /// Developer "Wipe this phone" and P03's one-time switch to real device keys.
  Future<void> wipeAll() => transaction(() async {
    for (final t in allTables) {
      await delete(t).go();
    }
  });
}
