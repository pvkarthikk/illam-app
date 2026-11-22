import 'package:nm_flat/core/domain/fractions.dart';
import 'package:nm_flat/core/domain/recipe_scaling.dart';
import 'package:nm_flat/core/domain/units.dart';

class Ingredient {
  const Ingredient({
    required this.name,
    required this.nameKey,
    required this.qty,
    required this.unit,
  });

  factory Ingredient.fromJson(Map<String, Object?> j) {
    final name = j['name'];
    final nameKey = j['nameKey'];
    final unit = j['unit'];
    final qty = j['qty'];
    return Ingredient(
      name: name is String ? name : '',
      nameKey: nameKey is String ? nameKey : '',
      qty: qty is num ? qty.toDouble() : 1.0,
      unit: unit is String ? unit : '',
    );
  }

  final String name;
  final String nameKey;
  final double qty;
  final String unit;

  Map<String, Object?> toJson() => {
    'name': name,
    'nameKey': nameKey,
    'qty': qty,
    'unit': unit,
  };
}

enum IngredientState { have, onList, missing }

IngredientState ingredientState(
  String nameKey,
  Set<String> openGroceryKeys,
  Set<String> pantryInStockKeys,
) {
  if (openGroceryKeys.contains(nameKey)) return IngredientState.onList;
  if (pantryInStockKeys.contains(nameKey)) return IngredientState.have;
  return IngredientState.missing;
}

class PlannedRecipe {
  const PlannedRecipe(this.dish, this.serves, this.ingredients);

  final String dish;
  final int serves;
  final List<Ingredient> ingredients;
}

class MissingLine {
  const MissingLine({
    required this.name,
    required this.nameKey,
    required this.qty,
    required this.unit,
    required this.dish,
  });

  final String name;
  final String nameKey;
  final double qty;
  final String unit;
  final String dish;
}

List<MissingLine> missingFor(
  List<PlannedRecipe> planned,
  Set<String> openKeys,
  Set<String> pantryKeys,
) {
  final lines = <MissingLine>[];
  final indexByKey = <String, int>{};

  for (final r in planned) {
    for (final i in r.ingredients) {
      if (ingredientState(i.nameKey, openKeys, pantryKeys) !=
          IngredientState.missing) {
        continue;
      }
      final unit = baseUnit(i.unit);
      final qty = toBaseQty(i.qty, i.unit);
      final groupKey = '${i.nameKey}|$unit';
      final existingIdx = indexByKey[groupKey];
      if (existingIdx == null) {
        indexByKey[groupKey] = lines.length;
        lines.add(
          MissingLine(
            name: i.name,
            nameKey: i.nameKey,
            qty: qty,
            unit: unit,
            dish: r.dish,
          ),
        );
      } else {
        final cur = lines[existingIdx];
        lines[existingIdx] = MissingLine(
          name: cur.name,
          nameKey: cur.nameKey,
          qty: cur.qty + qty,
          unit: cur.unit,
          dish: cur.dish,
        );
      }
    }
  }
  return lines;
}

class GroceryLine {
  const GroceryLine({
    required this.name,
    required this.nameKey,
    required this.qty,
    required this.unit,
    this.note,
  });

  final String name;
  final String nameKey;
  final double qty;
  final String unit;
  final String? note;
}

GroceryLine toGroceryLine(MissingLine m) {
  if (familyOf(m.unit) == UnitFamily.kitchen) {
    return GroceryLine(
      name: m.name,
      nameKey: m.nameKey,
      qty: 1,
      unit: '',
      note: '${formatFraction(m.qty, m.unit)} ${m.unit} · ${m.dish}',
    );
  }
  if (m.unit == 'g' && m.qty >= 1000) {
    return GroceryLine(
      name: m.name,
      nameKey: m.nameKey,
      qty: m.qty / 1000,
      unit: 'kg',
    );
  }
  if (m.unit == 'ml' && m.qty >= 1000) {
    return GroceryLine(
      name: m.name,
      nameKey: m.nameKey,
      qty: m.qty / 1000,
      unit: 'L',
    );
  }
  return GroceryLine(
    name: m.name,
    nameKey: m.nameKey,
    qty: m.qty,
    unit: m.unit,
  );
}

List<MissingLine> recipeMissing(
  PlannedRecipe r,
  int servings,
  Set<String> openKeys,
  Set<String> pantryKeys,
) => [
  for (final i in r.ingredients)
    if (ingredientState(i.nameKey, openKeys, pantryKeys) ==
        IngredientState.missing)
      MissingLine(
        name: i.name,
        nameKey: i.nameKey,
        qty: scaleQty(i.qty, r.serves, servings),
        unit: i.unit,
        dish: r.dish,
      ),
];
