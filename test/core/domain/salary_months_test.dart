import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/salary_months.dart';

void main() {
  test('salaryMonths returns start month through min(current, end)', () {
    expect(
      salaryMonths(startDate: '2026-08-15', today: '2026-11-05'),
      ['2026-08', '2026-09', '2026-10', '2026-11'],
    );
    final ended = salaryMonths(
      startDate: '2026-08-15',
      endDate: '2026-09-20',
      today: '2026-11-05',
    );
    expect(ended.last, '2026-09');
  });

  test('defaultSalaryMonth prefers unsettled previous month on days 1..10', () {
    const months = ['2026-08', '2026-09', '2026-10', '2026-11'];

    expect(
      defaultSalaryMonth(
        today: '2026-11-05',
        months: months,
        isSettled: (_) => false,
      ),
      '2026-10',
    );
    expect(
      defaultSalaryMonth(
        today: '2026-11-11',
        months: months,
        isSettled: (_) => false,
      ),
      '2026-11',
    );
    expect(
      defaultSalaryMonth(
        today: '2026-11-05',
        months: months,
        isSettled: (m) => m == '2026-10',
      ),
      '2026-11',
    );
    expect(
      defaultSalaryMonth(
        today: '2026-11-05',
        months: const ['2026-08', '2026-09'],
        isSettled: (_) => false,
      ),
      '2026-09',
    );
  });

  test('nextMonth and prevMonth wrap across year boundary', () {
    expect(nextMonth('2026-12'), '2027-01');
    expect(prevMonth('2026-01'), '2025-12');
  });
}
