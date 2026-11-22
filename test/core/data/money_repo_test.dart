import 'package:drift/drift.dart' show OrderingTerm, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/repo/expenses_repo.dart';
import 'package:nm_flat/core/data/repo/money_repo.dart';
import 'package:nm_flat/core/domain/spend_category.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';

typedef _Env = ({
  NestDatabase db,
  ChangeWriter changes,
  ExpensesRepo expenses,
  MoneyRepo repo,
  String me,
});

Future<_Env> _env() async {
  final db = NestDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final prefs = await DevicePrefs.inMemory();
  await prefs.setCurrentHomeId('home1');
  await prefs.setMemberId('mem-1');
  final me = prefs.memberId ?? prefs.deviceId;
  final clock = FixedClock(DateTime(2026, 11, 20, 9, 0));
  final changes = ChangeWriter(
    db,
    CollectionRegistry.build(db),
    HlcClock(clock, prefs),
    prefs,
  );
  await changes.write('Seed member', (c) {
    c.create('members', {
      'full_name': 'Priya Anand',
      'first_name': 'Priya',
      'role': 'admin',
      'status': 'active',
    }, id: 'demo-priya');
  }, homeId: 'home1');
  final expenses = ExpensesRepo(db, prefs);
  final repo = MoneyRepo(db, changes, expenses, 'home1', me);
  return (
    db: db,
    changes: changes,
    expenses: expenses,
    repo: repo,
    me: me,
  );
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  test('learning category rule overrides guessSpendCategory', () async {
    final e = await _env();
    await e.repo.addSpend(
      const NewExpense(
        amountPaise: 62400,
        merchant: 'Swiggy',
        category: 'Eating out',
        method: 'upi',
        date: '2026-11-20',
        source: 'manual',
      ),
    );
    final row = await e.db.select(e.db.expenses).getSingle();

    await e.repo.editSpend(
      row.id,
      SpendEdit(
        amountPaise: row.amountPaise,
        merchant: row.merchant,
        category: 'Groceries',
        method: row.method,
        date: row.date,
        paidBy: row.paidBy,
      ),
      learn: true,
    );

    final rules = await e.repo.watchMerchantRules().first;
    expect(guessSpendCategory('Swiggy', rules), 'Groceries');
  });

  test('editSpend keeps source and added_by unchanged', () async {
    final e = await _env();
    await e.repo.addSpend(
      const NewExpense(
        amountPaise: 50000,
        merchant: 'D-Mart',
        category: 'Groceries',
        method: 'upi',
        date: '2026-11-20',
        source: 'store',
      ),
    );
    final row = await e.db.select(e.db.expenses).getSingle();
    await e.changes.write('Set owner', (c) {
      c.set('expenses', row.id, 'added_by', 'demo-priya');
    }, homeId: 'home1');

    await e.repo.editSpend(
      row.id,
      const SpendEdit(
        amountPaise: 55000,
        merchant: 'D-Mart',
        category: 'Groceries',
        method: 'card',
        date: '2026-11-20',
        paidBy: 'demo-priya',
        note: 'Weekly haul',
      ),
    );

    final updated = await e.db.select(e.db.expenses).getSingle();
    expect(updated.source, 'store');
    expect(updated.addedBy, 'demo-priya');
    expect(updated.amountPaise, 55000);
  });

  test('markBillPaid updates usual amount and undo restores both', () async {
    final e = await _env();
    await e.repo.saveBill(
      const BillDraft(
        name: 'Electricity (BESCOM)',
        category: 'Utilities',
        usualAmountPaise: 198000,
        dueDay: 5,
        method: 'upi',
        remind: true,
        today: '2026-11-01',
      ),
    );
    final bill = await e.db.select(e.db.bills).getSingle();

    final res = await e.repo.markBillPaid(
      bill: bill,
      amountPaise: 214000,
      method: 'upi',
      date: '2026-11-20',
      forMonth: '2026-11',
    );

    final afterBill = await e.db.select(e.db.bills).getSingle();
    final expenses = await (e.db.select(
      e.db.expenses,
    )..where((x) => x.deleted.equals(false))).get();
    expect(afterBill.usualAmountPaise, 214000);
    expect(expenses.length, 1);
    expect(expenses.single.source, 'bill');
    expect(expenses.single.billId, bill.id);

    await res.undo!.run();

    final undoneBill = await e.db.select(e.db.bills).getSingle();
    final undoneExpenses = await (e.db.select(
      e.db.expenses,
    )..where((x) => x.deleted.equals(false))).get();
    expect(undoneBill.usualAmountPaise, 198000);
    expect(undoneExpenses, isEmpty);
  });

  test('checkDuplicate returns Priya or null when added by me', () async {
    final e = await _env();
    await e.repo.addSpend(
      const NewExpense(
        amountPaise: 48600,
        merchant: 'Zepto',
        category: 'Groceries',
        method: 'upi',
        date: '2026-11-20',
        source: 'manual',
      ),
    );

    final ownHit = await e.repo.checkDuplicate(
      amountPaise: 48600,
      merchant: 'zepto ',
      date: '2026-11-20',
    );
    expect(ownHit, isNotNull);
    expect(ownHit!.whoFirstName, isNull);

    final row = await (e.db.select(
      e.db.expenses,
    )..orderBy([(x) => OrderingTerm.desc(x.createdAt)])).getSingle();
    await e.changes.write('Reassign', (c) {
      c.set('expenses', row.id, 'added_by', 'demo-priya');
    }, homeId: 'home1');

    final priyaHit = await e.repo.checkDuplicate(
      amountPaise: 48600,
      merchant: 'zepto ',
      date: '2026-11-20',
    );
    expect(priyaHit, isNotNull);
    expect(priyaHit!.whoFirstName, 'Priya');
  });

  test('addSpend with repeatMonthly creates bill and linked bill expense', () async {
    final e = await _env();
    await e.repo.addSpend(
      const NewExpense(
        amountPaise: 9000,
        merchant: 'Water can',
        category: 'Groceries',
        method: 'cash',
        date: '2026-11-20',
        source: 'manual',
      ),
      repeatMonthly: true,
    );

    final bill = await e.db.select(e.db.bills).getSingle();
    final expense = await e.db.select(e.db.expenses).getSingle();
    expect(bill.name, 'Water can');
    expect(bill.firstDueMonth, '2026-11');
    expect(bill.dueDay, 20);
    expect(expense.source, 'bill');
    expect(expense.billId, bill.id);
    expect(expense.forMonth, '2026-11');
  });
}
