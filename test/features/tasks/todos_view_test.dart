import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/tasks_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/todo_dates.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/tasks/todos_view.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

TodoRow _todo(
  String id,
  String title, {
  String due = '2026-11-20',
  String assignee = 'm1',
  bool done = false,
  int? doneAt,
}) => TodoRow(
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
  assignee: assignee,
  done: done,
  doneAt: doneAt,
);

void main() {
  const people = [
    TaskPerson(
      id: 'm1',
      type: 'member',
      firstName: 'Anand',
      color: Color(0xFF4F8A8B),
      isMe: true,
    ),
    TaskPerson(
      id: 'm2',
      type: 'member',
      firstName: 'Meera',
      color: Color(0xFF9B5DE5),
    ),
  ];

  test('groupedTodosProvider groups, sorts, filters, and caches', () {
    final todos = [
      _todo('1', 'Overdue B', due: '2026-11-18', assignee: 'm1'),
      _todo('2', 'Overdue A', due: '2026-11-19', assignee: 'm2'),
      _todo('3', 'Today Z', due: '2026-11-20', assignee: 'm1'),
      _todo('4', 'Today A', due: '2026-11-20', assignee: 'm1'),
      _todo('5', 'Done older', done: true, doneAt: 100, assignee: 'm1'),
      _todo('6', 'Done newer', done: true, doneAt: 200, assignee: 'm2'),
    ];

    final container = ProviderContainer(
      overrides: [
        todayDateProvider.overrideWithValue('2026-11-20'),
        todosProvider.overrideWith((ref) => Stream.value(todos)),
      ],
    );
    addTearDown(container.dispose);

    // Prime async stream.
    container.listen(todosProvider, (_, _) {});
    return container.read(todosProvider.future).then((_) {
      final all = container.read(groupedTodosProvider(null));
      expect(all.hasOpen, isTrue);
      expect(all.open[TodoGroup.overdue]!.map((t) => t.id), ['1', '2']);
      expect(all.open[TodoGroup.today]!.map((t) => t.id), ['4', '3']);
      expect(all.done.map((t) => t.id), ['6', '5']);

      // Cached instance is reused across reads without upstream change.
      expect(identical(container.read(groupedTodosProvider(null)), all), isTrue);

      final onlyM1 = container.read(groupedTodosProvider('m1'));
      expect(onlyM1.open[TodoGroup.overdue]!.map((t) => t.id), ['1']);
      expect(onlyM1.done.map((t) => t.id), ['5']);
    });
  });

  testWidgets('TodosView lazily builds sliver items and toggles completed', (
    WidgetTester tester,
  ) async {
    final many = [
      for (var i = 0; i < 40; i++)
        _todo('t$i', 'Task ${i.toString().padLeft(2, '0')}', due: '2026-11-20'),
      _todo('d1', 'Finished errand', done: true, doneAt: 500),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayDateProvider.overrideWithValue('2026-11-20'),
          todosProvider.overrideWith((ref) => Stream.value(many)),
          taskPeopleProvider.overrideWithValue(const AsyncData(people)),
        ],
        child: MaterialApp(
          theme: NestTheme.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: const Scaffold(
            body: CustomScrollView(
              slivers: [TodosView()],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Task 00'), findsOneWidget);
    // Item 39 is far below the viewport so SliverList.builder does not build it yet.
    expect(find.text('Task 39'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Task 39'),
      400,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Task 39'), findsOneWidget);

    // Scroll to the collapsed completed card and expand it.
    await tester.scrollUntilVisible(
      find.text('Completed (1)'),
      400,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Finished errand'), findsNothing);
    await tester.tap(find.text('Completed (1)'));
    await tester.pump();
    expect(find.text('Finished errand'), findsOneWidget);
  });
}
