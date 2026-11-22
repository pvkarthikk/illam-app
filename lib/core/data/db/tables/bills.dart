import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

@DataClassName('Bill')
class Bills extends Table with SyncedColumns {
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant('Other'))();
  IntColumn get usualAmountPaise => integer().withDefault(const Constant(0))();
  IntColumn get dueDay => integer().withDefault(const Constant(1))();
  TextColumn get firstDueMonth => text().withDefault(const Constant(''))();
  TextColumn get method => text().withDefault(const Constant('upi'))();
  BoolColumn get remind => boolean().withDefault(const Constant(true))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}
