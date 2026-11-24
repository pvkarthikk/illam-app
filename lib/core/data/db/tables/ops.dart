import 'package:drift/drift.dart';

@DataClassName('OpRow')
@TableIndex(name: 'ops_device_seq', columns: {#deviceId, #seq})
@TableIndex(name: 'ops_home_device_seq', columns: {#homeId, #deviceId, #seq})
@TableIndex(name: 'ops_tbl_entity', columns: {#tbl, #entityId})
class Ops extends Table {
  TextColumn get opId => text()(); // "$deviceId:$seq"
  TextColumn get homeId => text()();
  TextColumn get deviceId => text()(); // author device (16 chars)
  IntColumn get seq => integer()(); // per-device counter 1, 2, 3 … never reused
  TextColumn get hlc => text()(); // hybrid logical clock string
  TextColumn get authorMemberId => text()();
  TextColumn get changeId => text()(); // groups the ops of one user action
  TextColumn get tbl => text()(); // SQL table name, e.g. "dev_notes"
  TextColumn get entityId => text()();
  TextColumn get kind => text()(); // "set" | "inc"
  TextColumn get field =>
      text()(); // SQL column name; delete = set("deleted", true)
  TextColumn get valueJson =>
      text().nullable()(); // JSON literal for "set": "\"Milk\"", "2", "true", "null"
  IntColumn get delta => integer().nullable()(); // for "inc"
  TextColumn get sig =>
      text().withDefault(const Constant(''))(); // signature (added in P13)
  TextColumn get status => text().withDefault(
    const Constant('applied'),
  )(); // applied | pending | quarantined

  @override
  Set<Column> get primaryKey => {opId};
}

class FieldClocks extends Table {
  TextColumn get tbl => text()();
  TextColumn get entityId => text()();
  TextColumn get field => text()();
  TextColumn get hlc => text()();

  @override
  Set<Column> get primaryKey => {tbl, entityId, field};
}
