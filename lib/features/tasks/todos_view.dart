import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/tasks_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/todo_dates.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/tasks/todo_sheet.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class TodosView extends ConsumerStatefulWidget {
  const TodosView({super.key, this.person});

  final String? person;

  @override
  ConsumerState<TodosView> createState() => _TodosViewState();
}

class _TodosViewState extends ConsumerState<TodosView> {
  bool _completedOpen = false;

  Future<void> _toggleDone(TodoRow row, bool done) async {
    final l10n = AppLocalizations.of(context);
    final res = await ref.read(tasksRepoProvider).setTodoDone(row.id, done);
    if (!mounted) return;
    ref
        .read(snackbarProvider)
        .show(
          done ? l10n.tasksTodoDone(row.title) : l10n.tasksMovedBack,
          undo: res.undo,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final allTodos = ref.watch(todosProvider).value ?? const <TodoRow>[];
    final people = ref.watch(taskPeopleProvider).value ?? const <TaskPerson>[];
    final today = ref.watch(todayDateProvider);

    final byId = {for (final p in people) p.id: p};
    final filterId = widget.person;
    final filtered = [
      for (final t in allTodos)
        if (filterId == null || t.assignee == filterId) t,
    ];

    final grouped = <TodoGroup, List<TodoRow>>{
      for (final g in TodoGroup.values) g: [],
    };
    final doneTodos = <TodoRow>[];
    for (final t in filtered) {
      if (t.done) {
        doneTodos.add(t);
      } else {
        grouped[todoGroup(t.due, today)]!.add(t);
      }
    }
    for (final list in grouped.values) {
      list.sort((a, b) {
        final cmp = a.due.compareTo(b.due);
        return cmp != 0 ? cmp : a.title.compareTo(b.title);
      });
    }
    doneTodos.sort((a, b) => (b.doneAt ?? 0).compareTo(a.doneAt ?? 0));

    final hasOpen = grouped.values.any((list) => list.isNotEmpty);
    final selectedName = filterId != null && byId[filterId] != null
        ? personName(l10n, byId[filterId]!)
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!hasOpen)
            EmptyState(
              icon: Icons.task_alt_rounded,
              title: l10n.tasksAllDone,
              body: filterId == null || selectedName.isEmpty
                  ? l10n.tasksNothingPending
                  : l10n.tasksNothingPendingFor(selectedName),
            )
          else
            for (final group in TodoGroup.values)
              if (grouped[group]!.isNotEmpty) ...[
                _GroupHeader(
                  title: switch (group) {
                    TodoGroup.overdue => l10n.tasksGroupOverdue,
                    TodoGroup.today => l10n.tasksGroupToday,
                    TodoGroup.tomorrow => l10n.tasksGroupTomorrow,
                    TodoGroup.later => l10n.tasksGroupLater,
                  },
                  count: grouped[group]!.length,
                  danger: group == TodoGroup.overdue,
                ),
                NestCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < grouped[group]!.length; i++) ...[
                        if (i > 0) Container(height: 1, color: c.line),
                        _TodoTile(
                          row: grouped[group]![i],
                          who: byId[grouped[group]![i].assignee],
                          today: today,
                          completed: false,
                          onCheck: () =>
                              _toggleDone(grouped[group]![i], true),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
          if (doneTodos.isNotEmpty) ...[
            if (!hasOpen) const SizedBox(height: 8),
            NestCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    button: true,
                    expanded: _completedOpen,
                    child: InkWell(
                      onTap: () =>
                          setState(() => _completedOpen = !_completedOpen),
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
                                  l10n.tasksCompleted(doneTodos.length),
                                  style: TextStyle(
                                    fontFamily: NestText.sans,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    fontVariations: const [
                                      FontVariation.weight(600),
                                    ],
                                    color: c.ink2,
                                  ),
                                ),
                              ),
                              Icon(
                                _completedOpen
                                    ? Icons.expand_less_rounded
                                    : Icons.expand_more_rounded,
                                color: c.ink3,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_completedOpen)
                    for (final t in doneTodos) ...[
                      Container(height: 1, color: c.line),
                      _TodoTile(
                        row: t,
                        who: byId[t.assignee],
                        today: today,
                        completed: true,
                        onCheck: () => _toggleDone(t, false),
                      ),
                    ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          NestButton(
            label: l10n.tasksNewTodo,
            icon: Icons.add_rounded,
            kind: NestButtonKind.ghost,
            size: NestButtonSize.block,
            onPressed: () => showTodoSheet(context),
          ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.title,
    required this.count,
    required this.danger,
  });

  final String title;
  final int count;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title.toUpperCase(),
                  style: NestText.section13.copyWith(
                    color: danger ? c.danger : c.ink2,
                  ),
                ),
              ),
            ),
            Text(
              '$count',
              style: NestText.small12.copyWith(
                color: danger ? c.danger : c.ink3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  const _TodoTile({
    required this.row,
    required this.who,
    required this.today,
    required this.completed,
    required this.onCheck,
  });

  final TodoRow row;
  final TaskPerson? who;
  final String today;
  final bool completed;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final whoLabel = who != null ? personName(l10n, who!) : l10n.tasksAnyone;
    final avatarColor = who?.color ?? c.ink3;
    final avatarName = who?.firstName ?? whoLabel;
    final day = '📅 ${Formatters.dayLabel(row.due, today, l10n)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RoundCheck(
            value: completed,
            semanticLabel: completed
                ? l10n.tasksReopenTodo(row.title)
                : l10n.tasksCompleteTodo(row.title),
            onChanged: (_) => onCheck(),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => showTodoSheet(context, existing: row),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.title,
                      style: NestText.itemTitle16.copyWith(
                        color: completed ? c.ink3 : c.ink,
                        decoration:
                            completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 6),
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
                            l10n.tasksTodoMeta(day, whoLabel),
                            style: NestText.meta13.copyWith(color: c.ink3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
