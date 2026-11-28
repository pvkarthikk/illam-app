import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/payroll.dart';

int _t(int day, int hour, int minute, {int year = 2026, int month = 6}) =>
    DateTime(year, month, day, hour, minute).millisecondsSinceEpoch;

String _iso(int day, {int year = 2026, int month = 6}) =>
    '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

PayRulesData _hourlyRule({
  String effectiveMonth = '2026-01',
  List<int> workDays = const [1, 2, 3, 4, 5, 6],
  int ratePerHourPaise = 9000,
  int roundingMin = 1,
  int minHoursPerVisit = 0,
}) => PayRulesData(
  effectiveMonth: effectiveMonth,
  workDays: workDays,
  type: PayType.hourly,
  ratePerHourPaise: ratePerHourPaise,
  roundingMin: roundingMin,
  minHoursPerVisit: minHoursPerVisit,
);

PayRulesData _monthlyRule({
  String effectiveMonth = '2026-01',
  List<int> workDays = const [1, 2, 3, 4, 5, 6],
  int amountPerMonthPaise = 700000,
  int paidLeavesPerMonth = 2,
}) => PayRulesData(
  effectiveMonth: effectiveMonth,
  workDays: workDays,
  type: PayType.monthly,
  amountPerMonthPaise: amountPerMonthPaise,
  paidLeavesPerMonth: paidLeavesPerMonth,
);

List<PayVisit> _workDayVisits({
  required int year,
  required int month,
  required int daysInMonth,
  required Set<int> skipDays,
}) {
  final out = <PayVisit>[];
  for (var d = 1; d <= daysInMonth; d++) {
    final dt = DateTime.utc(year, month, d);
    if (dt.weekday == DateTime.sunday || skipDays.contains(d)) continue;
    out.add(PayVisit(_iso(d, year: year, month: month), _t(d, 9, 0, year: year, month: month), _t(d, 11, 0, year: year, month: month)));
  }
  return out;
}

void main() {
  group('roundHalfUp and JSON', () {
    test('rounding vectors', () {
      expect(roundHalfUp(1755000, 6000), 293);
      expect(roundHalfUpSigned(-45000, 6000), -8);
      expect(roundHalfUp(142, 15), 9);
    });

    test('PayrollResult toJson/fromJson round-trip', () {
      final result = PayrollResult(
        rules: _hourlyRule(roundingMin: 15, minHoursPerVisit: 1),
        presentDays: 2,
        visitCount: 2,
        actualMinutes: 142,
        billedMinutes: 195,
        workDaysInMonth: 26,
        eligibleWorkDays: 26,
        grossPaise: 29250,
        netPaise: 49250,
        netRupees: 493,
        toPayRupees: 493,
        extras: const [PayAdj('extra', 20000, 'Balcony deep clean')],
      );
      final encoded = jsonEncode(result.toJson());
      final decoded = PayrollResult.fromJson(
        jsonDecode(encoded) as Map<String, Object?>,
      );
      expect(decoded.toJson(), result.toJson());
    });
  });

  group('computePayroll part 1 (rules, days, minutes)', () {
    test('merges overlapping visits and handles exact minute rounding', () {
      final res = computePayroll(
        PayrollInput(
          month: '2026-06',
          today: '2026-07-15',
          startDate: '2026-01-01',
          rules: [_hourlyRule(roundingMin: 1, minHoursPerVisit: 0)],
          visits: [
            PayVisit('2026-06-01', _t(1, 9, 0), _t(1, 11, 0)),
            PayVisit('2026-06-01', _t(1, 10, 30), _t(1, 12, 0)),
          ],
          leaveDates: const {},
          adjustments: const [],
        ),
      );
      expect(res.visitCount, 1);
      expect(res.actualMinutes, 180);
      expect(res.billedMinutes, 180);
    });

    test('rounds 142 minutes down to 135 with 15-min rounding', () {
      final res = computePayroll(
        PayrollInput(
          month: '2026-06',
          today: '2026-07-15',
          startDate: '2026-01-01',
          rules: [_hourlyRule(roundingMin: 15)],
          visits: [
            PayVisit('2026-06-01', _t(1, 9, 0), _t(1, 11, 22)),
          ],
          leaveDates: const {},
          adjustments: const [],
        ),
      );
      expect(res.billedMinutes, 135);
    });

    test('rounds 44 minutes to 30 with 30-min rounding and 0 min hours', () {
      final res = computePayroll(
        PayrollInput(
          month: '2026-06',
          today: '2026-07-15',
          startDate: '2026-01-01',
          rules: [_hourlyRule(roundingMin: 30, minHoursPerVisit: 0)],
          visits: [
            PayVisit('2026-06-01', _t(1, 9, 0), _t(1, 9, 44)),
          ],
          leaveDates: const {},
          adjustments: const [],
        ),
      );
      expect(res.billedMinutes, 30);
    });

    test('applies min 1 hour per visit with 15-min rounding', () {
      final res = computePayroll(
        PayrollInput(
          month: '2026-06',
          today: '2026-07-15',
          startDate: '2026-01-01',
          rules: [_hourlyRule(roundingMin: 15, minHoursPerVisit: 1)],
          visits: [
            PayVisit('2026-06-01', _t(1, 9, 0), _t(1, 11, 15)),
            PayVisit('2026-06-02', _t(2, 9, 0), _t(2, 9, 7)),
          ],
          leaveDates: const {},
          adjustments: const [],
        ),
      );
      expect(res.billedMinutes, 195);
    });

    test('counts absent, leave, and present days in monthly schedule', () {
      final visits = _workDayVisits(
        year: 2026,
        month: 6,
        daysInMonth: 30,
        skipDays: {2, 3, 4, 5},
      );
      final res = computePayroll(
        PayrollInput(
          month: '2026-06',
          today: '2026-07-15',
          startDate: '2026-01-01',
          rules: [_monthlyRule()],
          visits: visits,
          leaveDates: const {'2026-06-05'},
          adjustments: const [],
        ),
      );
      expect(res.absentDays, 3);
      expect(res.leaveDays, 1);
      expect(res.presentDays, 22);
    });

    test('visit beats leave on same date', () {
      final res = computePayroll(
        PayrollInput(
          month: '2026-06',
          today: '2026-07-15',
          startDate: '2026-01-01',
          rules: [_hourlyRule()],
          visits: [
            PayVisit('2026-06-01', _t(1, 9, 0), _t(1, 10, 0)),
          ],
          leaveDates: const {'2026-06-01'},
          adjustments: const [],
        ),
      );
      expect(res.presentDays, 1);
      expect(res.leaveDays, 0);
    });

    test('open visit counts day present with visitCount 0', () {
      final res = computePayroll(
        PayrollInput(
          month: '2026-06',
          today: '2026-07-15',
          startDate: '2026-01-01',
          rules: [_hourlyRule()],
          visits: [PayVisit('2026-06-01', _t(1, 9, 0))],
          leaveDates: const {},
          adjustments: const [],
        ),
      );
      expect(res.presentDays, 1);
      expect(res.visitCount, 0);
    });

    test('picks latest effectiveMonth <= M', () {
      final rMay = _hourlyRule(effectiveMonth: '2026-05', ratePerHourPaise: 9000);
      final rJul = _hourlyRule(effectiveMonth: '2026-07', ratePerHourPaise: 12000);
      final res = computePayroll(
        PayrollInput(
          month: '2026-06',
          today: '2026-07-15',
          startDate: '2026-01-01',
          rules: [rMay, rJul],
          visits: const [],
          leaveDates: const {},
          adjustments: const [],
        ),
      );
      expect(res.rules?.effectiveMonth, '2026-05');
      expect(res.rules?.ratePerHourPaise, 9000);
    });

    test('handles future startDate (notWorking) and empty rules (noRules)', () {
      final notWorking = computePayroll(
        PayrollInput(
          month: '2026-06',
          today: '2026-07-15',
          startDate: '2026-07-01',
          rules: [_hourlyRule()],
          visits: const [],
          leaveDates: const {},
          adjustments: const [],
        ),
      );
      expect(notWorking.notWorking, isTrue);

      final noRules = computePayroll(
        const PayrollInput(
          month: '2026-06',
          today: '2026-07-15',
          startDate: '2026-01-01',
          rules: [],
          visits: [],
          leaveDates: {},
          adjustments: [],
        ),
      );
      expect(noRules.noRules, isTrue);
    });
  });

  group('computePayroll part 2 (money & vectors)', () {
    test('hourly ₹90 vector gives grossPaise 29250 and netRupees 293', () {
      final res = computePayroll(
        PayrollInput(
          month: '2026-06',
          today: '2026-07-15',
          startDate: '2026-01-01',
          rules: [_hourlyRule(roundingMin: 15, minHoursPerVisit: 1)],
          visits: [
            PayVisit('2026-06-01', _t(1, 9, 0), _t(1, 11, 15)),
            PayVisit('2026-06-02', _t(2, 9, 0), _t(2, 9, 7)),
          ],
          leaveDates: const {},
          adjustments: const [],
        ),
      );
      expect(res.billedMinutes, 195);
      expect(res.grossPaise, 29250);
      expect(res.netRupees, 293);
      expect(res.toPayRupees, 293);
    });

    test('(d) monthly ₹7,000 with 2 absences within 2 paid leaves', () {
      final visits = _workDayVisits(
        year: 2026,
        month: 6,
        daysInMonth: 30,
        skipDays: {2, 3},
      );
      final res = computePayroll(
        PayrollInput(
          month: '2026-06',
          today: '2026-07-15',
          startDate: '2026-01-01',
          rules: [_monthlyRule()],
          visits: visits,
          leaveDates: const {},
          adjustments: const [],
        ),
      );
      expect(res.unpaidDays, 0);
      expect(res.netRupees, 7000);
    });

    test('(e) monthly ₹7,000 with 3 absent + 1 leave -> 2 unpaid -> 6462', () {
      final visits = _workDayVisits(
        year: 2026,
        month: 6,
        daysInMonth: 30,
        skipDays: {2, 3, 4, 5},
      );
      final res = computePayroll(
        PayrollInput(
          month: '2026-06',
          today: '2026-07-15',
          startDate: '2026-01-01',
          rules: [_monthlyRule()],
          visits: visits,
          leaveDates: const {'2026-06-05'},
          adjustments: const [],
        ),
      );
      expect(res.absentDays, 3);
      expect(res.leaveDays, 1);
      expect(res.unpaidDays, 2);
      expect(res.netRupees, 6462);
    });

    test('(f) hourly ₹90 + extra 200 - advance 500 -> carry 8', () {
      final res = computePayroll(
        PayrollInput(
          month: '2026-06',
          today: '2026-07-15',
          startDate: '2026-01-01',
          rules: [_hourlyRule(roundingMin: 15, minHoursPerVisit: 1)],
          visits: [
            PayVisit('2026-06-01', _t(1, 9, 0), _t(1, 11, 15)),
            PayVisit('2026-06-02', _t(2, 9, 0), _t(2, 9, 7)),
          ],
          leaveDates: const {},
          adjustments: const [
            PayAdj('extra', 20000, 'Balcony deep clean'),
            PayAdj('advance', 50000, 'Advance'),
          ],
        ),
      );
      expect(res.netRupees, -8);
      expect(res.toPayRupees, 0);
      expect(res.carryRupees, 8);
    });

    test('(g) partial month starting 2026-06-20 prorates leaves & salary', () {
      final visits = <PayVisit>[
        for (var d = 20; d <= 30; d++)
          if (DateTime.utc(2026, 6, d).weekday != DateTime.sunday)
            PayVisit(_iso(d), _t(d, 9, 0), _t(d, 11, 0)),
      ];
      final res = computePayroll(
        PayrollInput(
          month: '2026-06',
          today: '2026-07-15',
          startDate: '2026-06-20',
          rules: [_monthlyRule()],
          visits: visits,
          leaveDates: const {},
          adjustments: const [],
        ),
      );
      expect(res.eligibleWorkDays, 9);
      expect(res.unpaidDays, 0);
      expect(res.netRupees, 2423);
    });

    test('February 2026 vector gives 24 work days, 1 unpaid, 6708 netRupees', () {
      final visits = _workDayVisits(
        year: 2026,
        month: 2,
        daysInMonth: 28,
        skipDays: {2, 3, 4},
      );
      final res = computePayroll(
        PayrollInput(
          month: '2026-02',
          today: '2026-03-15',
          startDate: '2026-01-01',
          rules: [_monthlyRule()],
          visits: visits,
          leaveDates: const {},
          adjustments: const [],
        ),
      );
      expect(res.workDaysInMonth, 24);
      expect(res.unpaidDays, 1);
      expect(res.netRupees, 6708);
    });

    test('deduction lowers netPaise by exact amount', () {
      final base = computePayroll(
        PayrollInput(
          month: '2026-06',
          today: '2026-07-15',
          startDate: '2026-01-01',
          rules: [_hourlyRule()],
          visits: [PayVisit('2026-06-01', _t(1, 9, 0), _t(1, 10, 0))],
          leaveDates: const {},
          adjustments: const [],
        ),
      );
      final withDed = computePayroll(
        PayrollInput(
          month: '2026-06',
          today: '2026-07-15',
          startDate: '2026-01-01',
          rules: [_hourlyRule()],
          visits: [PayVisit('2026-06-01', _t(1, 9, 0), _t(1, 10, 0))],
          leaveDates: const {},
          adjustments: const [PayAdj('deduction', 1000, 'Broken cup')],
        ),
      );
      expect(base.netPaise - withDed.netPaise, 1000);
    });

    test('monthly with empty workDays yields grossPaise 0', () {
      final res = computePayroll(
        PayrollInput(
          month: '2026-06',
          today: '2026-07-15',
          startDate: '2026-01-01',
          rules: [_monthlyRule(workDays: const [])],
          visits: const [],
          leaveDates: const {},
          adjustments: const [],
        ),
      );
      expect(res.grossPaise, 0);
    });

    test('marked paidLeaveDates are not deducted and preserve paidLeavesPerMonth allowance', () {
      // Feb 2026 has 24 Mon-Sat work days. Skip days 2,3 (paidLeaveDates),
      // 4,5 (informed leaves) with 2/mo allowance -> 0 unpaid days.
      final visits = _workDayVisits(
        year: 2026,
        month: 2,
        daysInMonth: 28,
        skipDays: {2, 3, 4, 5},
      );
      final res = computePayroll(
        PayrollInput(
          month: '2026-02',
          today: '2026-03-15',
          startDate: '2026-01-01',
          rules: [_monthlyRule(amountPerMonthPaise: 700000, paidLeavesPerMonth: 2)],
          visits: visits,
          leaveDates: const {'2026-02-04', '2026-02-05'},
          paidLeaveDates: const {'2026-02-02', '2026-02-03'},
          adjustments: const [],
        ),
      );
      expect(res.presentDays, 20);
      expect(res.paidLeaveDays, 2);
      expect(res.leaveDays, 2);
      expect(res.absentDays, 0);
      expect(res.unpaidDays, 0);
      expect(res.leaveDeductionPaise, 0);
      expect(res.netRupees, 7000);

      // Even with 0 monthly paid-leave quota, explicit paidLeaveDates remain paid.
      final zeroQuota = computePayroll(
        PayrollInput(
          month: '2026-02',
          today: '2026-03-15',
          startDate: '2026-01-01',
          rules: [_monthlyRule(amountPerMonthPaise: 700000, paidLeavesPerMonth: 0)],
          visits: visits,
          leaveDates: const {'2026-02-04', '2026-02-05'},
          paidLeaveDates: const {'2026-02-02', '2026-02-03'},
          adjustments: const [],
        ),
      );
      expect(zeroQuota.paidLeaveDays, 2);
      expect(zeroQuota.unpaidDays, 2);

      // Present visit on same date takes priority over paidLeaveDates, and legacy JSON defaults paidLeaveDays to 0.
      final workedOverride = computePayroll(
        PayrollInput(
          month: '2026-02',
          today: '2026-03-15',
          startDate: '2026-01-01',
          rules: [_monthlyRule(amountPerMonthPaise: 700000, paidLeavesPerMonth: 0)],
          visits: _workDayVisits(year: 2026, month: 2, daysInMonth: 28, skipDays: const {}),
          leaveDates: const {},
          paidLeaveDates: const {'2026-02-02'},
          adjustments: const [],
        ),
      );
      expect(workedOverride.presentDays, 24);
      expect(workedOverride.paidLeaveDays, 0);

      final jsonMap = res.toJson();
      expect(PayrollResult.fromJson(jsonMap).paidLeaveDays, 2);
      jsonMap.remove('paidLeaveDays');
      expect(PayrollResult.fromJson(jsonMap).paidLeaveDays, 0);
    });
  });
}
