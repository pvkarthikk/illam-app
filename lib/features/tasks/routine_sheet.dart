import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/tasks_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/tasks/tasks_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showRoutineSheet(
  BuildContext context, {
  RoutineRow? existing,
}) => showNestSheet<void>(
  context,
  (_) => _RoutineSheet(existing: existing),
);

const _roomKeys = [
  'Kitchen',
  'Living room',
  'Bedrooms',
  'Bathrooms',
  'Balcony',
  'Whole house',
];

const _freqPresets = [1, 2, 3, 7, 14, 30, 90];

class _RoutineSheet extends ConsumerStatefulWidget {
  const _RoutineSheet({this.existing});

  final RoutineRow? existing;

  @override
  ConsumerState<_RoutineSheet> createState() => _RoutineSheetState();
}

class _RoutineSheetState extends ConsumerState<_RoutineSheet> {
  final _nameCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();
  final _daysCtrl = TextEditingController();

  late String _roomChoice;
  int? _freqChoice;
  String? _assigneeId;
  String? _nameError;
  String? _daysError;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    if (ex != null) {
      _nameCtrl.text = ex.name;
      if (_roomKeys.contains(ex.room)) {
        _roomChoice = ex.room;
      } else {
        _roomChoice = '_other';
        _roomCtrl.text = ex.room;
      }
      if (_freqPresets.contains(ex.everyDays)) {
        _freqChoice = ex.everyDays;
      } else {
        _freqChoice = null;
        _daysCtrl.text = '${ex.everyDays}';
      }
      _assigneeId = ex.assignee;
    } else {
      _roomChoice = 'Kitchen';
      _freqChoice = 7;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roomCtrl.dispose();
    _daysCtrl.dispose();
    super.dispose();
  }

  String _resolvedAssigneeId(List<TaskPerson> people) {
    if (_assigneeId != null &&
        (_isEdit || people.any((p) => p.id == _assigneeId))) {
      return _assigneeId!;
    }
    if (!_isEdit) {
      for (final p in people) {
        if (p.type == 'staff') return p.id;
      }
      for (final p in people) {
        if (p.isMe) return p.id;
      }
    }
    return people.isNotEmpty ? people.first.id : ref.read(myMemberIdProvider);
  }

  String _capitalise(String s) {
    final t = s.trim();
    if (t.isEmpty) return t;
    return t[0].toUpperCase() + t.substring(1);
  }

  Future<void> _save(AppLocalizations l10n, List<TaskPerson> people) async {
    if (_saving) return;
    final rawName = _nameCtrl.text.trim();
    if (rawName.isEmpty) {
      setState(() => _nameError = l10n.tasksNameRequired);
      return;
    }
    final int everyDays;
    if (_freqChoice != null) {
      everyDays = _freqChoice!;
    } else {
      final parsed = int.tryParse(_daysCtrl.text.trim());
      if (parsed == null || parsed < 1 || parsed > 365) {
        setState(() => _daysError = l10n.tasksDaysRange);
        return;
      }
      everyDays = parsed;
    }

    final room = _roomChoice == '_other'
        ? (_roomCtrl.text.trim().isEmpty ? 'Kitchen' : _roomCtrl.text.trim())
        : _roomChoice;
    final name = _capitalise(rawName);

    final assigneeId = _resolvedAssigneeId(people);
    var assigneeType = widget.existing?.assigneeType ?? 'member';
    for (final p in people) {
      if (p.id == assigneeId) {
        assigneeType = p.type;
        break;
      }
    }

    setState(() => _saving = true);
    var closed = false;
    try {
      final repo = ref.read(tasksRepoProvider);
      final snack = ref.read(snackbarProvider);
      final ctrl = ref.read(tasksControllerProvider.notifier);
      final ex = widget.existing;
      if (ex == null) {
        final today = ref.read(todayDateProvider);
        closed = true;
        Navigator.of(context).pop();
        try {
          final res = await repo.createRoutine(
            name: name,
            room: room,
            everyDays: everyDays,
            assigneeType: assigneeType,
            assignee: assigneeId,
            today: today,
          );
          snack.show(l10n.tasksRoutineAdded, undo: res.undo);
          ctrl.setTab('routines');
        } on Object {
          snack.show(rejectText('other'));
        }
      } else {
        final diff = <String, Object?>{
          if (name != ex.name) 'name': name,
          if (room != ex.room) 'room': room,
          if (everyDays != ex.everyDays) 'every_days': everyDays,
          if (assigneeType != ex.assigneeType) 'assignee_type': assigneeType,
          if (assigneeId != ex.assignee) 'assignee': assigneeId,
        };
        if (diff.isEmpty) {
          closed = true;
          Navigator.of(context).pop();
          return;
        }
        final exId = ex.id;
        closed = true;
        Navigator.of(context).pop();
        try {
          final res = await repo.updateRoutine(exId, diff);
          snack.show(l10n.tasksRoutineUpdated, undo: res.undo);
        } on Object {
          snack.show(rejectText('other'));
        }
      }
    } finally {
      if (!closed && mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(AppLocalizations l10n) async {
    final ex = widget.existing;
    if (ex == null || _saving) return;
    setState(() => _saving = true);
    try {
      final res = await ref.read(tasksRepoProvider).deleteRoutine(ex.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      ref.read(snackbarProvider).show(l10n.tasksRoutineDeleted, undo: res.undo);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final people = ref.watch(taskPeopleProvider).value ?? const <TaskPerson>[];
    final selectedAssignee = _resolvedAssigneeId(people);

    final rooms = [
      ('Kitchen', l10n.tasksRoomKitchen),
      ('Living room', l10n.tasksRoomLiving),
      ('Bedrooms', l10n.tasksRoomBedrooms),
      ('Bathrooms', l10n.tasksRoomBathrooms),
      ('Balcony', l10n.tasksRoomBalcony),
      ('Whole house', l10n.tasksRoomWhole),
    ];
    final freqs = [
      (1, l10n.tasksFreqDaily),
      (2, l10n.tasksEvery2),
      (3, l10n.tasksEvery3),
      (7, l10n.tasksFreqWeekly),
      (14, l10n.tasksFreqFortnightly),
      (30, l10n.tasksFreqMonthly),
      (90, l10n.tasksFreqEvery3Months),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(
          title: _isEdit ? l10n.tasksEditRoutineTitle : l10n.tasksNewRoutineTitle,
          lead: _isEdit ? null : l10n.tasksRoutineLead,
        ),
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) {
            if (_nameError != null) setState(() => _nameError = null);
          },
          decoration: InputDecoration(
            labelText: l10n.tasksWhatNeedsDoing,
            hintText: l10n.tasksRoutinePlaceholder,
            errorText: _nameError,
          ),
        ),
        const SizedBox(height: 16),
        Text(l10n.tasksWhere, style: NestText.small12.copyWith(color: c.ink2)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final (key, label) in rooms)
              NestChip(
                label: label,
                selected: _roomChoice == key,
                onTap: () => setState(() => _roomChoice = key),
              ),
            NestChip(
              label: l10n.tasksOther,
              selected: _roomChoice == '_other',
              onTap: () => setState(() => _roomChoice = '_other'),
            ),
          ],
        ),
        if (_roomChoice == '_other') ...[
          const SizedBox(height: 10),
          TextField(
            controller: _roomCtrl,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l10n.tasksRoomName),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          l10n.tasksHowOften,
          style: NestText.small12.copyWith(color: c.ink2),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final (days, label) in freqs)
              NestChip(
                label: label,
                selected: _freqChoice == days,
                onTap: () => setState(() {
                  _freqChoice = days;
                  _daysError = null;
                }),
              ),
            NestChip(
              label: l10n.tasksCustom,
              selected: _freqChoice == null,
              onTap: () => setState(() => _freqChoice = null),
            ),
          ],
        ),
        if (_freqChoice == null) ...[
          const SizedBox(height: 10),
          TextField(
            controller: _daysCtrl,
            keyboardType: TextInputType.number,
            onChanged: (_) {
              if (_daysError != null) setState(() => _daysError = null);
            },
            decoration: InputDecoration(
              labelText: l10n.tasksEveryHowMany,
              errorText: _daysError,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          l10n.tasksWhoDoesIt,
          style: NestText.small12.copyWith(color: c.ink2),
        ),
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
          label: _isEdit ? l10n.tasksSaveChanges : l10n.tasksAddRoutine,
          kind: NestButtonKind.primary,
          size: NestButtonSize.block,
          onPressed: _saving ? null : () => _save(l10n, people),
        ),
        if (_isEdit) ...[
          const SizedBox(height: 10),
          NestButton(
            label: l10n.tasksDeleteRoutine,
            kind: NestButtonKind.dangerGhost,
            size: NestButtonSize.block,
            onPressed: _saving ? null : () => _delete(l10n),
          ),
        ],
      ],
    );
  }
}
