import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

class Members extends Table with SyncedColumns {
  TextColumn get fullName => text().nullable()();
  TextColumn get firstName => text().nullable()();
  TextColumn get role => text().withDefault(const Constant('member'))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get color => text().nullable()();
  TextColumn get deviceModel => text().nullable()();
  IntColumn get joinedAt => integer().nullable()();
  TextColumn get joinedVia => text().nullable()();
  TextColumn get invitedBy => text().nullable()();
}
