import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';
import 'package:nm_flat/features/staff/attendance_calendar_card.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

void main() {
  setUpAll(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    await initializeDateFormatting('en');
  });

  testWidgets(
    'Admin can mark Paid leave, switch to Informed leave, undo leave, and mark upcoming Paid leave',
    (tester) async {
      tester.view.physicalSize = const Size(412, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final db = NestDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final prefs = await DevicePrefs.inMemory();
      await prefs.setCurrentHomeId('H1');
      await prefs.setMemberId('m1');

      final clock = FixedClock(DateTime(2026, 11, 20, 9, 0));
      final changes = ChangeWriter(
        db,
        CollectionRegistry.build(db),
        HlcClock(clock, prefs),
        prefs,
      );
      await changes.write('Seed', (c) {
        c.create('homes', {'name': 'Our Home'}, id: 'H1');
        c.create('members', {
          'full_name': 'Karthik',
          'first_name': 'Karthik',
          'role': 'admin',
          'status': 'active',
        }, id: 'm1');
        c.create('staff', {
          'name': 'Kamala',
          'role': 'House help',
          'work_days': '1,2,3,4,5,6',
          'expected_times': '09:00',
          'start_date': '2026-11-01',
          'active': true,
        }, id: 's1');
      });
      final staff = await (db.select(
        db.staff,
      )..where((s) => s.id.equals('s1'))).getSingle();

      final container = ProviderContainer(
        overrides: [
          dbProvider.overrideWithValue(db),
          prefsProvider.overrideWithValue(prefs),
          clockProvider.overrideWithValue(clock),
          changesProvider.overrideWithValue(changes),
          todayDateProvider.overrideWithValue('2026-11-20'),
          minuteTickProvider.overrideWith(
            (_) => Stream.value(DateTime(2026, 11, 20, 9, 0)),
          ),
          isAdminProvider.overrideWithValue(true),
          monthSettledProvider.overrideWith((_, _) => false),
          workDaysProvider.overrideWith((_, _) => const [1, 2, 3, 4, 5, 6]),
        ],
      );
      addTearDown(container.dispose);
      final snack = container.read(snackbarProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: NestTheme.light(),
            scaffoldMessengerKey: snack.messengerKey,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: AttendanceCalendarCard(staff: staff),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Legend includes Paid leave alongside Leave.
      expect(find.text('Paid leave'), findsOneWidget);

      // Tap past absent day 18 -> mark Paid leave.
      await tester.tap(find.bySemanticsLabel('18: absent'));
      await tester.pumpAndSettle();

      expect(find.text('Informed leave'), findsOneWidget);
      expect(find.text('Paid leave'), findsNWidgets(2));

      await tester.tap(find.text('Paid leave').last);
      await tester.pumpAndSettle();

      var leave = await (db.select(
        db.leaves,
      )..where((l) => l.id.equals('s1_2026-11-18'))).getSingle();
      expect(leave.deleted, isFalse);
      expect(leave.paid, isTrue);
      expect(find.bySemanticsLabel('18: paid leave'), findsOneWidget);

      // Reopen day 18 -> verify paid leave lead, switch to Informed leave, then undo.
      await tester.tap(find.bySemanticsLabel('18: paid leave'));
      await tester.pumpAndSettle();
      expect(
        find.text('Marked as paid leave (no salary deduction).'),
        findsOneWidget,
      );
      expect(find.text('Undo leave'), findsOneWidget);

      await tester.tap(find.text('Informed leave'));
      await tester.pumpAndSettle();

      leave = await (db.select(
        db.leaves,
      )..where((l) => l.id.equals('s1_2026-11-18'))).getSingle();
      expect(leave.deleted, isFalse);
      expect(leave.paid, isFalse);
      expect(find.bySemanticsLabel('18: informed leave'), findsOneWidget);

      // Reopen day 18 -> remove leave.
      await tester.tap(find.bySemanticsLabel('18: informed leave'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Undo leave'));
      await tester.pumpAndSettle();

      leave = await (db.select(
        db.leaves,
      )..where((l) => l.id.equals('s1_2026-11-18'))).getSingle();
      expect(leave.deleted, isTrue);
      expect(find.bySemanticsLabel('18: absent'), findsOneWidget);

      // Admin can also pre-mark Paid leave on an upcoming day (25).
      await tester.tap(find.bySemanticsLabel('25: upcoming'));
      await tester.pumpAndSettle();
      expect(find.text('+ Add visit'), findsNothing);
      await tester.tap(find.text('Paid leave').last);
      await tester.pumpAndSettle();

      final upcomingLeave = await (db.select(
        db.leaves,
      )..where((l) => l.id.equals('s1_2026-11-25'))).getSingle();
      expect(upcomingLeave.deleted, isFalse);
      expect(upcomingLeave.paid, isTrue);
      expect(find.bySemanticsLabel('25: paid leave'), findsOneWidget);
    },
  );
}
