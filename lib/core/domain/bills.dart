import 'dart:math';

import 'package:nm_flat/core/domain/duplicate_hint.dart';
import 'package:nm_flat/core/domain/salary_months.dart';
import 'package:nm_flat/core/time/dates.dart';

enum BillDue { overdue, today, soon, later, firstDue, paid }

/// Computed due status for a bill in the current month.
class BillStatus {
  const BillStatus(this.kind, this.dueDate, this.payments);

  final BillDue kind;
  final String dueDate;
  final List<SpendLite> payments;

  bool get paidTwice => payments.length > 1;
}

/// Returns the YYYY-MM-DD due date in [month] for [dueDay], clamped to the month's length.
String dueDateFor(String month, int dueDay) {
  final day = min(dueDay, Dates.daysInMonth(month));
  return '$month-${day.toString().padLeft(2, '0')}';
}

/// Returns the initial due month ('YYYY-MM') when creating a bill on [today].
String firstDueMonthFor(int dueDay, String today) {
  final m = Dates.month(today);
  return today.compareTo(dueDateFor(m, dueDay)) <= 0 ? m : nextMonth(m);
}

/// Computes the [BillStatus] for a bill on [today].
BillStatus billStatus({
  required String firstDueMonth,
  required int dueDay,
  required List<SpendLite> payments,
  required String today,
}) {
  final m = Dates.month(today);
  if (firstDueMonth.compareTo(m) > 0) {
    return BillStatus(
      BillDue.firstDue,
      dueDateFor(firstDueMonth, dueDay),
      const [],
    );
  }
  final monthPayments = [
    for (final p in payments)
      if (p.forMonth == m) p,
  ];
  final due = dueDateFor(m, dueDay);
  if (monthPayments.isNotEmpty) {
    return BillStatus(BillDue.paid, due, monthPayments);
  }
  final d = Dates.daysBetween(today, due);
  final BillDue kind;
  if (d < 0) {
    kind = BillDue.overdue;
  } else if (d == 0) {
    kind = BillDue.today;
  } else if (d <= 3) {
    kind = BillDue.soon;
  } else {
    kind = BillDue.later;
  }
  return BillStatus(kind, due, const []);
}

/// True when this month is unpaid and the previous month (>= [firstDueMonth]) is also unpaid.
bool previousMonthUnpaid({
  required String firstDueMonth,
  required List<SpendLite> payments,
  required String today,
}) {
  final m = Dates.month(today);
  final p = prevMonth(m);
  if (p.compareTo(firstDueMonth) < 0) return false;
  final mPaid = payments.any((e) => e.forMonth == m);
  final pPaid = payments.any((e) => e.forMonth == p);
  return !mPaid && !pPaid;
}

/// Returns the default `for_month` to preselect when marking a bill paid.
String defaultForMonth({
  required String firstDueMonth,
  required List<SpendLite> payments,
  required String today,
}) {
  final m = Dates.month(today);
  return previousMonthUnpaid(
        firstDueMonth: firstDueMonth,
        payments: payments,
        today: today,
      )
      ? prevMonth(m)
      : m;
}

/// Orders bills by due status index, then due date, then name.
int compareBills(BillStatus a, String nameA, BillStatus b, String nameB) {
  final byKind = a.kind.index.compareTo(b.kind.index);
  if (byKind != 0) return byKind;
  final byDue = a.dueDate.compareTo(b.dueDate);
  if (byDue != 0) return byDue;
  return nameA.compareTo(nameB);
}

/// Count of bills due today or overdue (shown on the Money tab badge).
int moneyBadgeCount(Iterable<BillStatus> s) {
  var n = 0;
  for (final st in s) {
    if (st.kind == BillDue.today || st.kind == BillDue.overdue) n++;
  }
  return n;
}

/// Count of bills due overdue, today, or within 3 days.
int billsDueCount(Iterable<BillStatus> s) {
  var n = 0;
  for (final st in s) {
    if (st.kind == BillDue.today ||
        st.kind == BillDue.overdue ||
        st.kind == BillDue.soon) {
      n++;
    }
  }
  return n;
}
