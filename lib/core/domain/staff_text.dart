import 'package:nm_flat/core/ui/formatters.dart';

List<int> parseWorkDays(String csv) {
  final out = <int>[];
  for (final part in csv.split(',')) {
    final v = int.tryParse(part.trim());
    if (v != null && v >= 1 && v <= 7) {
      out.add(v);
    }
  }
  return out;
}

String workDaysCsv(List<int> days) {
  final sorted = days.where((d) => d >= 1 && d <= 7).toSet().toList()..sort();
  return sorted.join(',');
}

List<String> parseTimes(String csv) => [
  for (final s in csv.split(','))
    if (s.trim().isNotEmpty) s.trim(),
];

String daysText(
  List<int> days, {
  required List<String> short,
  required String daily,
}) {
  final sorted = days.where((d) => d >= 1 && d <= 7).toSet().toList()..sort();
  if (sorted.isEmpty) return '';
  if (sorted.length == 7) return daily;

  final parts = <String>[];
  var i = 0;
  while (i < sorted.length) {
    final start = sorted[i];
    var end = start;
    while (i + 1 < sorted.length && sorted[i + 1] == end + 1) {
      i++;
      end = sorted[i];
    }
    if (end - start + 1 >= 3) {
      parts.add('${short[start - 1]}\u2013${short[end - 1]}');
    } else {
      for (var d = start; d <= end; d++) {
        parts.add(short[d - 1]);
      }
    }
    i++;
  }
  return parts.join(', ');
}

String time12Of(String hhmm) {
  final p = hhmm.split(':');
  final h = p.isNotEmpty ? (int.tryParse(p[0].trim()) ?? 0) : 0;
  final m = p.length > 1 ? (int.tryParse(p[1].trim()) ?? 0) : 0;
  return Formatters.time12(DateTime(2026, 1, 1, h, m));
}

String timesText(List<String> times, String? usualEnd) {
  if (times.isEmpty) return '';
  if (times.length == 1 && usualEnd != null && usualEnd.trim().isNotEmpty) {
    final start = time12Of(times.first);
    final end = time12Of(usualEnd);
    final sParts = start.split(' ');
    final eParts = end.split(' ');
    if (sParts.length == 2 && eParts.length == 2 && sParts[1] == eParts[1]) {
      return '${sParts[0]}\u2013$end';
    }
    return '$start\u2013$end';
  }
  return times.map(time12Of).join(' & ');
}

abstract final class IndianMobile {
  static String? toE164(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) return null;
    return '+91$digits';
  }

  static String display(String e164) {
    if (RegExp(r'^\+91\d{10}$').hasMatch(e164)) {
      return '${e164.substring(0, 3)} ${e164.substring(3, 8)} ${e164.substring(8)}';
    }
    return e164;
  }

  static String waDigits(String e164) => e164.replaceAll(RegExp(r'\D'), '');
}
