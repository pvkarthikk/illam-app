import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

@DataClassName('PayRuleRow')
class PayRules extends Table with SyncedColumns {
  TextColumn get staffId => text().withDefault(const Constant(''))();
  TextColumn get effectiveMonth => text().withDefault(const Constant(''))();
  TextColumn get workDays =>
      text().withDefault(const Constant('1,2,3,4,5,6'))();
  TextColumn get payType => text().withDefault(const Constant('hourly'))();
  IntColumn get ratePerHourPaise => integer().withDefault(const Constant(0))();
  IntColumn get roundingMin => integer().withDefault(const Constant(1))();
  IntColumn get minHoursPerVisit => integer().withDefault(const Constant(0))();
  IntColumn get amountPerMonthPaise =>
      integer().withDefault(const Constant(0))();
  IntColumn get paidLeavesPerMonth =>
      integer().withDefault(const Constant(0))();
}
