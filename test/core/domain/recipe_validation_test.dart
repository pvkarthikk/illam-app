import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/recipe_validation.dart';

RecipeDraft _validDraft() => RecipeDraft(
  name: 'Ghee pongal',
  timeMin: 20,
  serves: 4,
  ingredients: [IngredientDraft(name: 'Ghee', qtyText: '2', unit: 'tbsp')],
  steps: ['Cook rice and dal together.'],
);

void main() {
  test('parseQty handles fractions, decimals and invalid input', () {
    expect(parseQty('1/2'), 0.5);
    expect(parseQty('0.5'), 0.5);
    expect(parseQty('abc'), isNull);
    expect(parseQty('1/0'), isNull);
  });

  test('valid draft produces empty error map', () {
    expect(validateRecipe(_validDraft()), isEmpty);
  });

  test('one failing case per validation rule returns expected keys', () {
    final badName = _validDraft()..name = ' ';
    expect(validateRecipe(badName)['name'], 'recipeErrName');

    final badTime = _validDraft()..timeMin = 0;
    expect(validateRecipe(badTime)['time'], 'recipeErrTime');

    final badServes = _validDraft()..serves = 21;
    expect(validateRecipe(badServes)['serves'], 'recipeErrServes');

    final noIng = _validDraft()..ingredients = [];
    expect(validateRecipe(noIng)['ingredients'], 'recipeErrIngredients');

    final badIngName = _validDraft()
      ..ingredients = [IngredientDraft(name: '', qtyText: '2', unit: 'tbsp')];
    expect(validateRecipe(badIngName)['ingName.0'], 'recipeErrIngName');

    final badIngQty = _validDraft()
      ..ingredients = [IngredientDraft(name: 'Ghee', qtyText: '0', unit: 'tbsp')];
    expect(validateRecipe(badIngQty)['ingQty.0'], 'recipeErrQty');

    final noSteps = _validDraft()..steps = ['   '];
    expect(validateRecipe(noSteps)['steps'], 'recipeErrSteps');

    final longStep = _validDraft()..steps = ['x' * 501];
    expect(validateRecipe(longStep)['step.0'], 'recipeErrStepLong');
  });
}
