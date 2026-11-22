import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/undo.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/repo/expenses_repo.dart';
import 'package:nm_flat/core/domain/payroll.dart';
import 'package:nm_flat/core/domain/salary_months.dart';

class SalaryRepo {
  SalaryRepo(this.db, this.changes, this.expenses, this.prefs);

  final NestDatabase db;
  final ChangeWriter changes;
  final ExpensesRepo expenses;
  final DevicePrefs prefs;

  String get _me => prefs.memberId ?? prefs.deviceId;

  Stream<List<PayRuleRow>> watchRules(String staffId) =>
      (db.select(db.payRules)..where(
            (r) => r.staffId.equals(staffId) & r.deleted.equals(false),
          ))
          .watch();

  Stream<List<PayAdjustmentRow>> watchAdjustments(String staffId) =>
      (db.select(db.payAdjustments)
            ..where((a) => a.staffId.equals(staffId) & a.deleted.equals(false))
            ..orderBy([
              (a) => OrderingTerm.asc(a.createdAt),
              (a) => OrderingTerm.asc(a.id),
            ]))
          .watch();

  Stream<List<SettlementAttemptRow>> watchAttempts(String staffId) =>
      (db.select(db.settlementAttempts)
            ..where((a) => a.staffId.equals(staffId) & a.deleted.equals(false))
            ..orderBy([
              (a) => OrderingTerm.asc(a.createdAt),
              (a) => OrderingTerm.asc(a.id),
            ]))
          .watch();

  Stream<List<SettlementAttemptRow>> watchAllAttempts() =>
      (db.select(db.settlementAttempts)
            ..where((a) => a.deleted.equals(false))
            ..orderBy([
              (a) => OrderingTerm.asc(a.createdAt),
              (a) => OrderingTerm.asc(a.id),
            ]))
          .watch();

  Stream<List<Visit>> watchVisits(String staffId) =>
      (db.select(db.visits)
            ..where((v) => v.staffId.equals(staffId) & v.deleted.equals(false))
            ..orderBy([(v) => OrderingTerm.asc(v.inAt)]))
          .watch();

  Stream<List<Leave>> watchLeaves(String staffId) =>
      (db.select(db.leaves)..where(
            (l) => l.staffId.equals(staffId) & l.deleted.equals(false),
          ))
          .watch();

  Stream<StaffData?> watchStaff(String staffId) =>
      (db.select(db.staff)..where(
            (s) => s.id.equals(staffId) & s.deleted.equals(false),
          ))
          .watchSingleOrNull();

  Stream<ExpenseRow?> watchExpense(String id) =>
      (db.select(db.expenses)..where(
            (e) => e.id.equals(id) & e.deleted.equals(false),
          ))
          .watchSingleOrNull();

  Future<ChangeResult> saveRules(
    String staffId,
    PayRulesData r, {
    required bool applyThisMonth,
  }) async {
    final existing =
        await (db.select(db.payRules)
              ..where(
                (row) =>
                    row.staffId.equals(staffId) &
                    row.effectiveMonth.equals(r.effectiveMonth) &
                    row.deleted.equals(false),
              )
              ..limit(1))
            .getSingleOrNull();

    final days = r.workDays.join(',');
    return changes.write('Pay rules', (c) {
      if (existing != null) {
        final updates = <String, Object?>{};
        if (existing.workDays != days) updates['work_days'] = days;
        if (existing.payType != r.type.name) updates['pay_type'] = r.type.name;
        if (existing.ratePerHourPaise != r.ratePerHourPaise) {
          updates['rate_per_hour_paise'] = r.ratePerHourPaise;
        }
        if (existing.roundingMin != r.roundingMin) {
          updates['rounding_min'] = r.roundingMin;
        }
        if (existing.minHoursPerVisit != r.minHoursPerVisit) {
          updates['min_hours_per_visit'] = r.minHoursPerVisit;
        }
        if (existing.amountPerMonthPaise != r.amountPerMonthPaise) {
          updates['amount_per_month_paise'] = r.amountPerMonthPaise;
        }
        if (existing.paidLeavesPerMonth != r.paidLeavesPerMonth) {
          updates['paid_leaves_per_month'] = r.paidLeavesPerMonth;
        }
        if (updates.isNotEmpty) {
          c.setAll('pay_rules', existing.id, updates);
        }
      } else {
        c.create('pay_rules', {
          'staff_id': staffId,
          'effective_month': r.effectiveMonth,
          'work_days': days,
          'pay_type': r.type.name,
          'rate_per_hour_paise': r.ratePerHourPaise,
          'rounding_min': r.roundingMin,
          'min_hours_per_visit': r.minHoursPerVisit,
          'amount_per_month_paise': r.amountPerMonthPaise,
          'paid_leaves_per_month': r.paidLeavesPerMonth,
        });
      }

      if (applyThisMonth) {
        c.set('staff', staffId, 'work_days', days);
      }
    });
  }

  Future<ChangeResult> addAdjustment(
    String staffId,
    String month,
    String kind,
    int amountPaise,
    String note,
  ) => changes.write('Adjustment', (c) {
    c.create('pay_adjustments', {
      'staff_id': staffId,
      'month': month,
      'kind': kind,
      'amount_paise': amountPaise,
      'note': note,
    });
  });

  Future<ChangeResult> removeAdjustment(String id) =>
      changes.write('Adjustment', (c) => c.delete('pay_adjustments', id));

  Future<ChangeResult> markPaid({
    required String staffId,
    required String month,
    required PayrollResult r,
    required String method,
    required String merchantText,
    required String today,
    String? date,
  }) => changes.write('Salary paid', (c) {
    final attemptId = c.create('settlement_attempts', {
      'staff_id': staffId,
      'month': month,
      'kind': 'settle',
      'amount_paise': r.toPayRupees * 100,
      'method': method,
      'net_paise': r.netRupees * 100,
      'breakdown_json': jsonEncode(r.toJson()),
      'by_member': _me,
    });
    final expenseId = expenses.createIn(
      c,
      NewExpense(
        amountPaise: r.toPayRupees * 100,
        merchant: merchantText,
        category: 'Staff',
        method: method,
        date: date ?? today,
        source: 'salary',
        forMonth: month,
        staffId: staffId,
        settlementAttemptId: attemptId,
      ),
    );
    c.set('settlement_attempts', attemptId, 'expense_id', expenseId);
  });

  Future<ChangeResult> closeAtZero({
    required String staffId,
    required String month,
    required PayrollResult r,
    required String carryNote,
  }) => changes.write('Salary closed', (c) {
    final attemptId = c.create('settlement_attempts', {
      'staff_id': staffId,
      'month': month,
      'kind': 'settle',
      'amount_paise': 0,
      'method': null,
      'net_paise': r.netRupees * 100,
      'breakdown_json': jsonEncode(r.toJson()),
      'by_member': _me,
    });
    if (r.carryRupees > 0) {
      c.create('pay_adjustments', {
        'staff_id': staffId,
        'month': nextMonth(month),
        'kind': 'advance',
        'amount_paise': r.carryRupees * 100,
        'note': carryNote,
        'settlement_attempt_id': attemptId,
      });
    }
  });

  Future<ChangeResult> undoPayment(SettlementAttemptRow attempt) async {
    final linkedAdjustments =
        await (db.select(db.payAdjustments)..where(
              (a) =>
                  a.settlementAttemptId.equals(attempt.id) &
                  a.deleted.equals(false),
            ))
            .get();

    return changes.write('Payment undone', (c) {
      c.create('settlement_attempts', {
        'staff_id': attempt.staffId,
        'month': attempt.month,
        'kind': 'reverse',
        'ref_attempt_id': attempt.id,
        'by_member': _me,
      });
      if (attempt.expenseId != null) {
        c.delete('expenses', attempt.expenseId!);
      }
      for (final adj in linkedAdjustments) {
        c.delete('pay_adjustments', adj.id);
      }
    });
  }

  Future<ChangeResult> transferDifference({
    required String staffId,
    required String month,
    required int deltaPaise,
    required List<String> effectiveTransferIds,
    required String note,
  }) => changes.write('Salary difference', (c) {
    final attemptId = c.create('settlement_attempts', {
      'staff_id': staffId,
      'month': month,
      'kind': 'transfer',
      'delta_paise': deltaPaise,
      'prev_transfer_ids': jsonEncode(effectiveTransferIds),
      'by_member': _me,
    });
    c.create('pay_adjustments', {
      'staff_id': staffId,
      'month': nextMonth(month),
      'kind': deltaPaise > 0 ? 'extra' : 'deduction',
      'amount_paise': deltaPaise.abs(),
      'note': note,
      'settlement_attempt_id': attemptId,
    });
  });
}
