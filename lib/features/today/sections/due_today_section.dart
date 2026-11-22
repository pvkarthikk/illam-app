import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/tasks_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/routine_state.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class DueTodaySection extends ConsumerWidget {
  const DueTodaySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final routines = ref.watch(routinesProvider).value ?? const <RoutineRow>[];
    final todos = ref.watch(todosProvider).value ?? const <TodoRow>[];
    final people = ref.watch(taskPeopleProvider).value ?? const <TaskPerson>[];
    final today = ref.watch(todayDateProvider);

    final byId = {for (final p in people) p.id: p};

    final dueTodos = [
      for (final t in todos)
        if (!t.done &&
            t.due.isNotEmpty &&
            Dates.daysBetween(t.due, today) >= 0)
          t,
    ]..sort((a, b) {
        final cmp = a.due.compareTo(b.due);
        return cmp != 0 ? cmp : a.title.compareTo(b.title);
      });

    final dueRoutines = [
      for (final r in routines)
        if (routineState(
              lastDone: r.lastDone,
              everyDays: r.everyDays,
              today: today,
            ).left <=
            0)
          (
            row: r,
            st: routineState(
              lastDone: r.lastDone,
              everyDays: r.everyDays,
              today: today,
            ),
          ),
    ]..sort((a, b) {
        final cmp = a.st.left.compareTo(b.st.left);
        return cmp != 0 ? cmp : a.row.name.compareTo(b.row.name);
      });

    final total = dueTodos.length + dueRoutines.length;
    final rows = <Widget>[];
    for (final t in dueTodos) {
      if (rows.length == 5) break;
      rows.add(_DueTodoRow(row: t, who: byId[t.assignee], today: today));
    }
    for (final item in dueRoutines) {
      if (rows.length == 5) break;
      rows.add(
        _DueRoutineRow(
          row: item.row,
          state: item.st,
          who: byId[item.row.assignee],
          today: today,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        SectionHeader(
          title: l10n.todayDueToday,
          actionLabel: l10n.todayAllTasks,
          onAction: () => context.go(Routes.tasks),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: total == 0
              ? NestCard(
                  child: EmptyState(
                    icon: Icons.wb_sunny_outlined,
                    title: l10n.todayNothingDue,
                    body: l10n.todayEnjoyQuiet,
                  ),
                )
              : NestCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < rows.length; i++) ...[
                        if (i > 0) Container(height: 1, color: c.line),
                        rows[i],
                      ],
                      if (total > 5) ...[
                        Container(height: 1, color: c.line),
                        InkWell(
                          onTap: () => context.go(Routes.tasks),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 48),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      l10n.todayMoreDue(total - 5),
                                      style: NestText.meta13.copyWith(
                                        color: c.primary,
                                        fontWeight: FontWeight.w600,
                                        fontVariations: const [
                                          FontVariation.weight(600),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18,
                                    color: c.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _DueTodoRow extends ConsumerWidget {
  const _DueTodoRow({
    required this.row,
    required this.who,
    required this.today,
  });

  final TodoRow row;
  final TaskPerson? who;
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final whoLabel = who != null ? personName(l10n, who!) : l10n.tasksAnyone;
    final avatarColor = who?.color ?? c.ink3;
    final avatarName = who?.firstName ?? whoLabel;
    final overdue = Dates.daysBetween(row.due, today) > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RoundCheck(
            value: false,
            semanticLabel: l10n.tasksCompleteTodo(row.title),
            onChanged: (_) async {
              final res = await ref
                  .read(tasksRepoProvider)
                  .setTodoDone(row.id, true);
              if (!context.mounted) return;
              ref
                  .read(snackbarProvider)
                  .show(l10n.tasksTodoDone(row.title), undo: res.undo);
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.title,
                    style: NestText.itemTitle16.copyWith(color: c.ink),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Avatar(
                        name: avatarName,
                        color: avatarColor,
                        size: AvatarSize.s24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$whoLabel · ${l10n.todayTodoKind}',
                          style: NestText.meta13.copyWith(color: c.ink3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (overdue) ...[
            const SizedBox(width: 8),
            NestTag(
              label: Formatters.dayLabel(row.due, today, l10n),
              kind: NestTagKind.danger,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _DueRoutineRow extends ConsumerWidget {
  const _DueRoutineRow({
    required this.row,
    required this.state,
    required this.who,
    required this.today,
  });

  final RoutineRow row;
  final RoutineState state;
  final TaskPerson? who;
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final whoLabel = who != null ? personName(l10n, who!) : l10n.tasksAnyone;
    final overdue = state.left < 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          NestCheckbox(
            value: false,
            semanticLabel: l10n.tasksMarkDone(row.name),
            onChanged: (_) async {
              final res = await ref
                  .read(tasksRepoProvider)
                  .markRoutineDone(row.id, today);
              if (!context.mounted) return;
              ref
                  .read(snackbarProvider)
                  .show(
                    l10n.tasksRoutineDone(row.name, row.everyDays),
                    undo: res.undo,
                  );
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.name,
                    style: NestText.itemTitle16.copyWith(color: c.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$whoLabel · ${row.room}',
                    style: NestText.meta13.copyWith(color: c.ink3),
                  ),
                ],
              ),
            ),
          ),
          if (overdue) ...[
            const SizedBox(width: 8),
            NestTag(
              label: l10n.tasksOverdue(-state.left),
              kind: NestTagKind.danger,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
