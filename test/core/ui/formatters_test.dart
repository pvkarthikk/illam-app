import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUpAll(() => initializeDateFormatting('en'));

  test('Formatters.duration formats minutes and hours', () {
    expect(Formatters.duration(45), '45m');
    expect(Formatters.duration(65), '1h 05m');
    expect(Formatters.duration(135), '2h 15m');
  });

  test('Formatters.time12 formats 12-hour clock times', () {
    expect(Formatters.time12(DateTime(2026, 1, 1, 9, 5)), '9:05 AM');
    expect(Formatters.time12(DateTime(2026, 1, 1, 18, 0)), '6:00 PM');
  });

  test('Formatters.dayLabel handles relative and short dates', () {
    expect(Formatters.dayLabel('2026-11-25', '2026-11-25', l10n), 'Today');
    expect(Formatters.dayLabel('2026-11-26', '2026-11-25', l10n), 'Tomorrow');
    expect(Formatters.dayLabel('2026-11-24', '2026-11-25', l10n), 'Yesterday');
    expect(
      Formatters.dayLabel('2026-11-20', '2026-11-25', l10n),
      'Fri, 20 Nov',
    );
    expect(
      Formatters.dayLabel('2026-11-19', '2026-11-25', l10n),
      'Thu, 19 Nov',
    );
  });

  test('Formatters.monthName and fingerprint format expected strings', () {
    expect(Formatters.monthName('2026-11'), 'November');
    expect(Formatters.fingerprint('21fe31dfa154'), '21fe 31df a154');
  });
}
