import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nm_flat/core/domain/staff_text.dart';

void main() {
  setUpAll(() => initializeDateFormatting('en'));

  const short = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  test('daysText collapses runs of 3+ days', () {
    expect(daysText([1, 2, 3, 4, 5, 6], short: short, daily: 'Daily'), 'Mon–Sat');
    expect(
      daysText([1, 2, 3, 4, 5, 6, 7], short: short, daily: 'Daily'),
      'Daily',
    );
    expect(daysText([1, 3, 5], short: short, daily: 'Daily'), 'Mon, Wed, Fri');
    expect(
      daysText([1, 2, 3, 5], short: short, daily: 'Daily'),
      'Mon–Wed, Fri',
    );
  });

  test('timesText formats windows and multiple times', () {
    expect(timesText(['09:00'], '11:30'), '9:00–11:30 AM');
    expect(timesText(['11:00'], '13:00'), '11:00 AM–1:00 PM');
    expect(timesText(['07:30', '18:00'], null), '7:30 AM & 6:00 PM');
  });

  test('IndianMobile validates, formats display and waDigits', () {
    expect(IndianMobile.toE164('98765 43210'), '+919876543210');
    expect(IndianMobile.toE164('+91 98765-43210'), '+919876543210');
    expect(IndianMobile.toE164('919876543210'), '+919876543210');
    expect(IndianMobile.toE164('5876543210'), isNull);
    expect(IndianMobile.toE164('12345'), isNull);
    expect(IndianMobile.display('+919876543210'), '+91 98765 43210');
    expect(IndianMobile.waDigits('+919876543210'), '919876543210');
  });
}
