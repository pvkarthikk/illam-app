import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/spend_parser.dart';

void main() {
  ParsedSpend parse(String text) =>
      parseSpend(text, const {}, fallbackMerchant: 'Cash spend');

  test('parses rupee symbol prefix', () {
    final s = parse('₹450 Swiggy');
    expect(s.amountPaise, 45000);
    expect(s.merchant, 'Swiggy');
    expect(s.category, 'Eating out');
  });

  test('parses Rs prefix with space', () {
    final s = parse('Rs 300 milkman');
    expect(s.amountPaise, 30000);
    expect(s.merchant, 'Milkman');
    expect(s.category, 'Groceries');
  });

  test('strips noise words around amount', () {
    final s = parse('paid 1200 electricity bill');
    expect(s.amountPaise, 120000);
    expect(s.merchant, 'Electricity bill');
    expect(s.category, 'Utilities');
  });

  test('uses fallbackMerchant when only amount is given', () {
    final s = parse('450');
    expect(s.amountPaise, 45000);
    expect(s.merchant, 'Cash spend');
    expect(s.category, 'Other');
  });

  test('returns 0 amount when no number present', () {
    final s = parse('chai with friends');
    expect(s.amountPaise, 0);
  });

  test('extracts leading digit in Milk 2L', () {
    final s = parse('Milk 2L');
    expect(s.amountPaise, 200);
  });
}
