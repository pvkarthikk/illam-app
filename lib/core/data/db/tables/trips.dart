import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

@DataClassName('TripRow')
@TableIndex(name: 'trips_home_start', columns: {#homeId, #startDate})
class Trips extends Table with SyncedColumns {
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get startDate => text().withDefault(const Constant(''))();
  TextColumn get endDate => text().nullable()();
  TextColumn get note => text().nullable()();
}
