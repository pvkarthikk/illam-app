import 'package:nm_flat/core/domain/duplicate_hint.dart';
import 'package:nm_flat/core/domain/merchant_key.dart';
import 'package:nm_flat/core/time/dates.dart';

/// Sums all spend amounts in [month] excluding [excludedIds].
int monthTotal(List<SpendLite> all, String month, Set<String> excludedIds) {
  final prefix = '$month-';
  var sum = 0;
  for (final e in all) {
    if (!excludedIds.contains(e.id) && e.date.startsWith(prefix)) {
      sum += e.amountPaise;
    }
  }
  return sum;
}

/// Aggregates spend totals by category for [month], sorted descending with A-Z tie-break.
List<(String, int)> categoryTotals(
  List<SpendLite> all,
  Map<String, String> categoryById,
  String month,
  Set<String> excludedIds,
) {
  final prefix = '$month-';
  final totals = <String, int>{};
  for (final e in all) {
    if (excludedIds.contains(e.id) || !e.date.startsWith(prefix)) continue;
    final cat = categoryById[e.id] ?? 'Other';
    totals[cat] = (totals[cat] ?? 0) + e.amountPaise;
  }
  final out = [for (final entry in totals.entries) (entry.key, entry.value)];
  out.sort((a, b) {
    final byAmt = b.$2.compareTo(a.$2);
    return byAmt != 0 ? byAmt : a.$1.compareTo(b.$1);
  });
  return out;
}

/// Returns up to 6 frequent recent merchants, topped up from [fallback].
List<String> topMerchants(
  List<SpendLite> all,
  String today,
  List<String> fallback,
) {
  final groups = <String, ({int count, SpendLite newest})>{};
  for (final e in all) {
    if (e.source == 'salary' || e.source == 'bill') continue;
    final diff = Dates.daysBetween(e.date, today);
    if (diff < 0 || diff > 90) continue;
    final k = e.merchantKey.isNotEmpty ? e.merchantKey : merchantKey(e.merchant);
    final cur = groups[k];
    if (cur == null) {
      groups[k] = (count: 1, newest: e);
    } else {
      final isNewer =
          e.date.compareTo(cur.newest.date) > 0 ||
          (e.date == cur.newest.date && e.createdAt > cur.newest.createdAt);
      groups[k] = (
        count: cur.count + 1,
        newest: isNewer ? e : cur.newest,
      );
    }
  }

  final entries = groups.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.count.compareTo(a.value.count);
      if (byCount != 0) return byCount;
      final byDate = b.value.newest.date.compareTo(a.value.newest.date);
      if (byDate != 0) return byDate;
      return b.value.newest.createdAt.compareTo(a.value.newest.createdAt);
    });

  final result = <String>[];
  final seenKeys = <String>{};
  for (final entry in entries.take(6)) {
    result.add(entry.value.newest.merchant);
    seenKeys.add(entry.key);
  }
  for (final f in fallback) {
    if (result.length >= 6) break;
    final k = merchantKey(f);
    if (seenKeys.add(k)) {
      result.add(f);
    }
  }
  return result;
}

/// Validates a monetary amount in paise; returns an ARB error key or null.
String? validateAmount(int? paise) =>
    (paise == null || paise <= 0 || paise > 100000000) ? 'moneyErrAmount' : null;

/// Validates a merchant name; returns an ARB error key or null.
String? validateMerchant(String s) {
  final trimmed = s.trim();
  return (trimmed.isEmpty || trimmed.length > 60) ? 'moneyErrMerchant' : null;
}

/// Returns whether [date] is on or before [today] and within 13 months prior.
bool otherDayAllowed(String date, String today) {
  final minDate = Dates.monthStart(Dates.addMonths(Dates.month(today), -13));
  return date.compareTo(today) <= 0 && date.compareTo(minDate) >= 0;
}

/// Days remaining in [today]'s month after [today].
int daysToGo(String today) =>
    Dates.daysInMonth(Dates.month(today)) - Dates.parse(today).day;
