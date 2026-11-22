import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/tables/synced_columns.dart';

@DataClassName('Recipe')
class Recipes extends Table with SyncedColumns {
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get glyph => text().withDefault(const Constant(''))();
  TextColumn get color => text().withDefault(const Constant('#5E8A2B'))();
  IntColumn get timeMin => integer().withDefault(const Constant(0))();
  IntColumn get serves => integer().withDefault(const Constant(4))();
  TextColumn get mealTypes => text().withDefault(const Constant('[]'))();
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  TextColumn get ingredientsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get stepsJson => text().withDefault(const Constant('[]'))();
}
