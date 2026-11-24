import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/domain/staff_text.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';
import 'package:nm_flat/features/staff/widgets/staff_row.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showEditStaffSheet(BuildContext context, StaffData s) =>
    showNestSheet<void>(context, (_) => _EditStaffForm(staff: s));

class _EditStaffForm extends ConsumerStatefulWidget {
  const _EditStaffForm({required this.staff});

  final StaffData staff;

  @override
  ConsumerState<_EditStaffForm> createState() => _EditStaffFormState();
}

class _EditStaffFormState extends ConsumerState<_EditStaffForm> {
  static const _roles = ['House help', 'Cook', 'Driver', 'Nanny', 'Gardener'];

  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _upi;
  late String _role;
  late Set<int> _days;
  late List<String> _times;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.staff;
    _name = TextEditingController(text: s.name ?? '');
    final phone = s.phoneE164 ?? '';
    _phone = TextEditingController(
      text: phone.startsWith('+91') ? phone.substring(3) : phone,
    );
    _upi = TextEditingController(text: s.upiId ?? '');
    _role = s.role ?? 'House help';
    final curMonth = Dates.month(Dates.today(ref.read(clockProvider)));
    final rule = ref
        .read(salaryViewProvider((s.id, curMonth)))
        .value
        ?.payroll
        .rules;
    final parsedDays = (rule?.workDays ?? parseWorkDays(s.workDays)).toSet();
    _days = parsedDays.isEmpty ? {1, 2, 3, 4, 5, 6} : parsedDays;
    final parsedTimes = parseTimes(s.expectedTimes);
    _times = parsedTimes.isEmpty ? ['09:00'] : parsedTimes.take(2).toList();
    _times.sort();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _upi.dispose();
    super.dispose();
  }

  Future<String?> _pickTimeString(String initialHhmm) async {
    final p = initialHhmm.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(p[0]) ?? 9,
      minute: int.tryParse(p.length > 1 ? p[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return null;
    return '${picked.hour.toString().padLeft(2, '0')}:'
        '${picked.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _editTime(int index) async {
    final picked = await _pickTimeString(_times[index]);
    if (picked == null || !mounted) return;
    setState(() {
      _times[index] = picked;
      _times.sort();
    });
  }

  Future<void> _addSecondTime() async {
    final picked = await _pickTimeString('18:00');
    if (picked == null || !mounted) return;
    setState(() {
      _times.add(picked);
      _times.sort();
    });
  }

  Future<void> _save(AppLocalizations l10n, String? e164) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final upi = _upi.text.trim();
      final res = await ref.read(staffRepoProvider).updateDetails(
        widget.staff.id,
        {
          'name': Names.titleCase(_name.text),
          'role': _role,
          'phone_e164': e164,
          'upi_id': upi.isEmpty ? null : upi,
          'work_days': workDaysCsv(_days.toList()),
          'expected_times': (_times..sort()).join(','),
        },
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ref.read(snackbarProvider).show(l10n.staffDetailsSaved, undo: res.undo);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final dayLabels = [
      l10n.weekdayShortMon,
      l10n.weekdayShortTue,
      l10n.weekdayShortWed,
      l10n.weekdayShortThu,
      l10n.weekdayShortFri,
      l10n.weekdayShortSat,
      l10n.weekdayShortSun,
    ];
    final phoneTrimmed = _phone.text.trim();
    final e164 = phoneTrimmed.isEmpty
        ? null
        : IndianMobile.toE164(phoneTrimmed);
    final phoneError = phoneTrimmed.isNotEmpty && e164 == null
        ? l10n.staffPhoneInvalid
        : null;
    final canSave =
        !_saving && _name.text.trim().isNotEmpty && phoneError == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(title: l10n.staffEditDetails),
        TextField(
          controller: _name,
          maxLength: 30,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l10n.staffName),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Text(l10n.staffRole, style: NestText.meta13.copyWith(color: c.ink3)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final r in _roles)
              NestChip(
                label: roleLabel(l10n, r),
                selected: _role == r,
                onTap: () => setState(() => _role = r),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(l10n.staffMobile, style: NestText.meta13.copyWith(color: c.ink3)),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.paper2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+91',
                style: NestText.body16.copyWith(color: c.ink2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: InputDecoration(errorText: phoneError),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _upi,
          decoration: InputDecoration(labelText: l10n.staffUpi),
        ),
        const SizedBox(height: 14),
        Text(
          l10n.staffWorkDays,
          style: NestText.meta13.copyWith(color: c.ink3),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (var i = 0; i < 7; i++)
              NestChip(
                label: dayLabels[i],
                selected: _days.contains(i + 1),
                onTap: () => setState(() {
                  final day = i + 1;
                  if (_days.contains(day)) {
                    if (_days.length > 1) _days.remove(day);
                  } else {
                    _days.add(day);
                  }
                }),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          l10n.staffUsuallyAt,
          style: NestText.meta13.copyWith(color: c.ink3),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            NestButton(
              label: time12Of(_times[0]),
              kind: NestButtonKind.ghost,
              size: NestButtonSize.sm,
              onPressed: () => _editTime(0),
            ),
            if (_times.length == 1)
              NestButton(
                label: l10n.staffAddTime,
                kind: NestButtonKind.ghost,
                size: NestButtonSize.sm,
                onPressed: _addSecondTime,
              )
            else ...[
              NestButton(
                label: time12Of(_times[1]),
                kind: NestButtonKind.ghost,
                size: NestButtonSize.sm,
                onPressed: () => _editTime(1),
              ),
              IconButton(
                tooltip: l10n.commonRemove,
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(() => _times.removeAt(1)),
              ),
            ],
          ],
        ),
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.commonCancel,
              kind: NestButtonKind.ghost,
              onPressed: () => Navigator.of(context).pop(),
            ),
            NestButton(
              label: l10n.commonSave,
              kind: NestButtonKind.primary,
              onPressed: canSave ? () => _save(l10n, e164) : null,
            ),
          ],
        ),
      ],
    );
  }
}
