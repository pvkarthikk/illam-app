import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/domain/payroll.dart';
import 'package:nm_flat/core/domain/salary_months.dart';
import 'package:nm_flat/core/domain/settlement_state.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';

final salaryStaffProvider = StreamProvider.family<StaffData?, String>(
  (ref, staffId) => ref.watch(salaryRepoProvider).watchStaff(staffId),
);

final salaryRulesProvider = StreamProvider.family<List<PayRuleRow>, String>(
  (ref, staffId) => ref.watch(salaryRepoProvider).watchRules(staffId),
);

final salaryAdjustmentsProvider =
    StreamProvider.family<List<PayAdjustmentRow>, String>(
      (ref, staffId) => ref.watch(salaryRepoProvider).watchAdjustments(staffId),
    );

final salaryAttemptsProvider =
    StreamProvider.family<List<SettlementAttemptRow>, String>(
      (ref, staffId) => ref.watch(salaryRepoProvider).watchAttempts(staffId),
    );

final salaryVisitsProvider = StreamProvider.family<List<Visit>, String>(
  (ref, staffId) => ref.watch(salaryRepoProvider).watchVisits(staffId),
);

final salaryLeavesProvider = StreamProvider.family<List<Leave>, String>(
  (ref, staffId) => ref.watch(salaryRepoProvider).watchLeaves(staffId),
);

final salaryExpenseProvider = StreamProvider.family<ExpenseRow?, String>(
  (ref, id) => ref.watch(salaryRepoProvider).watchExpense(id),
);

AttemptData attemptFromRow(SettlementAttemptRow r) {
  final rawPrev = r.prevTransferIds;
  final prev = rawPrev == null || rawPrev.isEmpty
      ? const <String>[]
      : [for (final e in jsonDecode(rawPrev) as List) '$e'];
  return AttemptData(
    id: r.id,
    kind: r.kind,
    refAttemptId: r.refAttemptId,
    amountPaise: r.amountPaise,
    method: r.method,
    netPaise: r.netPaise,
    deltaPaise: r.deltaPaise,
    prevTransferIds: prev,
    createdAt: r.createdAt,
    byMember: r.byMember,
    expenseId: r.expenseId,
  );
}

PayRulesData rulesFromRow(PayRuleRow r) => PayRulesData(
  effectiveMonth: r.effectiveMonth,
  workDays: PayRulesData.parseDays(r.workDays),
  type: PayType.values.byName(r.payType),
  ratePerHourPaise: r.ratePerHourPaise,
  roundingMin: r.roundingMin,
  minHoursPerVisit: r.minHoursPerVisit,
  amountPerMonthPaise: r.amountPerMonthPaise,
  paidLeavesPerMonth: r.paidLeavesPerMonth,
  createdAt: r.createdAt,
  id: r.id,
);

final workDaysProvider = Provider.family<List<int>?, (String, String)>((
  ref,
  arg,
) {
  final rows = ref.watch(salaryRulesProvider(arg.$1)).value;
  if (rows == null) return null;
  return workDaysForMonth([for (final r in rows) rulesFromRow(r)], arg.$2);
});

final settledMonthsProvider = StreamProvider.family<Set<String>, String>((
  ref,
  staffId,
) {
  return ref.watch(salaryRepoProvider).watchAttempts(staffId).map((rows) {
    final byMonth = <String, List<AttemptData>>{};
    for (final row in rows) {
      (byMonth[row.month] ??= []).add(attemptFromRow(row));
    }
    return {
      for (final entry in byMonth.entries)
        if (computeSettlement(entry.value).status != SettlementStatus.unsettled)
          entry.key,
    };
  });
});

final duplicateSalaryAttemptIdsProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(salaryRepoProvider).watchAllAttempts().map((rows) {
    final byKey = <(String, String), List<AttemptData>>{};
    for (final row in rows) {
      (byKey[(row.staffId, row.month)] ??= []).add(attemptFromRow(row));
    }
    return {
      for (final entry in byKey.entries)
        for (final dup in computeSettlement(entry.value).duplicates)
          if (dup.kind == 'settle') dup.id,
    };
  });
});

class SalaryView {
  const SalaryView({
    required this.staff,
    required this.months,
    required this.payroll,
    required this.settlement,
    required this.frozen,
    required this.differencePaise,
  });

  final StaffData staff;
  final List<String> months;
  final PayrollResult payroll;
  final SettlementState settlement;
  final PayrollResult? frozen;
  final int differencePaise;

  PayrollResult get shown => frozen ?? payroll;
}

SalaryView buildSalaryView({
  required StaffData staff,
  required String month,
  required String today,
  required List<PayRuleRow> rules,
  required List<PayAdjustmentRow> adjustments,
  required List<SettlementAttemptRow> attempts,
  required List<Visit> visits,
  required List<Leave> leaves,
}) {
  final months = salaryMonths(
    startDate: staff.startDate ?? today,
    endDate: staff.endDate,
    today: today,
  );
  final settlement = computeSettlement([
    for (final a in attempts)
      if (a.month == month) attemptFromRow(a),
  ]);
  final prev = prevMonth(month);
  final prevSettlement = computeSettlement([
    for (final a in attempts)
      if (a.month == prev) attemptFromRow(a),
  ]);
  final dropIds = {for (final d in prevSettlement.duplicates) d.id};
  final monthAdjustments = [
    for (final a in adjustments)
      if (a.month == month && !dropIds.contains(a.settlementAttemptId))
        PayAdj(a.kind, a.amountPaise, a.note),
  ];

  final payroll = computePayroll(
    PayrollInput(
      month: month,
      today: today,
      startDate: staff.startDate ?? today,
      endDate: staff.endDate,
      rules: [for (final r in rules) rulesFromRow(r)],
      visits: [
        for (final v in visits) PayVisit(v.date ?? '', v.inAt ?? 0, v.outAt),
      ],
      leaveDates: {
        for (final l in leaves)
          if (l.date != null) l.date!,
      },
      adjustments: monthAdjustments,
    ),
  );

  PayrollResult? frozen;
  final effectiveId = settlement.effective?.id;
  if (effectiveId != null) {
    for (final a in attempts) {
      if (a.id == effectiveId &&
          a.breakdownJson != null &&
          a.breakdownJson!.isNotEmpty) {
        final decoded = jsonDecode(a.breakdownJson!);
        if (decoded is Map) {
          frozen = PayrollResult.fromJson(Map<String, Object?>.from(decoded));
        }
        break;
      }
    }
  }

  return SalaryView(
    staff: staff,
    months: months,
    payroll: payroll,
    settlement: settlement,
    frozen: frozen,
    differencePaise: settlement.differencePaise(payroll.netRupees),
  );
}

final salaryViewProvider =
    Provider.family<AsyncValue<SalaryView>, (String, String)>((ref, arg) {
      final staffId = arg.$1;
      final month = arg.$2;
      final staffAsync = ref.watch(salaryStaffProvider(staffId));
      final rulesAsync = ref.watch(salaryRulesProvider(staffId));
      final adjAsync = ref.watch(salaryAdjustmentsProvider(staffId));
      final attemptsAsync = ref.watch(salaryAttemptsProvider(staffId));
      final rangeKey = (staffId, '$month-01', '$month-31');
      final visitsAsync = ref.watch(staffVisitsProvider(rangeKey));
      final leavesAsync = ref.watch(staffLeavesProvider(rangeKey));

      for (final a in <AsyncValue<Object?>>[
        staffAsync,
        rulesAsync,
        adjAsync,
        attemptsAsync,
        visitsAsync,
        leavesAsync,
      ]) {
        if (a.hasError) {
          return AsyncError(
            a.error!,
            a.stackTrace ?? StackTrace.current,
          );
        }
      }

      final staff = staffAsync.value;
      if (staff == null) {
        if (staffAsync.isLoading) return const AsyncLoading();
        return AsyncError(StateError('Staff not found'), StackTrace.current);
      }

      final rules = rulesAsync.value;
      final adjustments = adjAsync.value;
      final attempts = attemptsAsync.value;
      final visits = visitsAsync.value;
      final leaves = leavesAsync.value;
      if (rules == null ||
          adjustments == null ||
          attempts == null ||
          visits == null ||
          leaves == null) {
        return const AsyncLoading();
      }

      final today = ref.watch(todayDateProvider);
      return AsyncData(
        buildSalaryView(
          staff: staff,
          month: month,
          today: today,
          rules: rules,
          adjustments: adjustments,
          attempts: attempts,
          visits: visits,
          leaves: leaves,
        ),
      );
    });
