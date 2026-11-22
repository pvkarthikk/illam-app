import 'package:drift/drift.dart';

mixin SyncedColumns on Table {
  TextColumn get id => text()(); // id
  TextColumn get homeId => text()(); // home_id
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt =>
      integer().withDefault(const Constant(0))(); // created_at (epoch ms)
  TextColumn get createdBy =>
      text().withDefault(const Constant(''))(); // memberId
  IntColumn get updatedAt => integer().withDefault(const Constant(0))();
  TextColumn get updatedBy => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
