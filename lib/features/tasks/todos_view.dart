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

class GroupedTodos {
  const GroupedTodos({
    required this.open,
    required this.done,
    required this.hasOpen,
  });

  final Map<TodoGroup, List<TodoRow>> open;
  final List<TodoRow> done;
  final bool hasOpen;
}

final groupedTodosProvider = Provider.family<GroupedTodos, String?>((
  ref,
  filterId,
) {
  final allTodos = ref.watch(todosProvider).value ?? const <TodoRow>[];
  final doneRows = ref.watch(doneTodosProvider).value ?? const <TodoRow>[];
  final today = ref.watch(todayDateProvider);
  final grouped = <TodoGroup, List<TodoRow>>{
    for (final g in TodoGroup.values) g: <TodoRow>[],
  };
  final doneTodos = <TodoRow>[];
  for (final t in allTodos) {
    if (filterId != null && t.assignee != filterId) continue;
    if (t.done) {
      doneTodos.add(t);
    } else {
      grouped[todoGroup(t.due, today)]!.add(t);
    }
  }
  for (final t in doneRows) {
    if (filterId != null && t.assignee != filterId) continue;
    doneTodos.add(t);
  }
  for (final list in grouped.values) {
    list.sort((a, b) {
      final cmp = a.due.compareTo(b.due);
      return cmp != 0 ? cmp : a.title.compareTo(b.title);
    });
  }
  doneTodos.sort((a, b) => (b.doneAt ?? 0).compareTo(a.doneAt ?? 0));
  final hasOpen = grouped.values.any((list) => list.isNotEmpty);
  return GroupedTodos(open: grouped, done: doneTodos, hasOpen: hasOpen);
});

class TodosView extends ConsumerStatefulWidget {
  const TodosView({super.key, this.person});

  final String? person;

  @override
  ConsumerState<TodosView> createState() => _TodosViewState();
}

class _TodosViewState extends ConsumerState<TodosView> {
  bool _completedOpen = false;

  Future<bool> _toggleDone(TodoRow row, bool done) async {
    final l10n = AppLocalizations.of(context);
    final snackbar = ref.read(snackbarProvider);
    final repo = ref.read(tasksRepoProvider);
    final text = done ? l10n.tasksTodoDone(row.title) : l10n.tasksMovedBack;
    try {
      final res = await repo.setTodoDone(row.id, done);
      snackbar.show(text, undo: res.undo);
      return res.undo != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final data = ref.watch(groupedTodosProvider(widget.person));
    final byId = ref.watch(taskPeopleByIdProvider);
    final today = ref.watch(todayDateProvider);

    final filterId = widget.person;
    final selectedName = filterId != null && byId[filterId] != null
        ? personName(l10n, byId[filterId]!)
        : '';

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          if (!data.hasOpen)
            SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.task_alt_rounded,
                title: l10n.tasksAllDone,
                body: filterId == null || selectedName.isEmpty
                    ? l10n.tasksNothingPending
                    : l10n.tasksNothingPendingFor(selectedName),
              ),
            )
          else
            for (final group in TodoGroup.values)
              if (data.open[group]!.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _GroupHeader(
                    title: switch (group) {
                      TodoGroup.overdue => l10n.tasksGroupOverdue,
                      TodoGroup.today => l10n.tasksGroupToday,
                      TodoGroup.tomorrow => l10n.tasksGroupTomorrow,
                      TodoGroup.later => l10n.tasksGroupLater,
                    },
                    count: data.open[group]!.length,
                    danger: group == TodoGroup.overdue,
                  ),
                ),
                DecoratedSliver(
                  decoration: NestCard.cardDecoration(context),
                  sliver: SliverPadding(
                    padding: const EdgeInsets.all(1),
                    sliver: SliverList.builder(
                      itemCount: data.open[group]!.length,
                      itemBuilder: (context, i) {
                        final row = data.open[group]![i];
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (i > 0) Container(height: 1, color: c.line),
                            _TodoTile(
                              row: row,
                              who: byId[row.assignee],
                              today: today,
                              completed: false,
                              onCheck: () => _toggleDone(row, true),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
          if (data.done.isNotEmpty) ...[
            if (!data.hasOpen)
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
            DecoratedSliver(
              decoration: NestCard.cardDecoration(context),
              sliver: SliverPadding(
                padding: const EdgeInsets.all(1),
                sliver: SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Material(
                        type: MaterialType.transparency,
                        child: Semantics(
                          button: true,
                          expanded: _completedOpen,
                          child: InkWell(
                            onTap: () => setState(
                              () => _completedOpen = !_completedOpen,
                            ),
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
                                        l10n.tasksCompleted(data.done.length),
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
                      ),
                    ),
                    if (_completedOpen)
                      SliverList.builder(
                        itemCount: data.done.length,
                        itemBuilder: (context, i) {
                          final t = data.done[i];
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(height: 1, color: c.line),
                              _TodoTile(
                                row: t,
                                who: byId[t.assignee],
                                today: today,
                                completed: true,
                                onCheck: () => _toggleDone(t, false),
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
          SliverToBoxAdapter(
            child: NestButton(
              label: l10n.tasksNewTodo,
              icon: Icons.add_rounded,
              kind: NestButtonKind.ghost,
              size: NestButtonSize.block,
              onPressed: () => showTodoSheet(context),
            ),
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

class _TodoTile extends StatefulWidget {
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
  final Future<bool> Function() onCheck;

  @override
  State<_TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<_TodoTile> {
  bool _busy = false;

  @override
  void didUpdateWidget(covariant _TodoTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.row.id != widget.row.id ||
        oldWidget.completed != widget.completed) {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final row = widget.row;
    final who = widget.who;
    final today = widget.today;
    final shownCompleted = widget.completed != _busy;
    final whoLabel = who != null ? personName(l10n, who) : l10n.tasksAnyone;
    final avatarColor = who?.color ?? c.ink3;
    final avatarName = who?.firstName ?? whoLabel;
    final meta = row.due.isEmpty
        ? whoLabel
        : l10n.tasksTodoMeta(
            '📅 ${Formatters.dayLabel(row.due, today, l10n)}',
            whoLabel,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RoundCheck(
            value: shownCompleted,
            semanticLabel: shownCompleted
                ? l10n.tasksReopenTodo(row.title)
                : l10n.tasksCompleteTodo(row.title),
            onChanged: (_) async {
              if (_busy) return;
              setState(() => _busy = true);
              final ok = await widget.onCheck();
              if (!ok && mounted) {
                setState(() => _busy = false);
              }
            },
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
                        color: shownCompleted ? c.ink3 : c.ink,
                        decoration: shownCompleted
                            ? TextDecoration.lineThrough
                            : null,
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
                            meta,
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
