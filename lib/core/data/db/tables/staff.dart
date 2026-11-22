import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

@DataClassName('StaffData')
class Staff extends Table with SyncedColumns {
  TextColumn get name => text().nullable()();
  TextColumn get role => text().nullable()();
  TextColumn get phoneE164 => text().named('phone_e164').nullable()();
  TextColumn get upiId => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get workDays =>
      text().withDefault(const Constant('1,2,3,4,5,6'))();
  TextColumn get expectedTimes => text().withDefault(const Constant('09:00'))();
  TextColumn get usualEndTime => text().nullable()();
  TextColumn get startDate => text().nullable()();
  TextColumn get endDate => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get initialPayType => text().nullable()();
  IntColumn get initialPayPaise => integer().nullable()();
}

@DataClassName('Visit')
class Visits extends Table with SyncedColumns {
  TextColumn get staffId => text().nullable()();
  TextColumn get date => text().nullable()();
  IntColumn get inAt => integer().nullable()();
  IntColumn get outAt => integer().nullable()();
  TextColumn get inBy => text().nullable()();
  TextColumn get outBy => text().nullable()();
}

@DataClassName('Leave')
class Leaves extends Table with SyncedColumns {
  TextColumn get staffId => text().nullable()();
  TextColumn get date => text().nullable()();
  TextColumn get markedBy => text().nullable()();
}
