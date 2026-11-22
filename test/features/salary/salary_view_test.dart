import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';

StaffData _staff({String startDate = '2026-01-01'}) => StaffData(
  id: 'st-1',
  homeId: 'h-1',
  deleted: false,
  createdAt: 1,
  createdBy: 'm-1',
  updatedAt: 1,
  updatedBy: 'm-1',
  name: 'Lakshmi',
  workDays: '1,2,3,4,5,6',
  expectedTimes: '09:00',
  startDate: startDate,
  active: true,
);

PayRuleRow _hourlyRule() => const PayRuleRow(
  id: 'pr-1',
  homeId: 'h-1',
  deleted: false,
  createdAt: 1,
  createdBy: 'm-1',
  updatedAt: 1,
  updatedBy: 'm-1',
  staffId: 'st-1',
  effectiveMonth: '2026-01',
  workDays: '1,2,3,4,5,6',
  payType: 'hourly',
  ratePerHourPaise: 9000,
  roundingMin: 15,
  minHoursPerVisit: 1,
  amountPerMonthPaise: 0,
  paidLeavesPerMonth: 0,
);

Visit _visit(String id, int day, int inH, int inM, int outH, int outM) {
  final date = '2026-06-${day.toString().padLeft(2, '0')}';
  return Visit(
    id: id,
    homeId: 'h-1',
    deleted: false,
    createdAt: 1,
    createdBy: 'm-1',
    updatedAt: 1,
    updatedBy: 'm-1',
    staffId: 'st-1',
    date: date,
    inAt: DateTime(2026, 6, day, inH, inM).millisecondsSinceEpoch,
    outAt: DateTime(2026, 6, day, outH, outM).millisecondsSinceEpoch,
  );
}

SettlementAttemptRow _attempt({
  required String id,
  required String month,
  required String kind,
  int amountPaise = 0,
  int netPaise = 0,
  String? breakdownJson,
  int deltaPaise = 0,
  String? prevTransferIds,
  int createdAt = 100,
}) => SettlementAttemptRow(
  id: id,
  homeId: 'h-1',
  deleted: false,
  createdAt: createdAt,
  createdBy: 'm-1',
  updatedAt: createdAt,
  updatedBy: 'm-1',
  staffId: 'st-1',
  month: month,
  kind: kind,
  amountPaise: amountPaise,
  netPaise: netPaise,
  breakdownJson: breakdownJson,
  deltaPaise: deltaPaise,
  prevTransferIds: prevTransferIds,
  byMember: 'm-1',
);

PayAdjustmentRow _adj({
  required String id,
  required String month,
  required String kind,
  required int amountPaise,
  String note = 'Note',
  String? settlementAttemptId,
}) => PayAdjustmentRow(
  id: id,
  homeId: 'h-1',
  deleted: false,
  createdAt: 100,
  createdBy: 'm-1',
  updatedAt: 100,
  updatedBy: 'm-1',
  staffId: 'st-1',
  month: month,
  kind: kind,
  amountPaise: amountPaise,
  note: note,
  settlementAttemptId: settlementAttemptId,
);

void main() {
  test('settled June displays frozen ₹293 and reports +₹45 difference after 30 min edit', () {
    final staff = _staff();
    final rules = [_hourlyRule()];
    final initialVisits = [
      _visit('v1', 1, 9, 0, 11, 15),
      _visit('v2', 2, 9, 0, 9, 7),
    ];
    final initialView = buildSalaryView(
      staff: staff,
      month: '2026-06',
      today: '2026-07-05',
      rules: rules,
      adjustments: const [],
      attempts: const [],
      visits: initialVisits,
      leaves: const [],
    );
    expect(initialView.payroll.billedMinutes, 195);
    expect(initialView.payroll.netRupees, 293);

    final settledAttempt = _attempt(
      id: 'att-1',
      month: '2026-06',
      kind: 'settle',
      amountPaise: 29300,
      netPaise: 29300,
      breakdownJson: jsonEncode(initialView.payroll.toJson()),
    );
    final editedVisits = [
      _visit('v1', 1, 9, 0, 11, 45),
      _visit('v2', 2, 9, 0, 9, 7),
    ];
    final afterEdit = buildSalaryView(
      staff: staff,
      month: '2026-06',
      today: '2026-07-05',
      rules: rules,
      adjustments: const [],
      attempts: [settledAttempt],
      visits: editedVisits,
      leaves: const [],
    );
    expect(afterEdit.shown.netRupees, 293);
    expect(afterEdit.payroll.netRupees, 338);
    expect(afterEdit.differencePaise, 4500);
  });

  test('duplicate transfer carried adjustment is ignored in next month', () {
    final staff = _staff();
    final rules = [_hourlyRule()];
    final juneSettle = _attempt(
      id: 'att-1',
      month: '2026-06',
      kind: 'settle',
      amountPaise: 29300,
      netPaise: 29300,
      createdAt: 100,
    );
    final t1 = _attempt(
      id: 't1',
      month: '2026-06',
      kind: 'transfer',
      deltaPaise: 4500,
      prevTransferIds: '[]',
      createdAt: 200,
    );
    final t2Dup = _attempt(
      id: 't2',
      month: '2026-06',
      kind: 'transfer',
      deltaPaise: 4500,
      prevTransferIds: '[]',
      createdAt: 201,
    );

    final julyView = buildSalaryView(
      staff: staff,
      month: '2026-07',
      today: '2026-07-05',
      rules: rules,
      adjustments: [
        _adj(
          id: 'adj-1',
          month: '2026-07',
          kind: 'extra',
          amountPaise: 4500,
          note: 'Difference from June',
          settlementAttemptId: 't1',
        ),
        _adj(
          id: 'adj-2',
          month: '2026-07',
          kind: 'extra',
          amountPaise: 4500,
          note: 'Difference from June',
          settlementAttemptId: 't2',
        ),
      ],
      attempts: [juneSettle, t1, t2Dup],
      visits: const [],
      leaves: const [],
    );

    expect(julyView.payroll.extras.length, 1);
    expect(julyView.payroll.extras.single.amountPaise, 4500);
    expect(julyView.payroll.netPaise, 4500);
  });
}
