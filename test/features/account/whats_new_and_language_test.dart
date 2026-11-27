import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/app.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/validator.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';
import 'package:nm_flat/features/account/appearance_controller.dart';
import 'package:nm_flat/features/account/profile_screen.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

void main() {
  setUpAll(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    await Future.wait([
      initializeDateFormatting('en'),
      initializeDateFormatting('ta'),
      initializeDateFormatting('hi'),
    ]);
  });

  testWidgets(
    'What\'s New sheet shows once on version upgrade, persists seen version, and hides on relaunch',
    (tester) async {
      final prefs = await DevicePrefs.inMemory();
      await prefs.setCurrentHomeId('NM-VER1');
      final db = NestDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prefsProvider.overrideWithValue(prefs),
            dbProvider.overrideWithValue(db),
            secureStoreProvider.overrideWithValue(MemorySecureStore()),
            appVersionNameProvider.overrideWith((_) async => '1.7.0'),
          ],
          child: const NestApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("What's new"), findsOneWidget);
      expect(find.text('Version 1.7.0'), findsOneWidget);

      await tester.ensureVisible(find.text('Got it'));
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(find.text("What's new"), findsNothing);
      expect(prefs.lastSeenChangelogVersion, '1.7.0');

      // Re-mounting at the same version must NOT show What's New again.
      await tester.pumpWidget(
        ProviderScope(
          key: const ValueKey('relaunch'),
          overrides: [
            prefsProvider.overrideWithValue(prefs),
            dbProvider.overrideWithValue(db),
            secureStoreProvider.overrideWithValue(MemorySecureStore()),
            appVersionNameProvider.overrideWith((_) async => '1.7.0'),
          ],
          child: const NestApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("What's new"), findsNothing);
    },
  );

  testWidgets(
    'Profile lets user open release notes history and switch language to Tamil and Hindi',
    (tester) async {
      tester.view.physicalSize = const Size(412, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final db = NestDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final prefs = await DevicePrefs.inMemory();
      await prefs.setCurrentHomeId('NM-PROF1');
      await prefs.setMemberId('mem-1');
      final clock = FixedClock(DateTime(2026, 11, 27, 10, 0));
      final changes = ChangeWriter(
        db,
        CollectionRegistry.build(db),
        HlcClock(clock, prefs),
        prefs,
        validator: const Validator(),
        clock: clock,
      );
      await changes.write('Seed home', (c) {
        c.create('homes', {'name': 'Illam Home'}, id: 'NM-PROF1');
        c.create('members', {
          'full_name': 'Karthik',
          'first_name': 'Karthik',
          'role': 'admin',
          'status': 'active',
          'color': '#23503A',
        }, id: 'mem-1');
      }, homeId: 'NM-PROF1');

      final container = ProviderContainer(
        overrides: [
          dbProvider.overrideWithValue(db),
          prefsProvider.overrideWithValue(prefs),
          secureStoreProvider.overrideWithValue(MemorySecureStore()),
          clockProvider.overrideWithValue(clock),
          changesProvider.overrideWithValue(changes),
          minuteTickProvider.overrideWith((_) => Stream.value(clock.now())),
          appVersionProvider.overrideWith((_) async => '1.7.0 (1007000)'),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: Routes.profile,
        routes: [
          GoRoute(
            path: Routes.profile,
            builder: (_, _) => const ProfileScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) => MaterialApp.router(
              locale: ref.watch(appLocaleProvider),
              theme: NestTheme.light(),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Language defaults to system preference (resolves to 'en' in test harness).
      expect(prefs.appLanguage, 'system');
      expect(find.text('System default'), findsOneWidget);

      // Switch to Tamil.
      final enL10n = lookupAppLocalizations(const Locale('en'));
      await tester.ensureVisible(find.text(enL10n.profileLanguage));
      await tester.tap(find.text(enL10n.profileLanguage));
      await tester.pumpAndSettle();

      await tester.tap(find.text(enL10n.profileLangTamil));
      await tester.pumpAndSettle();

      expect(prefs.appLanguage, 'ta');
      final taL10n = lookupAppLocalizations(const Locale('ta'));
      expect(find.text(taL10n.profileTitle), findsOneWidget);

      // Switch to Hindi.
      await tester.ensureVisible(find.text(taL10n.profileLanguage));
      await tester.tap(find.text(taL10n.profileLanguage));
      await tester.pumpAndSettle();

      await tester.tap(find.text(taL10n.profileLangHindi));
      await tester.pumpAndSettle();

      expect(prefs.appLanguage, 'hi');
      final hiL10n = lookupAppLocalizations(const Locale('hi'));
      expect(find.text(hiL10n.profileTitle), findsOneWidget);

      // Tapping Version row opens Release Notes history.
      await tester.ensureVisible(find.text('1.7.0 (1007000)'));
      await tester.tap(find.text('1.7.0 (1007000)'));
      await tester.pumpAndSettle();

      expect(find.text(hiL10n.whatsNewHistoryTitle), findsOneWidget);
      expect(find.text(hiL10n.whatsNewVersionHeader('1.7.0')), findsOneWidget);

      await tester.ensureVisible(find.text(hiL10n.whatsNewGotIt));
      await tester.tap(find.text(hiL10n.whatsNewGotIt));
      await tester.pumpAndSettle();

      // Switch back to System default (resolves to English in test harness).
      await tester.ensureVisible(find.text(hiL10n.profileLanguage));
      await tester.tap(find.text(hiL10n.profileLanguage));
      await tester.pumpAndSettle();

      await tester.tap(find.text(hiL10n.profileLangSystem));
      await tester.pumpAndSettle();

      expect(prefs.appLanguage, 'system');
      expect(find.text(enL10n.profileTitle), findsOneWidget);
    },
  );
}
