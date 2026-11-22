import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

@DataClassName('ExpenseRow')
@TableIndex(name: 'expenses_date_created', columns: {#date, #createdAt})
@TableIndex(name: 'expenses_source_paid_by', columns: {#source, #paidBy})
class Expenses extends Table with SyncedColumns {
  IntColumn get amountPaise => integer().withDefault(const Constant(0))();
  TextColumn get merchant => text().withDefault(const Constant(''))();
  TextColumn get merchantKey => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant('Other'))();
  TextColumn get method => text().withDefault(const Constant('upi'))();
  TextColumn get date => text().withDefault(const Constant(''))();
  TextColumn get docMonth => text().withDefault(const Constant(''))();
  TextColumn get forMonth => text().nullable()();
  TextColumn get paidBy => text().withDefault(const Constant(''))();
  TextColumn get addedBy => text().withDefault(const Constant(''))();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get billId => text().nullable()();
  TextColumn get orderChannel => text().nullable()();
  TextColumn get staffId => text().nullable()();
  TextColumn get settlementAttemptId => text().nullable()();
  TextColumn get note => text().nullable()();
}
