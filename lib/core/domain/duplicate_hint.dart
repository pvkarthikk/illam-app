import 'package:nm_flat/core/time/dates.dart';

/// Lightweight spend projection used by pure domain logic.
class SpendLite {
  const SpendLite({
    required this.id,
    required this.merchant,
    required this.merchantKey,
    required this.date,
    required this.source,
    required this.addedBy,
    required this.amountPaise,
    required this.createdAt,
    this.orderChannel,
    this.billId,
    this.forMonth,
    this.settlementAttemptId,
    this.method = 'upi',
  });

  final String id;
  final String merchant;
  final String merchantKey;
  final String date;
  final String source;
  final String addedBy;
  final int amountPaise;
  final int createdAt;
  final String? orderChannel;
  final String? billId;
  final String? forMonth;
  final String? settlementAttemptId;
  final String method;
}

/// Finds a likely duplicate spend within ±1 day with matching amount and merchant/channel.
SpendLite? findDuplicate({
  required int amountPaise,
  required String merchantKey,
  String? orderChannel,
  required String date,
  required List<SpendLite> existing,
}) {
  SpendLite? best;
  for (final e in existing) {
    if (e.source == 'salary') continue;
    if (e.amountPaise != amountPaise) continue;
    if (Dates.daysBetween(e.date, date).abs() > 1) continue;
    final sameMerchant = e.merchantKey == merchantKey;
    final sameChannel = orderChannel != null && orderChannel == e.orderChannel;
    if (!sameMerchant && !sameChannel) continue;

    if (best == null || e.createdAt > best.createdAt) {
      best = e;
    }
  }
  return best;
}
