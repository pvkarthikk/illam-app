import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

@DataClassName('TripTemplateItemRow')
@TableIndex(name: 'trip_template_home_sort', columns: {#homeId, #sortOrder})
class TripTemplateItems extends Table with SyncedColumns {
  TextColumn get title => text().withDefault(const Constant(''))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
