import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/repo/lists_repo.dart';
import 'package:nm_flat/core/data/repo/meals_repo.dart';
import 'package:nm_flat/core/data/repo/recipes_repo.dart';
import 'package:nm_flat/core/domain/ingredients.dart';
import 'package:nm_flat/core/domain/item_parse.dart';
import 'package:nm_flat/core/domain/recipe_validation.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';
import 'package:nm_flat/core/util/hash_id.dart';

typedef _Env = ({
  NestDatabase db,
  ChangeWriter changes,
  DevicePrefs prefs,
  RecipesRepo recipes,
  MealsRepo meals,
  ListsRepo lists,
});

Future<_Env> _env() async {
  final db = NestDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final prefs = await DevicePrefs.inMemory();
  await prefs.setCurrentHomeId('home1');
  await prefs.setMemberId('mem-1');
  final clock = FixedClock(DateTime(2026, 11, 20, 9, 0));
  final changes = ChangeWriter(
    db,
    CollectionRegistry.build(db),
    HlcClock(clock, prefs),
    prefs,
  );
  return (
    db: db,
    changes: changes,
    prefs: prefs,
    recipes: RecipesRepo(db, changes, 'home1'),
    meals: MealsRepo(db, changes, prefs, 'home1'),
    lists: ListsRepo(db, changes, prefs, clock),
  );
}

Future<RecipeView> _createSampleRecipe(_Env e) async {
  final id = await e.recipes.save(
    RecipeDraft(
      name: 'Paneer butter masala',
      timeMin: 35,
      serves: 4,
      mealTypes: ['Dinner'],
      ingredients: [IngredientDraft(name: 'Paneer', qtyText: '200', unit: 'g')],
      steps: ['Cook and serve.'],
    ),
  );
  return (await e.recipes.watchOne(id).first)!;
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  test('planRecipe sets fixed slotId and clearSlot keeps row with empty kind', () async {
    final e = await _env();
    final r = await _createSampleRecipe(e);

    await e.meals.planRecipe('2026-11-20', 'dinner', r);
    final slotId = e.meals.slotId('2026-11-20', 'dinner');
    expect(slotId, 'ms_home1_2026-11-20_dinner');

    final row = await (e.db.select(
      e.db.mealSlots,
    )..where((s) => s.id.equals(slotId))).getSingle();
    expect(row.kind, 'recipe');
    expect(row.recipeId, r.id);

    await e.meals.clearSlot('2026-11-20', 'dinner');
    final after = await (e.db.select(
      e.db.mealSlots,
    )..where((s) => s.id.equals(slotId))).getSingle();
    expect(after.kind, '');
    expect(after.deleted, isFalse);

    final ranged = await e.meals.watchRange('2026-11-16', '2026-11-22').first;
    expect(ranged, isEmpty);
  });

  test('addMissing adds ticked grocery items, marks unticked pantry, and undo reverses both', () async {
    final e = await _env();

    final res = await e.meals.addMissing(
      ticked: const [
        GroceryLine(
          name: 'Fresh cream',
          nameKey: 'fresh cream',
          qty: 1,
          unit: '',
          note: '3 tbsp · Paneer butter masala',
        ),
      ],
      unticked: const [
        GroceryLine(
          name: 'Green chillies',
          nameKey: 'green chillies',
          qty: 4,
          unit: '',
        ),
      ],
    );

    final openItems = await (e.db.select(
      e.db.items,
    )..where((i) => i.deleted.equals(false))).get();
    expect(openItems.length, 1);
    expect(openItems.single.list, 'grocery');
    expect(openItems.single.name, 'Fresh cream');
    expect(openItems.single.qtyMilli, 1000);
    expect(openItems.single.source, 'meal');
    expect(openItems.single.note, '3 tbsp · Paneer butter masala');

    final pantryInStock = await e.meals.watchPantryInStock().first;
    expect(pantryInStock, contains(itemNameKey('Green chillies')));

    await res.undo!.run();

    final afterItems = await (e.db.select(
      e.db.items,
    )..where((i) => i.deleted.equals(false))).get();
    expect(afterItems, isEmpty);
    final afterPantry = await e.meals.watchPantryInStock().first;
    expect(afterPantry, isNot(contains(itemNameKey('Green chillies'))));
  });

  test('softDelete deletes recipe, clears specified slots, and undo restores both', () async {
    final e = await _env();
    final r = await _createSampleRecipe(e);
    await e.meals.planRecipe('2026-11-20', 'dinner', r);
    final slotId = e.meals.slotId('2026-11-20', 'dinner');

    final res = await e.recipes.softDelete(r.id, clearSlotIds: [slotId]);

    expect(await e.recipes.watchOne(r.id).first, isNull);
    final slotAfter = await (e.db.select(
      e.db.mealSlots,
    )..where((s) => s.id.equals(slotId))).getSingle();
    expect(slotAfter.kind, '');

    await res.undo!.run();

    expect((await e.recipes.watchOne(r.id).first)?.name, r.name);
    final slotRestored = await (e.db.select(
      e.db.mealSlots,
    )..where((s) => s.id.equals(slotId))).getSingle();
    expect(slotRestored.kind, 'recipe');
  });

  test('ListsRepo.clearChannel marks cleared grocery items in pantry and undo restores', () async {
    final e = await _env();
    await e.lists.addItem(
      homeId: 'home1',
      list: 'grocery',
      text: 'Green chillies',
    );
    final item = await e.db.select(e.db.items).getSingle();
    await e.lists.tickGroup([item.id], true);

    final (res, count) = await e.lists.clearChannel('grocery', item.channel);
    expect(count, 1);

    final pantryRow = await (e.db.select(
      e.db.pantry,
    )..where((p) => p.id.equals(sha1Hex('green chillies')))).getSingle();
    expect(pantryRow.inStock, isTrue);
    expect(pantryRow.deleted, isFalse);

    await res.undo!.run();

    final inStockAfter = await e.meals.watchPantryInStock().first;
    expect(inStockAfter, isNot(contains('green chillies')));
  });
}
