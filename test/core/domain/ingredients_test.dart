import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/ingredients.dart';
import 'package:nm_flat/core/domain/item_parse.dart';
import 'package:nm_flat/core/domain/recipe_scaling.dart';

Ingredient _ing(String name, double qty, [String unit = '']) => Ingredient(
  name: name,
  nameKey: itemNameKey(name),
  qty: qty,
  unit: unit,
);

void main() {
  final pesarattu = PlannedRecipe('Pesarattu', 3, [
    _ing('Green moong', 1, 'cup'),
    _ing('Ginger', 1, 'inch'),
    _ing('Green chillies', 2),
    _ing('Onion', 1),
    _ing('Cumin', 1, 'tsp'),
  ]);
  final alooParatha = PlannedRecipe('Aloo paratha', 4, [
    _ing('Wheat atta', 2, 'cup'),
    _ing('Potatoes', 4),
    _ing('Green chillies', 2),
    _ing('Coriander', 1, 'bunch'),
    _ing('Ghee', 2, 'tbsp'),
  ]);
  final tomatoRasam = PlannedRecipe('Tomato rasam', 4, [
    _ing('Tomatoes', 3),
    _ing('Tamarind', 1, 'small'),
    _ing('Rasam powder', 1, 'tbsp'),
    _ing('Coriander', 1, 'bunch'),
  ]);
  final paneer = PlannedRecipe('Paneer butter masala', 4, [
    _ing('Paneer', 200, 'g'),
    _ing('Tomatoes', 4),
    _ing('Cashews', 12),
    _ing('Butter', 2, 'tbsp'),
    _ing('Fresh cream', 3, 'tbsp'),
  ]);
  final vegPulao = PlannedRecipe('Veg pulao', 4, [
    _ing('Basmati rice', 1.5, 'cup'),
    _ing('Mixed vegetables', 2, 'cup'),
    _ing('Whole spices', 1, 'tbsp'),
    _ing('Ghee', 1, 'tbsp'),
  ]);
  final dalTadka = PlannedRecipe('Dal tadka', 4, [
    _ing('Toor dal', 1, 'cup'),
    _ing('Onion', 1),
    _ing('Tomatoes', 1),
    _ing('Garlic', 6, 'clove'),
  ]);

  test('week vector aggregates missing lines and converts to grocery lines', () {
    final planned = [
      pesarattu,
      tomatoRasam,
      paneer,
      vegPulao,
      dalTadka,
      alooParatha,
    ];
    final openKeys = {
      itemNameKey('Tomatoes'),
      itemNameKey('Coriander'),
      itemNameKey('Toor dal'),
      itemNameKey('Basmati rice'),
    };
    final allKeys = {
      for (final r in planned)
        for (final i in r.ingredients) i.nameKey,
    };
    final pantryKeys = allKeys.difference({
      itemNameKey('Green chillies'),
      itemNameKey('Fresh cream'),
    });

    final lines = missingFor(planned, openKeys, pantryKeys);
    expect(lines.length, 2);
    expect(lines[0].name, 'Green chillies');
    expect(lines[0].qty, 4);
    expect(lines[0].unit, '');
    expect(lines[0].dish, 'Pesarattu');
    expect(lines[1].name, 'Fresh cream');
    expect(lines[1].qty, 3);
    expect(lines[1].unit, 'tbsp');
    expect(lines[1].dish, 'Paneer butter masala');

    final g0 = toGroceryLine(lines[0]);
    expect(g0.qty, 4);
    expect(g0.unit, '');
    expect(g0.note, isNull);

    final g1 = toGroceryLine(lines[1]);
    expect(g1.qty, 1);
    expect(g1.unit, '');
    expect(g1.note, '3 tbsp · Paneer butter masala');
  });

  test('ingredientState distinguishes have, onList, and missing', () {
    final open = {itemNameKey('Tomatoes')};
    final pantry = {itemNameKey('Tomatoes'), itemNameKey('Paneer')};
    expect(
      ingredientState(itemNameKey('Tomatoes'), open, pantry),
      IngredientState.onList,
    );
    expect(
      ingredientState(itemNameKey('Paneer'), open, pantry),
      IngredientState.have,
    );
    expect(
      ingredientState(itemNameKey('Fresh cream'), open, pantry),
      IngredientState.missing,
    );
  });

  test('recipeMissing filters only missing ingredients and scales qty', () {
    final lines = recipeMissing(
      paneer,
      4,
      {itemNameKey('Tomatoes')},
      {itemNameKey('Paneer'), itemNameKey('Cashews'), itemNameKey('Butter')},
    );
    expect(lines.length, 1);
    expect(lines.single.name, 'Fresh cream');
    expect(scaleQty(200, 4, 6), 300);
  });

  test('base units merge mass across g/kg while keeping distinct kitchen units separate', () {
    final r1 = PlannedRecipe('A', 2, [
      _ing('Flour', 600, 'g'),
      _ing('Sugar', 2, 'cup'),
    ]);
    final r2 = PlannedRecipe('B', 2, [
      _ing('Flour', 0.5, 'kg'),
      _ing('Sugar', 200, 'g'),
    ]);

    final flourLines = missingFor([
      PlannedRecipe('A', 2, [_ing('Flour', 600, 'g')]),
      PlannedRecipe('B', 2, [_ing('Flour', 0.5, 'kg')]),
    ], const {}, const {});
    expect(flourLines.length, 1);
    expect(flourLines.single.qty, 1100);
    expect(flourLines.single.unit, 'g');
    final flourGrocery = toGroceryLine(flourLines.single);
    expect(flourGrocery.qty, 1.1);
    expect(flourGrocery.unit, 'kg');

    final mixedLines = missingFor([r1, r2], const {}, const {});
    expect(mixedLines.length, 3);
    final sugarLines =
        mixedLines.where((l) => l.name == 'Sugar').toList();
    expect(sugarLines.length, 2);
  });
}
