import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

@DataClassName('PayAdjustmentRow')
@TableIndex(name: 'pay_adjustments_staff_month', columns: {#staffId, #month})
class PayAdjustments extends Table with SyncedColumns {
  TextColumn get staffId => text().withDefault(const Constant(''))();
  TextColumn get month => text().withDefault(const Constant(''))();
  TextColumn get kind => text().withDefault(const Constant('extra'))();
  IntColumn get amountPaise => integer().withDefault(const Constant(0))();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get settlementAttemptId => text().nullable()();
}
