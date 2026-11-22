import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/domain/merchant_key.dart';
import 'package:nm_flat/core/time/dates.dart';

class NewExpense {
  const NewExpense({
    required this.amountPaise,
    required this.merchant,
    required this.category,
    required this.method,
    required this.date,
    required this.source,
    this.paidBy,
    this.forMonth,
    this.billId,
    this.orderChannel,
    this.staffId,
    this.settlementAttemptId,
    this.note,
  });

  final int amountPaise;
  final String merchant;
  final String category;
  final String method;
  final String date;
  final String source;
  final String? paidBy;
  final String? forMonth;
  final String? billId;
  final String? orderChannel;
  final String? staffId;
  final String? settlementAttemptId;
  final String? note;
}

class ExpensesRepo {
  ExpensesRepo(this.db, this.prefs);

  final NestDatabase db;
  final DevicePrefs prefs;

  String get _me => prefs.memberId ?? prefs.deviceId;

  String createIn(ChangeBuilder c, NewExpense e) => c.create('expenses', {
    'amount_paise': e.amountPaise,
    'merchant': e.merchant,
    'merchant_key': merchantKey(e.merchant),
    'category': e.category,
    'method': e.method,
    'date': e.date,
    'doc_month': Dates.month(Dates.iso(DateTime.now())),
    'for_month': e.forMonth,
    'paid_by': e.paidBy ?? _me,
    'added_by': _me,
    'source': e.source,
    'bill_id': e.billId,
    'order_channel': e.orderChannel,
    'staff_id': e.staffId,
    'settlement_attempt_id': e.settlementAttemptId,
    'note': e.note,
  });

  Stream<List<ExpenseRow>> watchMonth(String homeId, String month) =>
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
}
