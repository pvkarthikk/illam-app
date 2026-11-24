import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/tasks_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/routine_state.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/tasks/routine_sheet.dart';
import 'package:nm_flat/features/tasks/staff_share.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

String frequencyLabel(AppLocalizations l10n, int everyDays) =>
    switch (frequencyKind(everyDays)) {
      FrequencyKind.daily => l10n.tasksFreqDaily,
      FrequencyKind.weekly => l10n.tasksFreqWeekly,
      FrequencyKind.fortnightly => l10n.tasksFreqFortnightly,
      FrequencyKind.monthly => l10n.tasksFreqMonthly,
      FrequencyKind.every3Months => l10n.tasksFreqEvery3Months,
      FrequencyKind.everyNDays => l10n.tasksFreqEveryN(everyDays),
    };

class RoutinesView extends ConsumerWidget {
  const RoutinesView({super.key, this.person});

  final String? person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final allRoutines = ref.watch(routinesProvider).value ?? const <RoutineRow>[];
    final people = ref.watch(taskPeopleProvider).value ?? const <TaskPerson>[];
    final today = ref.watch(todayDateProvider);

    final byId = {for (final p in people) p.id: p};

    final staffStrips = <(TaskPerson, List<RoutineRow>)>[];
    for (final p in people) {
      if (p.type != 'staff') continue;
      if (person != null && person != p.id) continue;
      final dueJobs = <(RoutineRow, double)>[];
      for (final r in allRoutines) {
        if (r.assignee != p.id) continue;
        final st = routineState(
          lastDone: r.lastDone,
          everyDays: r.everyDays,
          today: today,
        );
        if (st.isDue) dueJobs.add((r, st.ratio));
      }
      if (dueJobs.isEmpty) continue;
      dueJobs.sort((a, b) {
        final cmp = a.$2.compareTo(b.$2);
        return cmp != 0 ? cmp : a.$1.name.compareTo(b.$1.name);
      });
      staffStrips.add((p, [for (final j in dueJobs) j.$1]));
    }

    final filtered = [
      for (final r in allRoutines)
        if (person == null || r.assignee == person)
          (
            row: r,
            st: routineState(
              lastDone: r.lastDone,
              everyDays: r.everyDays,
              today: today,
            ),
          ),
    ];
    filtered.sort((a, b) {
      final cmp = a.st.ratio.compareTo(b.st.ratio);
      return cmp != 0 ? cmp : a.row.name.compareTo(b.row.name);
    });

    final emptyWho = person == null
        ? l10n.tasksAnyone
        : (byId[person] != null
              ? personName(l10n, byId[person]!)
              : l10n.tasksAnyone);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (staff, jobs) in staffStrips) ...[
            StaffShareStrip(staff: staff, jobs: jobs),
            const SizedBox(height: 12),
          ],
          if (filtered.isEmpty)
            EmptyState(
              icon: Icons.cleaning_services_outlined,
              title: l10n.tasksNoRoutines,
              body: l10n.tasksNoRoutinesBody(emptyWho),
            )
          else
            NestCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < filtered.length; i++) ...[
                    if (i > 0) Container(height: 1, color: c.line),
                    _RoutineTile(
                      row: filtered[i].row,
                      state: filtered[i].st,
                      who: byId[filtered[i].row.assignee],
                      today: today,
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 16),
          NestButton(
            label: l10n.tasksNewRoutine,
            icon: Icons.add_rounded,
            kind: NestButtonKind.ghost,
            size: NestButtonSize.block,
            onPressed: () => showRoutineSheet(context),
          ),
        ],
      ),
    );
  }
}

class _RoutineTile extends ConsumerStatefulWidget {
  const _RoutineTile({
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
  ConsumerState<_RoutineTile> createState() => _RoutineTileState();
}

class _RoutineTileState extends ConsumerState<_RoutineTile> {
  bool _busy = false;

  @override
  void didUpdateWidget(covariant _RoutineTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.row.id != widget.row.id ||
        oldWidget.row.lastDone != widget.row.lastDone) {
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
    final state = _busy
        ? routineState(
            lastDone: today,
            everyDays: row.everyDays,
            today: today,
          )
        : widget.state;
    final whoLabel = who != null ? personName(l10n, who) : l10n.tasksAnyone;
    final avatarColor = who?.color ?? c.ink3;
    final avatarName = who?.firstName ?? whoLabel;

    final tagText = switch (state.label) {
      RoutineLabel.overdue => l10n.tasksOverdue(-state.left),
      RoutineLabel.dueToday => l10n.tasksDueToday,
      RoutineLabel.dueTomorrow => l10n.tasksDueTomorrow,
      RoutineLabel.inDays => l10n.tasksInDays(state.left),
    };
    final tagKind = switch (state.tone) {
      Tone.danger => NestTagKind.danger,
      Tone.accent => NestTagKind.accent,
      Tone.ok => NestTagKind.ok,
    };

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => showRoutineSheet(context, existing: row),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.name,
                          style: TextStyle(
                            fontFamily: NestText.sans,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontVariations: const [FontVariation.weight(700)],
                            height: 1.25,
                            color: c.ink,
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
                                l10n.tasksRoutineMeta(
                                  whoLabel,
                                  row.room,
                                  frequencyLabel(l10n, row.everyDays),
                                ),
                                style: NestText.meta13.copyWith(color: c.ink3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44),
                    child: NestButton(
                      label: l10n.tasksDone,
                      icon: Icons.check_rounded,
                      kind: NestButtonKind.ghost,
                      size: NestButtonSize.sm,
                      semanticLabel: l10n.tasksMarkDone(row.name),
                      onPressed: _busy
                          ? null
                          : () async {
                              final snackbar = ref.read(snackbarProvider);
                              final repo = ref.read(tasksRepoProvider);
                              setState(() => _busy = true);
                              try {
                                final res = await repo.markRoutineDone(
                                  row.id,
                                  today,
                                );
                                if (res.undo == null && mounted) {
                                  setState(() => _busy = false);
                                }
                                snackbar.show(
                                  l10n.tasksRoutineDone(
                                    row.name,
                                    row.everyDays,
                                  ),
                                  undo: res.undo,
                                );
                              } catch (_) {
                                if (mounted) {
                                  setState(() => _busy = false);
                                }
                              }
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: l10n.tasksFreshness,
                      child: FreshnessBar(ratio: state.ratio),
                    ),
                  ),
                  const SizedBox(width: 12),
                  NestTag(label: tagText, kind: tagKind),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
