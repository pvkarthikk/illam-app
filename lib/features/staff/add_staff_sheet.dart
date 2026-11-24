import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/domain/staff_text.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/staff/widgets/staff_row.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showAddStaffSheet(BuildContext context) =>
    showNestSheet<void>(context, (_) => const _AddStaffForm());

class _AddStaffForm extends ConsumerStatefulWidget {
  const _AddStaffForm();

  @override
  ConsumerState<_AddStaffForm> createState() => _AddStaffFormState();
}

class _AddStaffFormState extends ConsumerState<_AddStaffForm> {
  static const _roles = ['House help', 'Cook', 'Driver', 'Nanny', 'Gardener'];
  static const _palette = [
    '#4F8A8B',
    '#8A5A2B',
    '#5E8A2B',
    '#A8362A',
    '#34508A',
  ];

  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _phone = TextEditingController();
  String _role = 'House help';
  String _payType = 'monthly';
  String _time = '09:00';
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final parts = _time.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;
    setState(() {
      _time =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _add(AppLocalizations l10n, int amountPaise, String? e164) async {
    if (_saving) return;
    setState(() => _saving = true);
    final repo = ref.read(staffRepoProvider);
    final snackbar = ref.read(snackbarProvider);
    final count = (ref.read(activeStaffProvider).value ?? const []).length;
    final color = _palette[count % _palette.length];
    final today = Dates.today(ref.read(clockProvider));
    final rawName = _name.text;
    Navigator.of(context).pop();
    try {
      final res = await repo.addStaff(
        name: rawName,
        role: _role,
        payType: _payType,
        amountPaise: amountPaise,
        expectedTime: _time,
        color: color,
        phoneE164: e164,
        today: today,
      );
      if (res.undo != null) {
        snackbar.show(
          l10n.staffAdded(Names.titleCase(rawName)),
          undo: res.undo,
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final amountPaise = Money.parseRupees(_amount.text) ?? 0;
    final phoneTrimmed = _phone.text.trim();
    final e164 = phoneTrimmed.isEmpty
        ? null
        : IndianMobile.toE164(phoneTrimmed);
    final phoneError = phoneTrimmed.isNotEmpty && e164 == null
        ? l10n.staffPhoneInvalid
        : null;
    final canAdd =
        !_saving &&
        _name.text.trim().isNotEmpty &&
        amountPaise > 0 &&
        phoneError == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(title: l10n.staffAddTitle, lead: l10n.staffAddLead),
        TextField(
          controller: _name,
          maxLength: 30,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.staffName,
            hintText: l10n.staffAddNameHint,
          ),
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
        Text(l10n.staffPay, style: NestText.meta13.copyWith(color: c.ink3)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            NestChip(
              label: l10n.staffPayPerHour,
              selected: _payType == 'hourly',
              onTap: () => setState(() => _payType = 'hourly'),
            ),
            NestChip(
              label: l10n.staffPayPerMonth,
              selected: _payType == 'monthly',
              onTap: () => setState(() => _payType = 'monthly'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.staffAmount,
                  hintText: l10n.staffAmountHint,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.staffUsuallyAt,
                  style: NestText.small12.copyWith(color: c.ink3),
                ),
                const SizedBox(height: 4),
                NestButton(
                  label: time12Of(_time),
                  kind: NestButtonKind.ghost,
                  size: NestButtonSize.sm,
                  onPressed: _pickTime,
                ),
              ],
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
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 18, color: c.ink3),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.staffAddInfo,
                style: NestText.meta13.copyWith(color: c.ink3),
              ),
            ),
          ],
        ),
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.commonAdd,
              kind: NestButtonKind.primary,
              size: NestButtonSize.block,
              onPressed: canAdd ? () => _add(l10n, amountPaise, e164) : null,
            ),
          ],
        ),
      ],
    );
  }
}
