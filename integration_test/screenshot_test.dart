import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nm_flat/features/today/today_screen.dart';
import 'package:nm_flat/main.dart' as app;

Future<void> _waitForFinder(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) {
      await tester.pumpAndSettle();
      return;
    }
  }
  await tester.pumpAndSettle();
}

Future<void> _openTab(WidgetTester tester, Key key) async {
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture Play Store screenshots', (WidgetTester tester) async {
    WidgetsApp.debugAllowBannerOverride = false;

    await app.main();
    await tester.pumpAndSettle();

    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }

    await _waitForFinder(tester, find.byKey(const Key('nav_today')));
    await _waitForFinder(tester, find.textContaining('ANAND HOME'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    await binding.takeScreenshot('01_today');

    await _openTab(tester, const Key('nav_lists'));
    await binding.takeScreenshot('02_lists');

    await _openTab(tester, const Key('nav_tasks'));
    await binding.takeScreenshot('03_tasks');

    await _openTab(tester, const Key('nav_meals'));
    await binding.takeScreenshot('04_meals');

    await _openTab(tester, const Key('nav_money'));
    await binding.takeScreenshot('05_money');

    await _openTab(tester, const Key('nav_today'));
    final todayScroll = find.descendant(
      of: find.byType(TodayScreen),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.textContaining('Lakshmi'),
      250,
      scrollable: todayScroll.first,
    );
    await tester.tap(find.textContaining('Lakshmi').first);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('06_staff_attendance');
  });
}
