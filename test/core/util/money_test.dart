import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/util/money.dart';

void main() {
  test('Money.format formats whole rupees with Indian grouping', () {
    expect(Money.format(0), '₹0');
    expect(Money.format(12345600), '₹1,23,456');
    expect(Money.format(29250), '₹293');
    expect(Money.format(-750), '\u2212₹8');
    expect(Money.format(100000000), '₹10,00,000');
  });

  test('Money.formatPaise always includes two decimal places', () {
    expect(Money.formatPaise(9950), '₹99.50');
    expect(Money.formatPaise(29250), '₹292.50');
  });

  test('Money.parseRupees parses valid inputs and rejects invalid ones', () {
    expect(Money.parseRupees('123'), 12300);
    expect(Money.parseRupees('1,234.5'), 123450);
    expect(Money.parseRupees('99.50'), 9950);
    expect(Money.parseRupees('₹ 99.50'), 9950);
    expect(Money.parseRupees(''), isNull);
    expect(Money.parseRupees('-5'), isNull);
    expect(Money.parseRupees('abc'), isNull);
    expect(Money.parseRupees('1.234'), isNull);
  });
}
