import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/tasks_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/todo_dates.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/tasks/tasks_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showTodoSheet(
  BuildContext context, {
  TodoRow? existing,
}) => showNestSheet<void>(
  context,
  (_) => _TodoSheet(existing: existing),
);

class _TodoSheet extends ConsumerStatefulWidget {
  const _TodoSheet({this.existing});

  final TodoRow? existing;

  @override
  ConsumerState<_TodoSheet> createState() => _TodoSheetState();
}

class _TodoSheetState extends ConsumerState<_TodoSheet> {
  final _titleCtrl = TextEditingController();
  late String _due;
  String? _assigneeId;
  String? _titleError;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    if (ex != null) {
      _titleCtrl.text = ex.title;
      _due = ex.due.isEmpty ? ref.read(todayDateProvider) : ex.due;
      _assigneeId = ex.assignee;
    } else {
      _due = ref.read(todayDateProvider);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  (String id, String type) _resolvedAssignee(List<TaskPerson> people) {
    final targetId = _assigneeId ?? ref.read(myMemberIdProvider);
    for (final p in people) {
      if (p.id == targetId) return (p.id, p.type);
    }
    if (_isEdit && _assigneeId != null && _assigneeId!.isNotEmpty) {
      return (_assigneeId!, widget.existing!.assigneeType);
    }
    for (final p in people) {
      if (p.isMe) return (p.id, p.type);
    }
    if (people.isNotEmpty) return (people.first.id, people.first.type);
    return (ref.read(myMemberIdProvider), 'member');
  }

  String _capitalise(String s) {
    final t = s.trim();
    if (t.isEmpty) return t;
    return t[0].toUpperCase() + t.substring(1);
  }

  Future<void> _pickDate(String today) async {
    final todayDt = Dates.parse(today);
    final dueDt = Dates.parse(_due);
    final firstDate = dueDt.isBefore(todayDt) ? dueDt : todayDt;
    final lastDate = DateTime(todayDt.year + 5, todayDt.month, todayDt.day);
    final initialDate = dueDt.isAfter(lastDate) ? lastDate : dueDt;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null && mounted) {
      setState(() => _due = Dates.iso(picked));
    }
  }

  Future<void> _save(AppLocalizations l10n, List<TaskPerson> people) async {
    if (_saving) return;
    final raw = _titleCtrl.text.trim();
    if (raw.isEmpty) {
      setState(() => _titleError = l10n.tasksTodoRequired);
      return;
    }
    final title = _capitalise(raw);
    final (assigneeId, assigneeType) = _resolvedAssignee(people);

    setState(() => _saving = true);
    try {
      final repo = ref.read(tasksRepoProvider);
      final ex = widget.existing;
      if (ex == null) {
        final res = await repo.createTodo(
          title: title,
          due: _due,
          assigneeType: assigneeType,
          assignee: assigneeId,
        );
        if (!mounted) return;
        Navigator.of(context).pop();
        ref.read(snackbarProvider).show(l10n.tasksTodoAdded, undo: res.undo);
        ref.read(tasksControllerProvider.notifier).setTab('todos');
      } else {
        final diff = <String, Object?>{
          if (title != ex.title) 'title': title,
          if (_due != ex.due) 'due': _due,
          if (assigneeType != ex.assigneeType) 'assignee_type': assigneeType,
          if (assigneeId != ex.assignee) 'assignee': assigneeId,
        };
        if (diff.isEmpty) {
          Navigator.of(context).pop();
          return;
        }
        final res = await repo.updateTodo(ex.id, diff);
        if (!mounted) return;
        Navigator.of(context).pop();
        ref.read(snackbarProvider).show(l10n.tasksTodoUpdated, undo: res.undo);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(AppLocalizations l10n) async {
    final ex = widget.existing;
    if (ex == null || _saving) return;
    setState(() => _saving = true);
    try {
      final res = await ref.read(tasksRepoProvider).deleteTodo(ex.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      ref.read(snackbarProvider).show(l10n.tasksTodoDeleted, undo: res.undo);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final today = ref.watch(todayDateProvider);
    final w = whenDates(today);
    final people = ref.watch(taskPeopleProvider).value ?? const <TaskPerson>[];
    final (selectedAssignee, _) = _resolvedAssignee(people);

    final whenChips = [
      (w.today, l10n.tasksToday),
      (w.tomorrow, l10n.tasksTomorrow),
      (w.weekend, l10n.tasksWeekend),
      (w.nextWeek, l10n.tasksNextWeek),
    ];
    final isPresetDate = whenChips.any((entry) => entry.$1 == _due);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(
          title: _isEdit ? l10n.tasksEditTodo : l10n.tasksNewTodo,
        ),
        TextField(
          controller: _titleCtrl,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) {
            if (_titleError != null) setState(() => _titleError = null);
          },
          decoration: InputDecoration(
            labelText: l10n.tasksWhat,
            hintText: l10n.tasksTodoPlaceholder,
            errorText: _titleError,
          ),
        ),
        const SizedBox(height: 16),
        Text(l10n.tasksWhen, style: NestText.small12.copyWith(color: c.ink2)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final (date, label) in whenChips)
              NestChip(
                label: label,
                selected: _due == date,
                onTap: () => setState(() => _due = date),
              ),
            NestChip(
              label: isPresetDate
                  ? l10n.tasksPickDate
                  : Formatters.dayLabel(_due, today, l10n),
              selected: !isPresetDate,
              onTap: () => _pickDate(today),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(l10n.tasksWho, style: NestText.small12.copyWith(color: c.ink2)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final p in people)
              NestChip(
                label: personName(l10n, p),
                leading: Avatar(
                  name: p.firstName,
                  color: p.color,
                  size: AvatarSize.s24,
                ),
                selected: selectedAssignee == p.id,
                onTap: () => setState(() => _assigneeId = p.id),
              ),
          ],
        ),
        const SizedBox(height: 20),
        NestButton(
          label: _isEdit ? l10n.tasksSaveChanges : l10n.tasksAddTodo,
          kind: NestButtonKind.primary,
          size: NestButtonSize.block,
          onPressed: _saving ? null : () => _save(l10n, people),
        ),
        if (_isEdit) ...[
          const SizedBox(height: 10),
          NestButton(
            label: l10n.tasksDeleteTodo,
            kind: NestButtonKind.dangerGhost,
            size: NestButtonSize.block,
            onPressed: _saving ? null : () => _delete(l10n),
          ),
        ],
      ],
    );
  }
}
