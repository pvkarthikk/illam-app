import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

@DataClassName('MealSlot')
class MealSlots extends Table with SyncedColumns {
  TextColumn get date => text().withDefault(const Constant(''))();
  TextColumn get slot => text().withDefault(const Constant(''))();
  TextColumn get kind => text().withDefault(const Constant(''))();
  TextColumn get recipeId => text().nullable()();
  TextColumn get nameSnapshot => text().nullable()();
  TextColumn get slotText => text().named('text').nullable()();
}
