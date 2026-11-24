import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/today/sections/help_at_home_section.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

StaffData _staff(String id, String name) => StaffData(
  id: id,
  homeId: 'h1',
  deleted: false,
  createdAt: 1000,
  createdBy: 'm1',
  updatedAt: 1000,
  updatedBy: 'm1',
  name: name,
  role: 'House help',
  color: '#4F8A8B',
  workDays: '1,2,3,4,5,6',
  expectedTimes: '09:00',
  startDate: '2026-11-20',
  active: true,
  initialPayType: 'monthly',
  initialPayPaise: 600000,
);

Future<void> _pumpSection(
  WidgetTester tester, {
  required List<StaffData> staff,
  required bool isAdmin,
  double width = 412,
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todayDateProvider.overrideWithValue('2026-11-20'),
        minuteTickProvider.overrideWith(
          (ref) => Stream.value(DateTime(2026, 11, 20, 9, 0)),
        ),
        clockProvider.overrideWithValue(
          FixedClock(DateTime(2026, 11, 20, 9, 0)),
        ),
        isAdminProvider.overrideWithValue(isAdmin),
        activeStaffProvider.overrideWith((ref) => Stream.value(staff)),
        openVisitsProvider.overrideWith((ref) => Stream.value(const <Visit>[])),
        visitsTodayProvider.overrideWith(
          (ref) => Stream.value(const <Visit>[]),
        ),
        leavesTodayProvider.overrideWith(
          (ref) => Stream.value(const <Leave>[]),
        ),
        workDaysProvider.overrideWith((ref, arg) => const [1, 2, 3, 4, 5, 6]),
      ],
      child: MaterialApp(
        theme: NestTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const Scaffold(
          body: SingleChildScrollView(child: HelpAtHomeSection()),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets(
    'keeps + Add button visible when a helper exists and opens add sheet',
    (WidgetTester tester) async {
      await _pumpSection(
        tester,
        staff: [_staff('s1', 'Kamala')],
        isAdmin: true,
      );

      expect(find.textContaining('Kamala'), findsOneWidget);
      expect(find.text('+ Add'), findsOneWidget);

      await tester.tap(find.text('+ Add'));
      await tester.pumpAndSettle();

      expect(find.text('Add house help'), findsOneWidget);
    },
  );

  testWidgets(
    'renders single + Add button when empty for admin',
    (WidgetTester tester) async {
      await _pumpSection(tester, staff: const [], isAdmin: true);

      expect(find.text('No house help added yet.'), findsOneWidget);
      expect(find.text('+ Add'), findsOneWidget);
    },
  );

  testWidgets(
    'hides + Add button for non-admins',
    (WidgetTester tester) async {
      await _pumpSection(
        tester,
        staff: [_staff('s1', 'Kamala')],
        isAdmin: false,
      );

      expect(find.textContaining('Kamala'), findsOneWidget);
      expect(find.text('+ Add'), findsNothing);
    },
  );

  testWidgets(
    'renders without overflow at narrow width and 2.0 text scale',
    (WidgetTester tester) async {
      await _pumpSection(
        tester,
        staff: const [],
        isAdmin: true,
        width: 360,
        textScale: 2.0,
      );

      expect(find.text('No house help added yet.'), findsOneWidget);
      expect(find.text('+ Add'), findsOneWidget);
    },
  );
}
