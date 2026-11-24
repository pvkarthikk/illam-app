import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/money_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/money_math.dart';
import 'package:nm_flat/core/domain/spend_category.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/money/bills_section.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showBillSheet(
  BuildContext context,
  WidgetRef ref, {
  Bill? bill,
}) => showNestSheet<void>(context, (_) => _BillSheet(bill: bill));

class _BillSheet extends ConsumerStatefulWidget {
  const _BillSheet({this.bill});

  final Bill? bill;

  @override
  ConsumerState<_BillSheet> createState() => _BillSheetState();
}

class _BillSheetState extends ConsumerState<_BillSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _dayCtrl;

  late String _category;
  late bool _categoryLocked;
  late String _method;
  late bool _remind;

  String? _nameError;
  String? _amountError;
  String? _dayError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final b = widget.bill;
    _nameCtrl = TextEditingController(text: b?.name ?? '');
    _amountCtrl = TextEditingController(
      text: b == null || b.usualAmountPaise <= 0
          ? ''
          : (b.usualAmountPaise % 100 == 0
                ? '${b.usualAmountPaise ~/ 100}'
                : (b.usualAmountPaise / 100).toStringAsFixed(2)),
    );
    _dayCtrl = TextEditingController(text: b == null ? '' : '${b.dueDay}');
    _category = b?.category ?? 'Other';
    _categoryLocked = b != null;
    _method = b?.method ?? 'upi';
    _remind = b?.remind ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _dayCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (_saving) return;
    final name = _nameCtrl.text.trim();
    final nameErr =
        (name.isEmpty || name.length > 40) ? l10n.moneyBillErrName : null;

    final paise = Money.parseRupees(_amountCtrl.text);
    final amountErr = validateAmount(paise) != null ? l10n.moneyErrAmount : null;

    final day = int.tryParse(_dayCtrl.text.trim());
    final dayErr =
        (day == null || day < 1 || day > 31) ? l10n.moneyBillErrDay : null;

    if (nameErr != null || amountErr != null || dayErr != null) {
      setState(() {
        _nameError = nameErr;
        _amountError = amountErr;
        _dayError = dayErr;
      });
      return;
    }

    setState(() {
      _saving = true;
      _nameError = null;
      _amountError = null;
      _dayError = null;
    });
    var closed = false;
    try {
      final today = ref.read(todayDateProvider);
      final existing = widget.bill;
      final snack = ref.read(snackbarProvider);
      final repo = ref.read(moneyRepoProvider);
      final draft = BillDraft(
        name: name,
        category: _category,
        usualAmountPaise: paise!,
        dueDay: day!,
        method: _method,
        remind: _remind,
        today: today,
      );
      final existingId = existing?.id;
      final text = existing == null
          ? l10n.moneyBillAdded(name)
          : l10n.moneyBillSaved;
      closed = true;
      Navigator.of(context).pop();
      try {
        final res = await repo.saveBill(draft, id: existingId);
        snack.show(text, undo: res.undo);
      } on Object {
        snack.show(rejectText('other'));
      }
    } finally {
      if (!closed && mounted) setState(() => _saving = false);
    }
  }

  Future<void> _stopTracking(AppLocalizations l10n, Bill bill) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final res = await ref
          .read(moneyRepoProvider)
          .setBillActive(bill.id, false);
      if (!mounted) return;
      Navigator.of(context).pop();
      ref
          .read(snackbarProvider)
          .show(l10n.moneyStopped(bill.name), undo: res.undo);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete(AppLocalizations l10n, Bill bill) async {
    final confirmed = await showNestSheet<bool>(
      context,
      (sheetCtx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          NestSheetHeader(
            title: l10n.moneyDeleteBillTitle(bill.name),
            lead: l10n.moneyDeleteBillLead,
          ),
          NestSheetActions(
            children: [
              NestButton(
                label: l10n.moneyKeep,
                kind: NestButtonKind.ghost,
                onPressed: () => Navigator.of(sheetCtx).pop(false),
              ),
              NestButton(
                label: l10n.moneyDelete,
                kind: NestButtonKind.danger,
                onPressed: () => Navigator.of(sheetCtx).pop(true),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      final res = await ref.read(moneyRepoProvider).deleteBill(bill.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      ref
          .read(snackbarProvider)
          .show(l10n.moneyBillDeleted(bill.name), undo: res.undo);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final rules = ref.watch(merchantRulesProvider).value ?? const {};
    final isAdmin = ref.watch(isAdminProvider);
    final me = ref.watch(myMemberIdProvider);
    final existing = widget.bill;
    final parsedDay = int.tryParse(_dayCtrl.text.trim());
    final dueHelper = (parsedDay != null && parsedDay >= 1 && parsedDay <= 31)
        ? l10n.moneyDueHelper(l10n.moneyOrdinal('$parsedDay'))
        : null;
    final canDelete =
        existing != null && (isAdmin || existing.createdBy == me);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(
          title: existing == null
              ? l10n.moneyAddBillTitle
              : l10n.moneyEditBillTitle,
        ),
        TextField(
          controller: _nameCtrl,
          autofocus: true,
          maxLength: 40,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (v) {
            setState(() {
              _nameError = null;
              if (!_categoryLocked) {
                _category = guessSpendCategory(v, rules);
              }
            });
          },
          decoration: InputDecoration(
            labelText: l10n.moneyBillName,
            counterText: '',
            errorText: _nameError,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) {
            if (_amountError != null) setState(() => _amountError = null);
          },
          decoration: InputDecoration(
            labelText: l10n.moneyUsualAmount,
            prefixText: '₹ ',
            errorText: _amountError,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _dayCtrl,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() => _dayError = null),
          decoration: InputDecoration(
            labelText: l10n.moneyDueDay,
            helperText: dueHelper,
            errorText: _dayError,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.moneyCategory,
          style: NestText.small12.copyWith(color: c.ink2),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final cat in spendCategories)
              NestChip(
                label: cat,
                selected: _category == cat,
                dotColor: NestPalette.categories[cat],
                onTap: () => setState(() {
                  _category = cat;
                  _categoryLocked = true;
                }),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          l10n.moneyPaidWith,
          style: NestText.small12.copyWith(color: c.ink2),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final m in const ['upi', 'cash', 'card', 'bank'])
              NestChip(
                label: methodLabel(l10n, m),
                selected: _method == m,
                onTap: () => setState(() => _method = m),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SwitchRow(
          title: l10n.moneyRemind,
          value: _remind,
          onChanged: (v) => setState(() => _remind = v),
        ),
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.moneySave,
              kind: NestButtonKind.primary,
              size: NestButtonSize.block,
              onPressed: _saving ? null : () => _save(l10n),
            ),
          ],
        ),
        if (existing != null) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _saving ? null : () => _stopTracking(l10n, existing),
              child: Text(l10n.moneyStopTracking),
            ),
          ),
          if (canDelete) ...[
            const SizedBox(height: 4),
            NestButton(
              label: l10n.moneyDeleteBill,
              kind: NestButtonKind.dangerGhost,
              onPressed: _saving ? null : () => _confirmDelete(l10n, existing),
            ),
          ],
        ],
      ],
    );
  }
}
