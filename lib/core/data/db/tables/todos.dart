import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

@DataClassName('TodoRow')
class Todos extends Table with SyncedColumns {
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get due => text().withDefault(const Constant(''))();
  TextColumn get assigneeType =>
      text().withDefault(const Constant('member'))();
  TextColumn get assignee => text().withDefault(const Constant(''))();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get doneAt => integer().nullable()();
  TextColumn get doneBy => text().nullable()();
}
