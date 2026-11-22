import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

@DataClassName('PantryEntry')
class Pantry extends Table with SyncedColumns {
  TextColumn get nameKey => text().withDefault(const Constant(''))();
  TextColumn get name => text().withDefault(const Constant(''))();
  BoolColumn get inStock => boolean().withDefault(const Constant(false))();
}
