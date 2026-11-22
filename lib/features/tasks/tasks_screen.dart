import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/tasks_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/routine_state.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/tasks/routines_view.dart';
import 'package:nm_flat/features/tasks/tasks_controller.dart';
import 'package:nm_flat/features/tasks/todos_view.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ui = ref.watch(tasksControllerProvider);
    final ctrl = ref.read(tasksControllerProvider.notifier);

    final routines = ref.watch(routinesProvider).value ?? const <RoutineRow>[];
    final todos = ref.watch(todosProvider).value ?? const <TodoRow>[];
    final people = ref.watch(taskPeopleProvider).value ?? const <TaskPerson>[];
    final today = ref.watch(todayDateProvider);

    final dueRoutinesCount = routines
        .where(
          (r) => routineState(
            lastDone: r.lastDone,
            everyDays: r.everyDays,
            today: today,
          ).isDue,
        )
        .length;
    final openTodosCount = todos.where((t) => !t.done).length;

    final staffIdsWithRoutines = {
      for (final r in routines)
        if (r.assigneeType == 'staff') r.assignee,
    };
    final visiblePeople = [
      for (final p in people)
        if (p.type == 'member' || staffIdsWithRoutines.contains(p.id)) p,
    ];
    final effectivePerson =
        ui.person != null && visiblePeople.any((p) => p.id == ui.person)
        ? ui.person
        : null;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          controller:
              ref.watch(tabScrollControllersProvider)[NestTab.tasks.index],
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            NestTopBar.tab(
              eyebrow: l10n.tasksEyebrow,
              title: l10n.tasksTitle,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: SegmentedTabs<String>(
                segments: [
                  ('routines', '⟳ ${l10n.tasksCleaningTab}', dueRoutinesCount),
                  ('todos', '✓ ${l10n.tasksTodosTab}', openTodosCount),
                ],
                selected: ui.tab,
                onChanged: ctrl.setTab,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  NestChip(
                    label: l10n.tasksEveryone,
                    selected: effectivePerson == null,
                    onTap: () => ctrl.setPerson(null),
                  ),
                  for (final p in visiblePeople) ...[
                    const SizedBox(width: 8),
                    NestChip(
                      label: personName(l10n, p),
                      leading: Avatar(
                        name: p.firstName,
                        color: p.color,
                        size: AvatarSize.s24,
                      ),
                      selected: effectivePerson == p.id,
                      onTap: () => ctrl.setPerson(p.id),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (ui.tab == 'routines')
              RoutinesView(person: effectivePerson)
            else
              TodosView(person: effectivePerson),
          ],
        ),
      ),
    );
  }
}
