import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

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
import 'package:nm_flat/features/tasks/tasks_screen.dart';
import 'package:nm_flat/features/today/sections/upcoming_trip_section.dart';
import 'package:nm_flat/features/trips/trip_detail_screen.dart';
import 'package:nm_flat/features/trips/trip_template_screen.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<({
  NestDatabase db,
  DevicePrefs prefs,
  MemorySecureStore secure,
  ChangeWriter changes,
  FixedClock clock,
  GoRouter router,
})> _pumpTripRouter(
  WidgetTester tester, {
  String initialLocation = Routes.tasks,
}) async {
  tester.view.physicalSize = const Size(412, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final db = NestDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final prefs = await DevicePrefs.inMemory();
  await prefs.setCurrentHomeId('NM-TRP1');
  await prefs.setMemberId('mem-1');
  final clock = FixedClock(DateTime(2026, 11, 27, 9, 0));
  final changes = ChangeWriter(
    db,
    CollectionRegistry.build(db),
    HlcClock(clock, prefs),
    prefs,
    validator: const Validator(),
    clock: clock,
  );
  await changes.write('Seed home & member', (c) {
    c.create('homes', {'name': 'Home'}, id: 'NM-TRP1');
    c.create('members', {
      'full_name': 'Karthik',
      'first_name': 'Karthik',
      'role': 'admin',
      'status': 'active',
    }, id: 'mem-1');
  }, homeId: 'NM-TRP1');

  final secure = MemorySecureStore();
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: Routes.tasks,
        builder: (_, _) => const TasksScreen(),
      ),
      GoRoute(
        path: '/tasks/trip/:id',
        builder: (_, state) =>
            TripDetailScreen(tripId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: Routes.tripTemplate,
        builder: (_, _) => const TripTemplateScreen(),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(db),
        prefsProvider.overrideWithValue(prefs),
        secureStoreProvider.overrideWithValue(secure),
        clockProvider.overrideWithValue(clock),
        changesProvider.overrideWithValue(changes),
      ],
      child: MaterialApp.router(
        theme: NestTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();

  return (
    db: db,
    prefs: prefs,
    secure: secure,
    changes: changes,
    clock: clock,
    router: router,
  );
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  testWidgets(
    'Tasks -> Trips manages generic checklist, creates trip with date & generic items, and checks items off',
    (tester) async {
      await _pumpTripRouter(tester);

      // Switch to the 3rd segment: Trips.
      await tester.tap(find.textContaining('Trips'));
      await tester.pumpAndSettle();

      expect(find.text('Generic checklist'), findsOneWidget);
      expect(find.text('No trips planned'), findsOneWidget);

      // Open Generic checklist screen and add a generic item.
      await tester.tap(find.text('Generic checklist'));
      await tester.pumpAndSettle();

      expect(find.text('No generic items yet'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Chargers');
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Chargers'), findsOneWidget);

      // Load starter essentials too.
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(
        find.text('1 reusable item · auto-copies to new trips'),
        findsOneWidget,
      );

      // Tap New trip and create one (default tomorrow = 2026-11-28, Include generic checklist ON).
      await tester.tap(find.text('New trip'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Trip name'),
        'Coorg Weekend',
      );
      await tester.tap(find.text('Add trip'));
      await tester.pumpAndSettle();

      // Automatically navigated to TripDetailScreen with copied generic item.
      expect(find.text('Coorg Weekend'), findsOneWidget);
      expect(find.text('28 Nov'), findsOneWidget);
      expect(find.text('1 item left before you go'), findsOneWidget);
      expect(find.text('Chargers'), findsOneWidget);

      // Add a trip-specific item.
      await tester.enterText(
        find.widgetWithText(TextField, 'Add item to check before leaving…'),
        'Umbrella',
      );
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Umbrella'), findsOneWidget);
      expect(find.text('2 items left before you go'), findsOneWidget);

      // Check off Chargers -> moves into collapsed Checked (1).
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is NestCheckbox && w.semanticLabel == 'Chargers',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1 item left before you go'), findsOneWidget);
      expect(find.text('Chargers'), findsNothing);
      expect(find.text('Checked (1)'), findsOneWidget);

      // Check off Umbrella -> trip is now all set!
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is NestCheckbox && w.semanticLabel == 'Umbrella',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('All set for your trip!'), findsOneWidget);
      expect(find.text('Checked (2)'), findsOneWidget);
    },
  );

  testWidgets(
    'TripTemplateScreen Load starter essentials populates starter items cleanly',
    (tester) async {
      await _pumpTripRouter(tester, initialLocation: Routes.tripTemplate);

      await tester.tap(find.text('Load starter essentials'));
      await tester.pumpAndSettle();

      expect(find.text('Phone chargers & cables'), findsOneWidget);
      expect(find.text('Turn off gas stove'), findsOneWidget);
    },
  );

  testWidgets(
    'UpcomingTripSection appears on Today within 3 days when unchecked items exist and hides when ready',
    (tester) async {
      final db = NestDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final prefs = await DevicePrefs.inMemory();
      await prefs.setCurrentHomeId('NM-TRP1');
      await prefs.setMemberId('mem-1');
      final clock = FixedClock(DateTime(2026, 11, 27, 9, 0));
      final changes = ChangeWriter(
        db,
        CollectionRegistry.build(db),
        HlcClock(clock, prefs),
        prefs,
        validator: const Validator(),
        clock: clock,
      );
      await changes.write('Seed home', (c) {
        c.create('homes', {'name': 'Home'}, id: 'NM-TRP1');
      }, homeId: 'NM-TRP1');

      late String itemId;
      await changes.write('Seed trip', (c) {
        final tripId = c.create('trips', {
          'title': 'Goa',
          'start_date': '2026-11-28',
        });
        itemId = c.create('trip_items', {
          'trip_id': tripId,
          'title': 'Lock main door',
          'done': false,
          'sort_order': 0,
        });
      }, homeId: 'NM-TRP1');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dbProvider.overrideWithValue(db),
            prefsProvider.overrideWithValue(prefs),
            clockProvider.overrideWithValue(clock),
            changesProvider.overrideWithValue(changes),
          ],
          child: MaterialApp(
            theme: NestTheme.light(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            home: const Scaffold(body: UpcomingTripSection()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('UPCOMING TRIP'), findsOneWidget);
      expect(find.text('Goa'), findsOneWidget);
      expect(find.text('Tomorrow · 1 item left'), findsOneWidget);

      await changes.write('Check item', (c) {
        c.set('trip_items', itemId, 'done', true);
      }, homeId: 'NM-TRP1');
      await tester.pumpAndSettle();

      expect(find.text('Goa'), findsNothing);
    },
  );
}
