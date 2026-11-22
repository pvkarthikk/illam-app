import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

@DataClassName('RoutineRow')
class Routines extends Table with SyncedColumns {
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get room => text().withDefault(const Constant('Kitchen'))();
  IntColumn get everyDays => integer().withDefault(const Constant(7))();
  TextColumn get assigneeType =>
      text().withDefault(const Constant('member'))();
  TextColumn get assignee => text().withDefault(const Constant(''))();
  TextColumn get lastDone => text().withDefault(const Constant(''))();
  TextColumn get lastDoneBy => text().nullable()();
}
