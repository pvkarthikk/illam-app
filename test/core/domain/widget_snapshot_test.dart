import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/attendance.dart';
import 'package:nm_flat/core/domain/duplicate_hint.dart';
import 'package:nm_flat/core/domain/money_widget_snapshot.dart';
import 'package:nm_flat/core/domain/widget_snapshot.dart';

void main() {
  const today = '2026-11-25'; // Wednesday (ISO weekday 3)
  final nowMs = DateTime(2026, 11, 25, 9, 30).millisecondsSinceEpoch;
  final inAtMs = DateTime(2026, 11, 25, 8, 0).millisecondsSinceEpoch;
  final outAtMs = DateTime(2026, 11, 25, 9, 15).millisecondsSinceEpoch;

  test('noHome builders return empty hasHome: false payloads', () {
    final staff = buildStaffWidgetSnapshot(
      hasHome: false,
      today: today,
      nowMs: nowMs,
      staff: const [StaffWidgetInput(id: 's1', name: 'Lakshmi')],
      visitsToday: const [],
      leavesToday: const {},
    );
    expect(staff.hasHome, isFalse);
    expect(staff.items, isEmpty);
    expect(staff.toJson()['hasHome'], isFalse);

    final todos = buildTodoWidgetSnapshot(
      hasHome: false,
      today: today,
      todos: const [TodoWidgetInput(id: 't1', title: 'Milk', due: today)],
      routines: const [],
    );
    expect(todos.hasHome, isFalse);
    expect(todos.totalCount, 0);
    expect(todos.items, isEmpty);
  });

  test('staff snapshot encodes expected, in (newest open), done, leave, and off', () {
    final snap = buildStaffWidgetSnapshot(
      hasHome: true,
      homeName: 'Home',
      today: today,
      nowMs: nowMs,
      staff: const [
        StaffWidgetInput(
          id: 's_exp',
          name: 'Kamala',
          role: 'House help',
          expectedTimesCsv: '09:00',
        ),
        StaffWidgetInput(id: 's_in', name: 'Lakshmi', color: 'B0412A'),
        StaffWidgetInput(id: 's_done', name: 'Selvi'),
        StaffWidgetInput(id: 's_leave', name: 'Rani'),
        StaffWidgetInput(
          id: 's_off',
          name: 'Mani',
          workDaysOverride: [1, 2, 4, 5],
        ),
      ],
      visitsToday: [
        StaffVisitRecord(
          staffId: 's_in',
          visit: VisitLite(id: 'v_old', date: today, inAt: inAtMs - 3600000),
        ),
        StaffVisitRecord(
          staffId: 's_in',
          visit: VisitLite(id: 'v_new', date: today, inAt: inAtMs),
        ),
        StaffVisitRecord(
          staffId: 's_done',
          visit: VisitLite(
            id: 'v_done',
            date: today,
            inAt: inAtMs,
            outAt: outAtMs,
          ),
        ),
      ],
      leavesToday: const {'s_leave'},
    );

    expect(snap.hasHome, isTrue);
    expect(snap.items.length, 5);

    expect(snap.items[0].status, 'expected');
    expect(snap.items[0].action, 'mark_in');
    expect(snap.items[0].actionLabel, 'Mark in');
    expect(snap.items[0].subtitle, contains('Expected 9:00 AM'));

    expect(snap.items[1].status, 'in');
    expect(snap.items[1].action, 'mark_out');
    expect(snap.items[1].actionLabel, 'Mark out');
    expect(snap.items[1].openVisitId, 'v_new');
    expect(snap.items[1].colorHex, '#B0412A');

    expect(snap.items[2].status, 'done');
    expect(snap.items[2].action, 'mark_in');
    expect(snap.items[2].actionLabel, '+ Visit');
    expect(snap.items[2].subtitle, contains('1h 15m'));

    expect(snap.items[3].status, 'leave');
    expect(snap.items[3].action, 'mark_in');

    expect(snap.items[4].status, 'off');
    expect(snap.items[4].action, 'mark_in');
  });

  test('todo snapshot includes overdue, due today, and due routines sorted', () {
    final snap = buildTodoWidgetSnapshot(
      hasHome: true,
      homeName: 'Home',
      today: today,
      todos: const [
        TodoWidgetInput(id: 't_done', title: 'Done', due: today, done: true),
        TodoWidgetInput(id: 't_fut', title: 'Future', due: '2026-11-26'),
        TodoWidgetInput(id: 't_nodue', title: 'Someday', due: ''),
        TodoWidgetInput(
          id: 't_today_b',
          title: 'Order rice',
          due: today,
          assigneeName: 'You',
        ),
        TodoWidgetInput(
          id: 't_today_a',
          title: 'Buy milk',
          due: today,
          assigneeName: 'Meera',
        ),
        TodoWidgetInput(
          id: 't_old',
          title: 'Pay bill',
          due: '2026-11-23',
        ),
      ],
      routines: const [
        RoutineWidgetInput(
          id: 'r_future',
          name: 'Fresh towels',
          room: 'Bath',
          lastDone: '2026-11-24',
          everyDays: 7,
        ),
        RoutineWidgetInput(
          id: 'r_due',
          name: 'Mop floors',
          room: 'Living',
          lastDone: '2026-11-18',
          everyDays: 7,
          assigneeName: 'Lakshmi',
        ),
        RoutineWidgetInput(
          id: 'r_over',
          name: 'Clean stove',
          room: 'Kitchen',
          lastDone: '2026-11-10',
          everyDays: 7,
        ),
      ],
      maxItems: 4,
    );

    expect(snap.totalCount, 5);
    expect(snap.items.length, 4);
    expect(snap.items[0].id, 't_old');
    expect(snap.items[0].overdue, isTrue);
    expect(snap.items[1].id, 't_today_a');
    expect(snap.items[1].overdue, isFalse);
    expect(snap.items[1].meta, contains('Meera'));
    expect(snap.items[2].id, 't_today_b');
    expect(snap.items[3].id, 'r_over');
    expect(snap.items[3].kind, 'routine');
    expect(snap.items[3].overdue, isTrue);
    expect(snap.items[3].meta, contains('Kitchen'));
  });

  test('todo snapshot filters strictly to onlyMemberId when provided', () {
    final snap = buildTodoWidgetSnapshot(
      hasHome: true,
      homeName: 'Home',
      today: today,
      onlyMemberId: 'm1',
      todos: const [
        TodoWidgetInput(
          id: 't_mine',
          title: 'My due task',
          due: today,
          assigneeType: 'member',
          assigneeId: 'm1',
          assigneeName: 'You',
        ),
        TodoWidgetInput(
          id: 't_wife',
          title: 'Wife due task',
          due: today,
          assigneeType: 'member',
          assigneeId: 'm2',
          assigneeName: 'Priya',
        ),
        TodoWidgetInput(
          id: 't_staff',
          title: 'Helper task',
          due: today,
          assigneeType: 'staff',
          assigneeId: 's1',
          assigneeName: 'Lakshmi',
        ),
      ],
      routines: const [
        RoutineWidgetInput(
          id: 'r_mine',
          name: 'Check filter',
          room: 'Kitchen',
          lastDone: '2026-11-10',
          everyDays: 7,
          assigneeType: 'member',
          assigneeId: 'm1',
          assigneeName: 'You',
        ),
        RoutineWidgetInput(
          id: 'r_other',
          name: 'Mop floors',
          room: 'Living',
          lastDone: '2026-11-10',
          everyDays: 7,
          assigneeType: 'member',
          assigneeId: 'm2',
          assigneeName: 'Priya',
        ),
        RoutineWidgetInput(
          id: 'r_staff_id_collision',
          name: 'Garden watering',
          room: 'Balcony',
          lastDone: '2026-11-10',
          everyDays: 7,
          assigneeType: 'staff',
          assigneeId: 'm1',
          assigneeName: 'Lakshmi',
        ),
      ],
    );

    expect(snap.totalCount, 2);
    expect(snap.items.map((e) => e.id), ['t_mine', 'r_mine']);
  });

  test('buildMoneyWidgetSnapshot computes month total, budget status & deduped merchants', () {
    final noHome = buildMoneyWidgetSnapshot(
      hasHome: false,
      today: today,
      monthExpenses: const [],
      recentSpends: const [],
    );
    expect(noHome.hasHome, isFalse);
    expect(noHome.monthSpentText, '₹0');

    final expenses = [
      const SpendLite(
        id: 'e1',
        merchant: 'Reliance Fresh',
        merchantKey: 'reliance fresh',
        date: today,
        source: 'manual',
        addedBy: 'm1',
        amountPaise: 125000,
        createdAt: 20,
        method: 'upi',
      ),
      const SpendLite(
        id: 'e2',
        merchant: 'Reliance Fresh',
        merchantKey: 'reliance fresh',
        date: '2026-11-24',
        source: 'manual',
        addedBy: 'm1',
        amountPaise: 30000,
        createdAt: 10,
        method: 'upi',
      ),
      const SpendLite(
        id: 'e3',
        merchant: 'Apollo',
        merchantKey: 'apollo',
        date: '2026-11-20',
        source: 'manual',
        addedBy: 'm1',
        amountPaise: 50000,
        createdAt: 5,
        method: 'card',
      ),
    ];

    final snap = buildMoneyWidgetSnapshot(
      hasHome: true,
      homeName: 'Home',
      today: today,
      monthExpenses: expenses,
      recentSpends: expenses,
      budgetMonthlyPaise: 500000,
      extraCategories: const ['Medical'],
      localizedCategoryLabels: const {'Groceries': 'மளிகை'},
    );
    expect(snap.hasHome, isTrue);
    expect(snap.monthSpentPaise, 205000);
    expect(snap.monthSpentText, '₹2,050');
    expect(snap.budgetSubtitle, '₹2,950 left of ₹5,000');
    expect(snap.recentMerchants, ['Reliance Fresh', 'Apollo']);
    expect(snap.recentItems.length, 2);
    expect(snap.categories.any((c) => c['id'] == 'Medical'), isTrue);
    expect(
      snap.categories.firstWhere((c) => c['id'] == 'Groceries')['label'],
      'மளிகை',
    );
  });
}
