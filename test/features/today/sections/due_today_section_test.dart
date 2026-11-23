import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/tasks_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/today/sections/due_today_section.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

TodoRow _todo(String id, String title, {String due = '2026-11-20', bool done = false}) =>
    TodoRow(
      id: id,
      homeId: 'h1',
      deleted: false,
      createdAt: 1000,
      createdBy: 'm1',
      updatedAt: 1000,
      updatedBy: 'm1',
      title: title,
      due: due,
      assigneeType: 'member',
      assignee: 'm1',
      done: done,
    );

RoutineRow _routine(String id, String name, {String lastDone = '2026-11-10', int everyDays = 7}) =>
    RoutineRow(
      id: id,
      homeId: 'h1',
      deleted: false,
      createdAt: 1000,
      createdBy: 'm1',
      updatedAt: 1000,
      updatedBy: 'm1',
      name: name,
      room: 'Kitchen',
      everyDays: everyDays,
      assigneeType: 'member',
      assignee: 'm1',
      lastDone: lastDone,
    );

void main() {
  testWidgets('dueTodayProvider caps visible rows at 5 and reports total', (
    WidgetTester tester,
  ) async {
    final todos = [
      _todo('t1', 'Beta', due: '2026-11-20'),
      _todo('t2', 'Alpha', due: '2026-11-20'),
      _todo('t3', 'Overdue', due: '2026-11-19'),
      _todo('t4', 'Future', due: '2026-11-22'),
      _todo('t5', 'Already done', due: '2026-11-19', done: true),
    ];
    final routines = [
      _routine('r1', 'Mop floors', lastDone: '2026-11-01', everyDays: 7),
      _routine('r2', 'Clean stove', lastDone: '2026-11-10', everyDays: 7),
      _routine('r3', 'Wash curtains', lastDone: '2026-11-13', everyDays: 7),
      _routine('r4', 'Fresh routine', lastDone: '2026-11-19', everyDays: 7),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayDateProvider.overrideWithValue('2026-11-20'),
          todosProvider.overrideWith((ref) => Stream.value(todos)),
          routinesProvider.overrideWith((ref) => Stream.value(routines)),
          taskPeopleProvider.overrideWithValue(
            const AsyncData([
              TaskPerson(
                id: 'm1',
                type: 'member',
                firstName: 'Anand',
                color: Color(0xFF4F8A8B),
                isMe: true,
              ),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: NestTheme.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: const Scaffold(
            body: SingleChildScrollView(child: DueTodaySection()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    // 3 due todos + 3 due routines = 6 total due, max 5 rendered + "1 more due".
    expect(find.text('Overdue'), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Mop floors'), findsOneWidget);
    expect(find.text('Clean stove'), findsOneWidget);
    expect(find.text('Wash curtains'), findsNothing);
    expect(find.text('Future'), findsNothing);
    expect(find.text('Fresh routine'), findsNothing);
    expect(find.text('+ 1 more due'), findsOneWidget);
  });
}
