import 'package:drift/drift.dart';

/// Projected device directory rebuilt by every membership replay (never in CollectionRegistry).
@DataClassName('MemberDeviceRow')
class MemberDevices extends Table {
  TextColumn get deviceId => text()();
  TextColumn get homeId => text()();
  TextColumn get memberId => text()();
  TextColumn get signPub => text()();
  TextColumn get agreePub => text().withDefault(const Constant(''))();
  TextColumn get model => text().withDefault(const Constant(''))();
  IntColumn get addedAt => integer().withDefault(const Constant(0))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get endedHlc => text().nullable()();

  @override
  Set<Column> get primaryKey => {deviceId};
}
