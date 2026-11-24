import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/undo.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/repo/recipes_repo.dart';
import 'package:nm_flat/core/domain/ingredients.dart';
import 'package:nm_flat/core/domain/item_category.dart';
import 'package:nm_flat/core/domain/usual_store.dart';
import 'package:nm_flat/core/util/hash_id.dart';

class MealsRepo {
  MealsRepo(this.db, this.changes, this.prefs, this.homeId);

  final NestDatabase db;
  final ChangeWriter changes;
  final DevicePrefs prefs;
  final String homeId;

  String slotId(String date, String slot) => 'ms_${homeId}_${date}_$slot';

  Future<List<String>> _slotIds(String date, String slot) async {
    final rows =
        await (db.select(db.mealSlots)..where(
              (s) =>
                  s.homeId.equals(homeId) &
                  s.date.equals(date) &
                  s.slot.equals(slot) &
                  s.deleted.equals(false),
            ))
            .get();
    if (rows.isEmpty) return [slotId(date, slot)];
    return [for (final r in rows) r.id];
  }

  Stream<List<MealSlot>> watchRange(String fromIso, String toIso) =>
      (db.select(db.mealSlots)..where(
            (s) =>
                s.homeId.equals(homeId) &
                s.deleted.equals(false) &
                s.kind.equals('').not() &
                s.date.isBiggerOrEqualValue(fromIso) &
                s.date.isSmallerOrEqualValue(toIso),
          ))
          .watch();

  Stream<Set<String>> watchPantryInStock() =>
      (db.select(db.pantry)..where(
            (p) =>
                p.homeId.equals(homeId) &
                p.deleted.equals(false) &
                p.inStock.equals(true),
          ))
          .watch()
          .map((rows) => {for (final r in rows) r.nameKey})
          .distinct(const SetEquality<String>().equals);

  // Also returns bought rows until they are cleared.
  Stream<Set<String>> watchOpenGroceryKeys() =>
      (db.select(db.items)..where(
            (i) =>
                i.homeId.equals(homeId) &
                i.list.equals('grocery') &
                i.deleted.equals(false),
          ))
          .watch()
          .map((rows) => {for (final r in rows) r.nameKey})
          .distinct(const SetEquality<String>().equals);

  Future<ChangeResult> planRecipe(
    String date,
    String slot,
    RecipeView r,
  ) async {
    final ids = await _slotIds(date, slot);
    return changes.write('Planned meal', (c) {
      for (final id in ids) {
        c.setAll('meal_slots', id, {
          'deleted': false,
          'date': date,
          'slot': slot,
          'kind': 'recipe',
          'recipe_id': r.id,
          'name_snapshot': r.name,
          'text': null,
        });
      }
    }, homeId: homeId);
  }

  Future<ChangeResult> planKind(
    String date,
    String slot,
    String kind, {
    String? text,
  }) async {
    final ids = await _slotIds(date, slot);
    return changes.write('Planned meal', (c) {
      for (final id in ids) {
        c.setAll('meal_slots', id, {
          'deleted': false,
          'date': date,
          'slot': slot,
          'kind': kind,
          'recipe_id': null,
          'name_snapshot': null,
          'text': text,
        });
      }
    }, homeId: homeId);
  }

  Future<ChangeResult> clearSlot(String date, String slot) async {
    final ids = await _slotIds(date, slot);
    return changes.write('Cleared slot', (c) {
      for (final id in ids) {
        c.setAll('meal_slots', id, {
          'deleted': false,
          'date': date,
          'slot': slot,
          'kind': '',
          'recipe_id': null,
          'name_snapshot': null,
          'text': null,
        });
      }
    }, homeId: homeId);
  }

  Future<ChangeResult> setPantry(String name, String nameKey, bool inStock) =>
      changes.write('Pantry', (c) {
        c.setAll('pantry', sha1Hex(nameKey), {
          'deleted': false,
          'name': name,
          'name_key': nameKey,
          'in_stock': inStock,
        });
      }, homeId: homeId);

  Future<ChangeResult> addMissing({
    required List<GroceryLine> ticked,
    required List<GroceryLine> unticked,
  }) async {
    final histRows =
        await (db.select(db.itemHistory)..where(
              (h) =>
                  h.homeId.equals(homeId) &
                  h.list.equals('grocery') &
                  h.deleted.equals(false),
            ))
            .get();
    final usualByKey = <String, String>{
      for (final h in histRows)
        if (h.usualChannel != null) h.nameKey: h.usualChannel!,
    };
    final last = prefs.lastStore('grocery');

    return changes.write('Added missing ingredients', (c) {
      for (final line in ticked) {
        final channel = usualStore(
          list: 'grocery',
          nameKey: line.nameKey,
          usualByKey: usualByKey,
          lastChosen: last,
        ).channel;
        final id = c.create('items', {
          'list': 'grocery',
          'name': line.name,
          'name_key': line.nameKey,
          if (line.unit.isNotEmpty) 'unit': line.unit,
          'channel': channel,
          'category': guessCategory(line.name),
          'note': line.note,
          'source': 'meal',
        });
        c.inc('items', id, 'qty_milli', (line.qty * 1000).round());
      }
      for (final line in unticked) {
        c.setAll('pantry', sha1Hex(line.nameKey), {
          'deleted': false,
          'name': line.name,
          'name_key': line.nameKey,
          'in_stock': true,
        });
      }
    }, homeId: homeId);
  }

  Future<List<MealSlot>> futureSlotsFor(String recipeId, String fromIso) =>
      (db.select(db.mealSlots)..where(
            (s) =>
                s.homeId.equals(homeId) &
                s.deleted.equals(false) &
                s.kind.equals('recipe') &
                s.recipeId.equals(recipeId) &
                s.date.isBiggerOrEqualValue(fromIso),
          ))
          .get();
}
