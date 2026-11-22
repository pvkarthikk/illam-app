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
}
