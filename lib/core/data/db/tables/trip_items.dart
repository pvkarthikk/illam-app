import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

@DataClassName('TripItemRow')
@TableIndex(name: 'trip_items_trip_done', columns: {#tripId, #done})
class TripItems extends Table with SyncedColumns {
  TextColumn get tripId => text().withDefault(const Constant(''))();
  TextColumn get title => text().withDefault(const Constant(''))();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get doneAt => integer().nullable()();
  TextColumn get doneBy => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
