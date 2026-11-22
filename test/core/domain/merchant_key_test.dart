import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/merchant_key.dart';

void main() {
  test('merchantKey trims, lowercases, and collapses spaces', () {
    expect(merchantKey(' Big Basket '), 'big basket');
    expect(merchantKey('  Milk   Vendor\tCo '), 'milk vendor co');
  });
}
