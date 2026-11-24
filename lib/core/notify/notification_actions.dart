import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:nm_flat/core/domain/salary_months.dart';
import 'package:nm_flat/core/notify/notifications.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';

Future<void> handleNotificationAction(Reader read, NotificationResponse r) async {
  final raw = r.payload;
  if (raw == null || raw.isEmpty) return;
  Map<String, dynamic> data;
  try {
    data = jsonDecode(raw) as Map<String, dynamic>;
  } catch (_) {
    return;
  }

  final today = Dates.today(read(clockProvider));
  final me = read(myMemberIdProvider);

  switch (r.actionId) {
    case 'mark_in':
      final staffId = data['staffId'] as String?;
      if (staffId != null) {
        final visits = await read(visitsTodayProvider.future);
        final hasOpen = visits.any(
          (v) => v.staffId == staffId && v.outAt == null,
        );
        if (!hasOpen) {
          await read(staffRepoProvider).markIn(staffId, me);
        }
      }
    case 'leave_today':
      final staffId = data['staffId'] as String?;
      if (staffId != null) {
        await read(staffRepoProvider).setLeave(
          staffId: staffId,
          date: today,
          on: true,
          memberId: me,
        );
      }
    case 'bill_paid':
      final billId = data['billId'] as String?;
      if (billId != null) {
        final rawKey = data['key'] as String? ?? '';
        final colon = rawKey.lastIndexOf(':');
        final tail = colon >= 0 ? rawKey.substring(colon + 1) : '';
        final month = tail.length == 10 ? Dates.month(tail) : Dates.month(today);
        final bills = await read(billsProvider.future);
        final bill = bills.where((b) => b.id == billId).firstOrNull;
        if (bill != null && bill.active) {
          final expenses = await read(
            moneyRepoProvider,
          ).watchExpensesSince(Dates.monthStart(prevMonth(month))).first;
          final alreadyPaid = expenses.any(
            (e) => e.billId == billId && e.forMonth == month,
          );
          if (!alreadyPaid) {
            await read(moneyRepoProvider).markBillPaid(
              bill: bill,
              amountPaise: bill.usualAmountPaise,
              method: bill.method,
              date: today,
              forMonth: month,
            );
          }
        }
      }
  }

  final key = data['key'] as String? ?? '';
  final cancelId = r.id ?? (key.isNotEmpty ? stableId(key) : null);
  if (cancelId != null) {
    try {
      await plugin.cancel(id: cancelId);
    } catch (_) {}
  }
}
