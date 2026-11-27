import 'package:intl/intl.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

abstract final class Formatters {
  /// Builds a [DateFormat] for [locale], falling back to `'en'` when date
  /// symbols for [locale] have not been initialized (e.g. headless unit tests).
  static DateFormat safeDateFormat(String pattern, String locale) {
    try {
      return DateFormat(pattern, locale);
    } on ArgumentError {
      return DateFormat(pattern, 'en');
    }
  }

  static String dayLabel(String date, String today, AppLocalizations l10n) {
    final d = Dates.daysBetween(today, date);
    if (d == 0) return l10n.dayToday;
    if (d == 1) return l10n.dayTomorrow;
    if (d == -1) return l10n.dayYesterday;
    return safeDateFormat('EEE, d MMM', l10n.localeName).format(Dates.parse(date));
  }

  static String duration(int minutes) => minutes < 60
      ? '${minutes}m'
      : '${minutes ~/ 60}h ${(minutes % 60).toString().padLeft(2, '0')}m';

  static String time12(DateTime t, [String locale = 'en']) =>
      safeDateFormat('h:mm a', locale).format(t);

  static String time12Ms(int ms, [String locale = 'en']) =>
      time12(DateTime.fromMillisecondsSinceEpoch(ms), locale);

  static String monthName(String yyyyMm, [String locale = 'en']) =>
      safeDateFormat('MMMM', locale).format(Dates.parse('$yyyyMm-01'));

  static String fingerprint(String hex12) =>
      '${hex12.substring(0, 4)} ${hex12.substring(4, 8)} ${hex12.substring(8, 12)}';
}
