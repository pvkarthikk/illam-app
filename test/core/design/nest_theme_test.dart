import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/app.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/today/today_screen.dart';

void main() {
  group('NestTheme palette & typography', () {
    test('light theme matches NestColors.light tokens', () {
      final light = NestTheme.light();
      final nest = light.extension<NestColors>()!;

      expect(light.brightness, Brightness.light);
      expect(light.scaffoldBackgroundColor, const Color(0xFFF4ECDF));
      expect(nest.paper, const Color(0xFFF4ECDF));
      expect(nest.card, const Color(0xFFFFFAF2));
      expect(nest.ink, const Color(0xFF1D2A21));
      expect(light.colorScheme.onSurface, const Color(0xFF1D2A21));
      expect(light.colorScheme.primary, const Color(0xFF23503A));
      expect(light.colorScheme.secondary, const Color(0xFFD98F1C));
      expect(light.colorScheme.error, const Color(0xFFB0412A));
    });

    test('dark theme matches NestColors.dark tokens', () {
      final dark = NestTheme.dark();
      final nest = dark.extension<NestColors>()!;

      expect(dark.brightness, Brightness.dark);
      expect(dark.scaffoldBackgroundColor, const Color(0xFF0F1612));
      expect(nest.paper, const Color(0xFF0F1612));
      expect(nest.card, const Color(0xFF19241D));
      expect(nest.ink, const Color(0xFFEFE7D8));
      expect(dark.colorScheme.onSurface, const Color(0xFFEFE7D8));
      expect(dark.colorScheme.primary, const Color(0xFF8FD0A8));
      expect(dark.colorScheme.secondary, const Color(0xFFF0B44E));
      expect(dark.colorScheme.error, const Color(0xFFF08C72));
    });

    test('uses HankenGrotesk for theme/sans and YoungSerif for display styles', () {
      final light = NestTheme.light();

      expect(light.textTheme.bodyMedium?.fontFamily, NestText.sans);
      expect(NestText.body15.fontFamily, 'HankenGrotesk');
      expect(NestText.display38.fontFamily, 'YoungSerif');
    });
  });

  group('NestApp shell and theme mode', () {
    testWidgets('renders 5 tabs and honours themeModeProvider', (
      WidgetTester tester,
    ) async {
      final prefs = await DevicePrefs.inMemory();
      final db = NestDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prefsProvider.overrideWithValue(prefs),
            dbProvider.overrideWithValue(db),
            themeModeProvider.overrideWithValue(ThemeMode.light),
          ],
          child: const NestApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationDestination), findsNWidgets(5));
      expect(find.text('Arrives in P03'), findsOneWidget);

      var todayContext = tester.element(find.byType(TodayScreen));
      expect(Theme.of(todayContext).brightness, Brightness.light);
      expect(todayContext.nest.paper, const Color(0xFFF4ECDF));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prefsProvider.overrideWithValue(prefs),
            dbProvider.overrideWithValue(db),
            themeModeProvider.overrideWithValue(ThemeMode.dark),
          ],
          child: const NestApp(),
        ),
      );
      await tester.pumpAndSettle();

      todayContext = tester.element(find.byType(TodayScreen));
      expect(Theme.of(todayContext).brightness, Brightness.dark);
      expect(todayContext.nest.paper, const Color(0xFF0F1612));
    });
  });
}
