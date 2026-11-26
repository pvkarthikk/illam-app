import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/spend_category.dart';

void main() {
  test('Zepto maps to Groceries', () {
    expect(guessSpendCategory('Zepto', const {}), 'Groceries');
  });

  test('Milkman maps to Groceries', () {
    expect(guessSpendCategory('Milkman', const {}), 'Groceries');
  });

  test('Swiggy Instamart maps to Groceries before Eating out', () {
    expect(guessSpendCategory('Swiggy Instamart', const {}), 'Groceries');
  });

  test('Swiggy maps to Eating out', () {
    expect(guessSpendCategory('Swiggy', const {}), 'Eating out');
  });

  test('learned rule overrides built-in keywords', () {
    expect(
      guessSpendCategory('Swiggy', const {'swiggy': 'Groceries'}),
      'Groceries',
    );
  });

  test('Electricity (BESCOM) maps to Utilities', () {
    expect(guessSpendCategory('Electricity (BESCOM)', const {}), 'Utilities');
  });

  test('Society maintenance maps to Home care', () {
    expect(guessSpendCategory('Society maintenance', const {}), 'Home care');
  });

  test('Broadband (ACT) maps to Utilities', () {
    expect(guessSpendCategory('Broadband (ACT)', const {}), 'Utilities');
  });

  test('Urban Company maps to Home care', () {
    expect(guessSpendCategory('Urban Company', const {}), 'Home care');
  });

  test('Rent falls back to Other', () {
    expect(guessSpendCategory('Rent', const {}), 'Other');
  });

  group('normalizeSpendCategory & mergeSpendCategories', () {
    test('normalizes whitespace, built-in casing, lowercase & clamps length', () {
      expect(normalizeSpendCategory('  groceries  '), 'Groceries');
      expect(normalizeSpendCategory('EATING   OUT'), 'Eating out');
      expect(normalizeSpendCategory('medical'), 'Medical');
      expect(normalizeSpendCategory('  health   care  '), 'Health care');
      expect(normalizeSpendCategory('PetCare'), 'PetCare');
      expect(normalizeSpendCategory('   '), 'Other');
      expect(normalizeSpendCategory('', fallback: 'Shopping'), 'Shopping');
      expect(
        normalizeSpendCategory('A very long custom household category name').length,
        lessThanOrEqualTo(maxSpendCategoryLength),
      );
    });

    test('merges built-ins with sorted distinct custom categories before Other', () {
      final merged = mergeSpendCategories([
        'Travel',
        'medical',
        'Medical',
        'utilities',
        'Fuel',
        '  ',
      ]);
      expect(merged, [
        'Groceries',
        'Shopping',
        'Staff',
        'Utilities',
        'Eating out',
        'Home care',
        'Fuel',
        'Medical',
        'Travel',
        'Other',
      ]);
    });
  });
}
