import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

@DataClassName('BackupStatusRow')
class BackupStatus extends Table with SyncedColumns {
  TextColumn get memberId => text().withDefault(const Constant(''))();
  TextColumn get frequency => text().withDefault(const Constant('weekly'))();
  BoolColumn get recoveryCapable =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get offPhone => boolean().withDefault(const Constant(false))();
  TextColumn get destsJson => text().withDefault(const Constant('[]'))();
}
