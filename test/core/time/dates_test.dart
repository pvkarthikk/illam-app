import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/dates.dart';

void main() {
  test('Dates helpers handle calendar arithmetic and FixedClock', () {
    expect(Dates.addDays('2026-02-28', 1), '2026-03-01');
    expect(Dates.daysBetween('2026-11-20', '2026-11-18'), -2);
    expect(Dates.weekdayIso('2026-11-23'), 1);
    expect(Dates.daysInMonth('2028-02'), 29);
    expect(Dates.addMonths('2026-12', 1), '2027-01');
    expect(Dates.today(FixedClock(DateTime(2026, 11, 20, 9))), '2026-11-20');
  });
}
