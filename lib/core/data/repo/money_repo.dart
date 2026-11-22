import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/undo.dart';
import 'package:nm_flat/core/data/repo/expenses_repo.dart';
import 'package:nm_flat/core/domain/bills.dart';
import 'package:nm_flat/core/domain/duplicate_hint.dart';
import 'package:nm_flat/core/domain/merchant_key.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/util/hash_id.dart';

class DuplicateHit {
  const DuplicateHit({
    this.whoFirstName,
    required this.amountPaise,
    required this.merchant,
    required this.date,
  });

  final String? whoFirstName;
  final int amountPaise;
  final String merchant;
  final String date;
}

class SpendEdit {
  const SpendEdit({
    required this.amountPaise,
    required this.merchant,
    required this.category,
    required this.method,
    required this.date,
    required this.paidBy,
    this.note,
  });

  final int amountPaise;
  final String merchant;
  final String category;
  final String method;
  final String date;
  final String paidBy;
  final String? note;
}

class BillDraft {
  const BillDraft({
    required this.name,
    required this.category,
    required this.usualAmountPaise,
    required this.dueDay,
    required this.method,
    required this.remind,
    required this.today,
  });

  final String name;
  final String category;
  final int usualAmountPaise;
  final int dueDay;
  final String method;
  final bool remind;
  final String today;
}

/// Returns expense IDs for salary rows linked to duplicate settlement attempts.
Set<String> duplicateSalaryExpenseIds(
  List<ExpenseRow> rows,
  Set<String> dupAttempts,
) => {
  for (final e in rows)
    if (e.source == 'salary' &&
        e.settlementAttemptId != null &&
        dupAttempts.contains(e.settlementAttemptId))
      e.id,
};

class MoneyRepo {
  MoneyRepo(this.db, this.changes, this.expenses, this.homeId, this.myMemberId);

  final NestDatabase db;
  final ChangeWriter changes;
  final ExpensesRepo expenses;
  final String homeId;
  final String myMemberId;

  Stream<List<ExpenseRow>> watchExpensesSince(String fromIso) =>
      (db.select(db.expenses)
            ..where(
              (e) =>
                  e.homeId.equals(homeId) &
                  e.deleted.equals(false) &
                  e.date.isBiggerOrEqualValue(fromIso),
            )
            ..orderBy([
              (e) => OrderingTerm.desc(e.date),
              (e) => OrderingTerm.desc(e.createdAt),
            ]))
          .watch();

  Stream<List<ExpenseRow>> watchExpensesInMonth(String month) =>
      (db.select(db.expenses)
            ..where(
              (e) =>
                  e.homeId.equals(homeId) &
                  e.deleted.equals(false) &
                  e.date.like('$month-%'),
            )
            ..orderBy([
              (e) => OrderingTerm.desc(e.date),
              (e) => OrderingTerm.desc(e.createdAt),
            ]))
          .watch();

  Stream<List<Bill>> watchBills() =>
      (db.select(db.bills)
            ..where((b) => b.homeId.equals(homeId) & b.deleted.equals(false))
            ..orderBy([
              (b) => OrderingTerm.asc(b.dueDay),
              (b) => OrderingTerm.asc(b.name),
            ]))
          .watch();

  Stream<Map<String, String>> watchMerchantRules() =>
      (db.select(db.merchantRules)..where(
            (r) => r.homeId.equals(homeId) & r.deleted.equals(false),
          ))
          .watch()
          .map(
            (rows) => {
              for (final r in rows)
                if (r.category.isNotEmpty) r.merchantKey: r.category,
            },
          );

  SpendLite toSpendLite(ExpenseRow e) => SpendLite(
    id: e.id,
    merchant: e.merchant,
    merchantKey: e.merchantKey,
    date: e.date,
    source: e.source,
    addedBy: e.addedBy,
    amountPaise: e.amountPaise,
    createdAt: e.createdAt,
    orderChannel: e.orderChannel,
    billId: e.billId,
    forMonth: e.forMonth,
    settlementAttemptId: e.settlementAttemptId,
    method: e.method,
  );

  Future<DuplicateHit?> checkDuplicate({
    required int amountPaise,
    required String merchant,
    String? orderChannel,
    required String date,
  }) async {
    final from = Dates.addDays(date, -1);
    final to = Dates.addDays(date, 1);
    final rows =
        await (db.select(db.expenses)..where(
              (e) =>
                  e.homeId.equals(homeId) &
                  e.deleted.equals(false) &
                  e.date.isBiggerOrEqualValue(from) &
                  e.date.isSmallerOrEqualValue(to),
            ))
            .get();

    final hit = findDuplicate(
      amountPaise: amountPaise,
      merchantKey: merchantKey(merchant),
      orderChannel: orderChannel,
      date: date,
      existing: [for (final r in rows) toSpendLite(r)],
    );
    if (hit == null) return null;

    String? whoFirstName;
    if (hit.addedBy != myMemberId) {
      final member = await (db.select(
        db.members,
      )..where((m) => m.id.equals(hit.addedBy))).getSingleOrNull();
      final first = member?.firstName;
      whoFirstName = (first == null || first.isEmpty) ? null : first;
    }

    return DuplicateHit(
      whoFirstName: whoFirstName,
      amountPaise: hit.amountPaise,
      merchant: hit.merchant,
      date: hit.date,
    );
  }

  void _learnRule(ChangeBuilder c, String merchant, String category) {
    final key = merchantKey(merchant);
    c.setAll('merchant_rules', sha1Hex(key), {
      'deleted': false,
      'merchant_key': key,
      'category': category,
    });
  }

  Future<ChangeResult> addSpend(
    NewExpense s, {
    bool learn = false,
    bool repeatMonthly = false,
  }) => changes.write('Add spend', (c) {
    if (repeatMonthly) {
      final month = s.date.substring(0, 7);
      final billId = c.create('bills', {
        'name': s.merchant,
        'category': s.category,
        'usual_amount_paise': s.amountPaise,
        'due_day': Dates.parse(s.date).day,
        'first_due_month': month,
        'method': s.method,
        'remind': true,
        'active': true,
      });
      expenses.createIn(
        c,
        NewExpense(
          amountPaise: s.amountPaise,
          merchant: s.merchant,
          category: s.category,
          method: s.method,
          date: s.date,
          source: 'bill',
          paidBy: s.paidBy,
          forMonth: month,
          billId: billId,
          orderChannel: s.orderChannel,
          staffId: s.staffId,
          settlementAttemptId: s.settlementAttemptId,
          note: s.note,
        ),
      );
    } else {
      expenses.createIn(c, s);
    }
    if (learn) {
      _learnRule(c, s.merchant, s.category);
    }
  }, homeId: homeId);

  Future<ChangeResult> editSpend(
    String id,
    SpendEdit e, {
    bool learn = false,
  }) => changes.write('Edit spend', (c) {
    c.setAll('expenses', id, {
      'amount_paise': e.amountPaise,
      'merchant': e.merchant,
      'merchant_key': merchantKey(e.merchant),
      'category': e.category,
      'method': e.method,
      'date': e.date,
      'paid_by': e.paidBy,
      'note': e.note,
    });
    if (learn) {
      _learnRule(c, e.merchant, e.category);
    }
  }, homeId: homeId);

  Future<ChangeResult> deleteSpend(String id) =>
      changes.write('Delete spend', (c) {
        c.delete('expenses', id);
      }, homeId: homeId);

  Future<ChangeResult> saveBill(BillDraft d, {String? id}) =>
      changes.write(id == null ? 'Add bill' : 'Edit bill', (c) {
        if (id == null) {
          c.create('bills', {
            'name': d.name,
            'category': d.category,
            'usual_amount_paise': d.usualAmountPaise,
            'due_day': d.dueDay,
            'first_due_month': firstDueMonthFor(d.dueDay, d.today),
            'method': d.method,
            'remind': d.remind,
            'active': true,
          });
        } else {
          c.setAll('bills', id, {
            'name': d.name,
            'category': d.category,
            'usual_amount_paise': d.usualAmountPaise,
            'due_day': d.dueDay,
            'method': d.method,
            'remind': d.remind,
          });
        }
      }, homeId: homeId);

  Future<ChangeResult> setBillActive(String id, bool active) =>
      changes.write('Bill status', (c) {
        c.set('bills', id, 'active', active);
      }, homeId: homeId);

  Future<ChangeResult> deleteBill(String id) =>
      changes.write('Delete bill', (c) {
        c.delete('bills', id);
      }, homeId: homeId);

  Future<ChangeResult> setBudget(int? paise) =>
      changes.write('Budget', (c) {
        c.set('homes', homeId, 'budget_monthly_paise', paise);
      }, homeId: homeId);

  Future<ChangeResult> markBillPaid({
    required Bill bill,
    required int amountPaise,
    required String method,
    required String date,
    required String forMonth,
  }) => changes.write('Bill paid', (c) {
    expenses.createIn(
      c,
      NewExpense(
        amountPaise: amountPaise,
        merchant: bill.name,
        category: bill.category,
        method: method,
        date: date,
        source: 'bill',
        billId: bill.id,
        forMonth: forMonth,
      ),
    );
    c.set('bills', bill.id, 'usual_amount_paise', amountPaise);
  }, homeId: homeId);
}
