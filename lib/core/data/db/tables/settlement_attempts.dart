import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

@DataClassName('SettlementAttemptRow')
class SettlementAttempts extends Table with SyncedColumns {
  TextColumn get staffId => text().withDefault(const Constant(''))();
  TextColumn get month => text().withDefault(const Constant(''))();
  TextColumn get kind => text().withDefault(const Constant('settle'))();
  TextColumn get refAttemptId => text().nullable()();
  IntColumn get amountPaise => integer().withDefault(const Constant(0))();
  TextColumn get method => text().nullable()();
  IntColumn get netPaise => integer().withDefault(const Constant(0))();
  TextColumn get breakdownJson => text().nullable()();
  IntColumn get deltaPaise => integer().withDefault(const Constant(0))();
  TextColumn get prevTransferIds => text().nullable()();
  TextColumn get expenseId => text().nullable()();
  TextColumn get byMember => text().withDefault(const Constant(''))();
}
