import 'package:intl/intl.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

abstract final class Formatters {
  static String dayLabel(String date, String today, AppLocalizations l10n) {
    final d = Dates.daysBetween(today, date);
    if (d == 0) return l10n.dayToday;
    if (d == 1) return l10n.dayTomorrow;
    if (d == -1) return l10n.dayYesterday;
    return DateFormat('EEE, d MMM', 'en').format(Dates.parse(date));
  }

  static String duration(int minutes) => minutes < 60
      ? '${minutes}m'
      : '${minutes ~/ 60}h ${(minutes % 60).toString().padLeft(2, '0')}m';

  static String time12(DateTime t) => DateFormat('h:mm a', 'en').format(t);

  static String time12Ms(int ms) =>
      time12(DateTime.fromMillisecondsSinceEpoch(ms));

  static String monthName(String yyyyMm) =>
      DateFormat('MMMM', 'en').format(Dates.parse('$yyyyMm-01'));

  static String fingerprint(String hex12) =>
      '${hex12.substring(0, 4)} ${hex12.substring(4, 8)} ${hex12.substring(8, 12)}';
}
