import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

class DevNotes extends Table with SyncedColumns {
  TextColumn get title => text().nullable()();
  TextColumn get body => text().nullable()();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  IntColumn get taps =>
      integer().withDefault(const Constant(0))(); // counter: only ever changed with inc
}
