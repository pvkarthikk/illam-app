import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/bills.dart';
import 'package:nm_flat/core/domain/duplicate_hint.dart';
import 'package:nm_flat/core/domain/merchant_key.dart';
import 'package:nm_flat/core/domain/money_math.dart';

SpendLite _spend({
  String id = 's1',
  String merchant = 'Zepto',
  int amountPaise = 48600,
  String date = '2026-11-20',
  String source = 'manual',
  String addedBy = 'demo-priya',
  int createdAt = 1000,
  String? orderChannel,
  String? billId,
  String? forMonth,
  String? settlementAttemptId,
}) => SpendLite(
  id: id,
  merchant: merchant,
  merchantKey: merchantKey(merchant),
  date: date,
  source: source,
  addedBy: addedBy,
  amountPaise: amountPaise,
  createdAt: createdAt,
  orderChannel: orderChannel,
  billId: billId,
  forMonth: forMonth,
  settlementAttemptId: settlementAttemptId,
);

void main() {
  group('findDuplicate (P10.3)', () {
    const today = '2026-11-20';

    test('matches same merchant and amount on same day', () {
      final priya = _spend();
      final hit = findDuplicate(
        amountPaise: 48600,
        merchantKey: merchantKey('zepto '),
        date: today,
        existing: [priya],
      );
      expect(hit?.id, priya.id);
      expect(hit?.addedBy, 'demo-priya');
    });

    test('matches within 1 day and rejects 2 days apart', () {
      final yesterday = _spend(date: '2026-11-19');
      expect(
        findDuplicate(
          amountPaise: 48600,
          merchantKey: merchantKey('Zepto'),
          date: today,
          existing: [yesterday],
        )?.id,
        yesterday.id,
      );

      final twoDays = _spend(date: '2026-11-18');
      expect(
        findDuplicate(
          amountPaise: 48600,
          merchantKey: merchantKey('Zepto'),
          date: today,
          existing: [twoDays],
        ),
        isNull,
      );
    });

    test('returns null when amount differs', () {
      final hit = findDuplicate(
        amountPaise: 48700,
        merchantKey: merchantKey('Zepto'),
        date: today,
        existing: [_spend()],
      );
      expect(hit, isNull);
    });

    test('matches bill source spend on same day', () {
      final bill = _spend(
        merchant: 'Electricity (BESCOM)',
        amountPaise: 198000,
        source: 'bill',
      );
      final hit = findDuplicate(
        amountPaise: 198000,
        merchantKey: merchantKey('Electricity (BESCOM)'),
        date: today,
        existing: [bill],
      );
      expect(hit?.id, bill.id);
    });

    test('ignores salary source', () {
      final salary = _spend(source: 'salary');
      final hit = findDuplicate(
        amountPaise: 48600,
        merchantKey: merchantKey('Zepto'),
        date: today,
        existing: [salary],
      );
      expect(hit, isNull);
    });

    test('matches by orderChannel even with different merchantKey', () {
      final order = _spend(
        merchant: 'Zepto order',
        source: 'order',
        orderChannel: 'zepto',
      );
      final hit = findDuplicate(
        amountPaise: 48600,
        merchantKey: merchantKey('Zepto'),
        orderChannel: 'zepto',
        date: today,
        existing: [order],
      );
      expect(hit?.id, order.id);
    });

    test('picks candidate with largest createdAt', () {
      final older = _spend(id: 'old', createdAt: 100);
      final newer = _spend(id: 'new', createdAt: 500);
      final hit = findDuplicate(
        amountPaise: 48600,
        merchantKey: merchantKey('Zepto'),
        date: today,
        existing: [older, newer],
      );
      expect(hit?.id, 'new');
    });
  });

  group('bills (P10.4)', () {
    const today = '2026-11-20';
    const firstDue = '2026-08';

    test('computes due kinds for today, overdue, soon, later, paid, paidTwice', () {
      expect(
        billStatus(
          firstDueMonth: firstDue,
          dueDay: 20,
          payments: const [],
          today: today,
        ).kind,
        BillDue.today,
      );
      expect(
        billStatus(
          firstDueMonth: firstDue,
          dueDay: 18,
          payments: const [],
          today: today,
        ).kind,
        BillDue.overdue,
      );
      expect(
        billStatus(
          firstDueMonth: firstDue,
          dueDay: 22,
          payments: const [],
          today: today,
        ).kind,
        BillDue.soon,
      );
      expect(
        billStatus(
          firstDueMonth: firstDue,
          dueDay: 23,
          payments: const [],
          today: today,
        ).kind,
        BillDue.soon,
      );
      expect(
        billStatus(
          firstDueMonth: firstDue,
          dueDay: 24,
          payments: const [],
          today: today,
        ).kind,
        BillDue.later,
      );

      final paidOne = billStatus(
        firstDueMonth: firstDue,
        dueDay: 20,
        payments: [_spend(forMonth: '2026-11')],
        today: today,
      );
      expect(paidOne.kind, BillDue.paid);
      expect(paidOne.paidTwice, isFalse);

      final paidTwo = billStatus(
        firstDueMonth: firstDue,
        dueDay: 20,
        payments: [
          _spend(id: 'p1', forMonth: '2026-11'),
          _spend(id: 'p2', forMonth: '2026-11'),
        ],
        today: today,
      );
      expect(paidTwo.kind, BillDue.paid);
      expect(paidTwo.paidTwice, isTrue);
    });

    test('dueDateFor clamps to month length', () {
      expect(dueDateFor('2027-02', 31), '2027-02-28');
    });

    test('firstDueMonthFor picks this or next month', () {
      expect(firstDueMonthFor(10, today), '2026-12');
      expect(firstDueMonthFor(25, today), '2026-11');
    });

    test('future firstDueMonth produces firstDue status', () {
      final st = billStatus(
        firstDueMonth: '2026-12',
        dueDay: 10,
        payments: const [],
        today: today,
      );
      expect(st.kind, BillDue.firstDue);
      expect(st.dueDate, '2026-12-10');
    });

    test('defaultForMonth picks previous month when unpaid', () {
      expect(
        defaultForMonth(
          firstDueMonth: firstDue,
          payments: const [],
          today: today,
        ),
        '2026-10',
      );
    });

    test('badge and due counts', () {
      final statuses = [
        for (final kind in BillDue.values) BillStatus(kind, today, const []),
      ];
      expect(moneyBadgeCount(statuses), 2);
      expect(billsDueCount(statuses), 3);
    });
  });

  group('money math (P10.5)', () {
    const today = '2026-11-20';

    test('monthTotal skips excluded ids and other months', () {
      final spends = [
        _spend(id: 'a', amountPaise: 1000, date: '2026-11-05'),
        _spend(id: 'b', amountPaise: 2000, date: '2026-11-10'),
        _spend(id: 'c', amountPaise: 5000, date: '2026-10-10'),
      ];
      expect(monthTotal(spends, '2026-11', {'b'}), 1000);
    });

    test('categoryTotals sorts descending then A-Z on ties', () {
      final spends = [
        _spend(id: '1', amountPaise: 500, date: '2026-11-01'),
        _spend(id: '2', amountPaise: 500, date: '2026-11-02'),
        _spend(id: '3', amountPaise: 900, date: '2026-11-03'),
      ];
      final cats = {'1': 'Utilities', '2': 'Eating out', '3': 'Groceries'};
      expect(categoryTotals(spends, cats, '2026-11', const {}), [
        ('Groceries', 900),
        ('Eating out', 500),
        ('Utilities', 500),
      ]);
    });

    test('validateAmount and validateMerchant', () {
      expect(validateAmount(0), 'moneyErrAmount');
      expect(validateAmount(100000001), 'moneyErrAmount');
      expect(validateAmount(100000000), isNull);

      expect(validateMerchant(''), 'moneyErrMerchant');
      expect(validateMerchant('x' * 61), 'moneyErrMerchant');
      expect(validateMerchant('Zepto'), isNull);
    });

    test('otherDayAllowed and daysToGo', () {
      expect(otherDayAllowed('2026-11-21', today), isFalse);
      expect(otherDayAllowed('2025-10-01', today), isTrue);
      expect(otherDayAllowed('2025-09-30', today), isFalse);
      expect(daysToGo(today), 10);
    });

    test('topMerchants deduplicates fallback by merchantKey', () {
      final spends = [
        _spend(id: '1', merchant: 'Zepto', date: '2026-11-19'),
        _spend(id: '2', merchant: 'zepto', date: '2026-11-18'),
        _spend(id: '3', merchant: 'Milkman', date: '2026-11-17'),
      ];
      final top = topMerchants(spends, today, const [
        'Zepto',
        'Amazon',
        'Milkman',
        'Swiggy',
        'D-Mart',
        'Electricity',
      ]);
      expect(top, ['Zepto', 'Milkman', 'Amazon', 'Swiggy', 'D-Mart', 'Electricity']);
    });
  });
}
