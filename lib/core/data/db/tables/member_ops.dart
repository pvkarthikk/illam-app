import 'package:drift/drift.dart';

/// Device-local log of signed membership operations (never registered in CollectionRegistry).
@DataClassName('MemberOpRow')
class MemberOps extends Table {
  TextColumn get opId => text()();
  TextColumn get homeId => text()();
  TextColumn get opType => text()();
  TextColumn get authorDeviceId => text()();
  TextColumn get hlc => text()();
  TextColumn get prevJson => text().withDefault(const Constant('[]'))();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
  TextColumn get sig => text()();
  BoolColumn get sigOk => boolean().nullable()();
  TextColumn get effect => text().withDefault(const Constant('pending'))();
  TextColumn get reason => text().nullable()();
  IntColumn get receivedAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {opId};
}
