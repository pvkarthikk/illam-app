import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/nest_colors.dart';
import 'package:nm_flat/core/design/nest_text.dart';
import 'package:nm_flat/core/design/nest_theme.dart';
import 'package:nm_flat/main.dart';

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

  group('MyApp branding and theme switching', () {
    testWidgets('uses Nest Mojo - Flat title and switches between light and dark', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp(initialThemeMode: ThemeMode.light));

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.title, 'Nest Mojo - Flat');
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Nest Mojo - Flat'),
        ),
        findsOneWidget,
      );

      var scaffoldContext = tester.element(find.byType(Scaffold));
      expect(Theme.of(scaffoldContext).brightness, Brightness.light);
      expect(scaffoldContext.nest.paper, const Color(0xFFF4ECDF));

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      scaffoldContext = tester.element(find.byType(Scaffold));
      expect(Theme.of(scaffoldContext).brightness, Brightness.dark);
      expect(scaffoldContext.nest.paper, const Color(0xFF0F1612));

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      scaffoldContext = tester.element(find.byType(Scaffold));
      expect(Theme.of(scaffoldContext).brightness, Brightness.light);
      expect(scaffoldContext.nest.paper, const Color(0xFFF4ECDF));
    });
  });
}
