import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nm_flat/core/domain/payroll.dart';
import 'package:nm_flat/features/salary/pay_slip.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

int _t(int year, int month, int day, int hour, int minute) =>
    DateTime(year, month, day, hour, minute).millisecondsSinceEpoch;

String _iso(int year, int month, int day) =>
    '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUpAll(() => initializeDateFormatting('en'));

  test('formats hourly vector (f) pay slip', () {
    const rule = PayRulesData(
      effectiveMonth: '2026-01',
      workDays: [1, 2, 3, 4, 5, 6],
      type: PayType.hourly,
      ratePerHourPaise: 9000,
      roundingMin: 15,
      minHoursPerVisit: 1,
    );
    final res = computePayroll(
      PayrollInput(
        month: '2026-06',
        today: '2026-07-15',
        startDate: '2026-01-01',
        rules: const [rule],
        visits: [
          PayVisit('2026-06-01', _t(2026, 6, 1, 9, 0), _t(2026, 6, 1, 11, 15)),
          PayVisit('2026-06-02', _t(2026, 6, 2, 9, 0), _t(2026, 6, 2, 9, 7)),
        ],
        leaveDates: const {},
        adjustments: const [
          PayAdj('extra', 20000, 'Balcony deep clean'),
          PayAdj('advance', 50000, 'Advance'),
        ],
      ),
    );

    expect(
      buildPaySlip(
        l10n,
        PaySlipData(month: '2026-06', name: 'Lakshmi', r: res),
      ),
      'June pay — Lakshmi\n'
      'Days: 2 · Hours: 3h 15m\n'
      '3h 15m × ₹90 = ₹293\n'
      '+ Balcony deep clean: ₹200\n'
      '− Advance: ₹500\n'
      'Total: −₹8',
    );
  });

  test('formats monthly February 2026 pay slip', () {
    const rule = PayRulesData(
      effectiveMonth: '2026-01',
      workDays: [1, 2, 3, 4, 5, 6],
      type: PayType.monthly,
      amountPerMonthPaise: 700000,
      paidLeavesPerMonth: 2,
    );
    final visits = <PayVisit>[
      for (var d = 1; d <= 28; d++)
        if (DateTime.utc(2026, 2, d).weekday != DateTime.sunday &&
            d != 2 &&
            d != 3 &&
            d != 4)
          PayVisit(
            _iso(2026, 2, d),
            _t(2026, 2, d, 9, 0),
            _t(2026, 2, d, 11, 0),
          ),
    ];
    final res = computePayroll(
      PayrollInput(
        month: '2026-02',
        today: '2026-03-15',
        startDate: '2026-01-01',
        rules: const [rule],
        visits: visits,
        leaveDates: const {},
        adjustments: const [],
      ),
    );

    expect(
      buildPaySlip(
        l10n,
        PaySlipData(month: '2026-02', name: 'Selvi', r: res),
      ),
      'February pay — Selvi\n'
      'Salary: ₹7,000\n'
      'Leaves: 3 (2 paid)\n'
      'Total: ₹6,708',
    );
  });

  test('includes marked paid leave days in monthly pay slip total and paid count', () {
    const rule = PayRulesData(
      effectiveMonth: '2026-01',
      workDays: [1, 2, 3, 4, 5, 6],
      type: PayType.monthly,
      amountPerMonthPaise: 700000,
      paidLeavesPerMonth: 2,
    );
    final visits = <PayVisit>[
      for (var d = 1; d <= 28; d++)
        if (DateTime.utc(2026, 2, d).weekday != DateTime.sunday &&
            !<int>{2, 3, 4, 5, 6}.contains(d))
          PayVisit(
            _iso(2026, 2, d),
            _t(2026, 2, d, 9, 0),
            _t(2026, 2, d, 11, 0),
          ),
    ];
    final res = computePayroll(
      PayrollInput(
        month: '2026-02',
        today: '2026-03-15',
        startDate: '2026-01-01',
        rules: const [rule],
        visits: visits,
        leaveDates: const {},
        paidLeaveDates: const {'2026-02-02', '2026-02-03'},
        adjustments: const [],
      ),
    );

    expect(
      buildPaySlip(
        l10n,
        PaySlipData(month: '2026-02', name: 'Selvi', r: res),
      ),
      'February pay — Selvi\n'
      'Salary: ₹7,000\n'
      'Leaves: 5 (4 paid)\n'
      'Total: ₹6,708',
    );
  });
}
