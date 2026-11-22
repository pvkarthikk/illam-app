import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/todo_dates.dart';

void main() {
  const today = '2026-11-20'; // Friday

  test('todoGroup categorizes -1/0/+1/+3 days correctly', () {
    expect(todoGroup('2026-11-19', today), TodoGroup.overdue);
    expect(todoGroup('2026-11-20', today), TodoGroup.today);
    expect(todoGroup('2026-11-21', today), TodoGroup.tomorrow);
    expect(todoGroup('2026-11-23', today), TodoGroup.later);
  });

  test('whenDates computes today, tomorrow, weekend, nextWeek', () {
    final fri = whenDates('2026-11-20');
    expect(fri.today, '2026-11-20');
    expect(fri.tomorrow, '2026-11-21');
    expect(fri.weekend, '2026-11-21');
    expect(fri.nextWeek, '2026-11-27');

    final sat = whenDates('2026-11-21');
    expect(sat.weekend, '2026-11-28');

    final sun = whenDates('2026-11-22');
    expect(sun.weekend, '2026-11-28');
  });
}
