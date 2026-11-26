import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/tasks_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/tasks/tasks_screen.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

void main() {
  const people = [
    TaskPerson(
      id: 'm1',
      type: 'member',
      firstName: 'Anand',
      color: Color(0xFF4F8A8B),
      isMe: true,
    ),
  ];

  testWidgets(
    'TasksScreen shows Routines tab, generic empty icon, 3-month preset, and Area or place field',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todayDateProvider.overrideWithValue('2026-11-26'),
            routinesProvider.overrideWith(
              (ref) => Stream.value(const <RoutineRow>[]),
            ),
            todosProvider.overrideWith(
              (ref) => Stream.value(const <TodoRow>[]),
            ),
            taskPeopleProvider.overrideWithValue(const AsyncData(people)),
          ],
          child: MaterialApp(
            theme: NestTheme.light(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            home: const TasksScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Routines'), findsOneWidget);
      expect(find.textContaining('Cleaning'), findsNothing);
      expect(find.byIcon(Icons.event_repeat_outlined), findsOneWidget);
      expect(find.text('New routine'), findsOneWidget);

      await tester.ensureVisible(find.text('New routine'));
      await tester.tap(find.text('New routine'));
      await tester.pumpAndSettle();

      final sheet = find.byType(BottomSheet);
      expect(
        find.descendant(of: sheet, matching: find.text('New routine')),
        findsOneWidget,
      );
      expect(find.text('New cleaning routine'), findsNothing);

      final every3Months = find.descendant(
        of: sheet,
        matching: find.text('Every 3 months'),
      );
      await tester.ensureVisible(every3Months);
      expect(every3Months, findsOneWidget);

      final otherChip = find.descendant(
        of: sheet,
        matching: find.text('Other…'),
      );
      await tester.ensureVisible(otherChip);
      await tester.tap(otherChip);
      await tester.pump();

      expect(
        find.descendant(of: sheet, matching: find.text('Area or place')),
        findsOneWidget,
      );
    },
  );
}
