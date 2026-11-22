import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/expenses_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<bool?> showLogBillSheet(
  BuildContext context, {
  required String list,
  required List<ItemRow> picked,
}) => showNestSheet<bool>(
  context,
  (_) => _LogBillSheet(list: list, picked: picked),
);

class _LogBillSheet extends ConsumerStatefulWidget {
  const _LogBillSheet({required this.list, required this.picked});

  final String list;
  final List<ItemRow> picked;

  @override
  ConsumerState<_LogBillSheet> createState() => _LogBillSheetState();
}

class _LogBillSheetState extends ConsumerState<_LogBillSheet> {
  final _amountCtrl = TextEditingController();
  final _amountFocus = FocusNode();
  final _otherCtrl = TextEditingController();

  String _storeKey = 'kirana';
  String _method = 'upi';
  String? _amountError;
  String? _nameError;
  bool _saving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _amountFocus.dispose();
    _otherCtrl.dispose();
    super.dispose();
  }

  String _storeLabel(AppLocalizations l10n, String key) => switch (key) {
    'dmart' => l10n.storeDMart,
    'kirana' => l10n.storeKirana,
    'sabzi' => l10n.storeSabzi,
    'reliance' => l10n.storeReliance,
    _ => l10n.storeOther,
  };

  Future<void> _save(AppLocalizations l10n) async {
    if (_saving) return;
    final paise = Money.parseRupees(_amountCtrl.text);
    if (paise == null || paise <= 0 || paise > 100000000) {
      setState(() => _amountError = l10n.storeCheckAmount);
      _amountFocus.requestFocus();
      return;
    }

    final String store;
    if (_storeKey == 'other') {
      final typed = _otherCtrl.text.trim();
      if (typed.isEmpty) {
        setState(() => _nameError = l10n.storeNameRequired);
        return;
      }
      store = typed;
    } else {
      store = _storeLabel(l10n, _storeKey);
    }

    setState(() {
      _saving = true;
      _amountError = null;
      _nameError = null;
    });

    try {
      final clock = ref.read(clockProvider);
      final today = Dates.today(clock);
      final nowMs = clock.nowMs;
      final expenses = ref.read(expensesRepoProvider);
      final listsRepo = ref.read(listsRepoProvider);
      // P10: run the ALG-21 duplicate hint here (FR-STORE-3) before writing.
      final res = await ref.read(changesProvider).write('Store bill', (c) {
        expenses.createIn(
          c,
          NewExpense(
            amountPaise: paise,
            merchant: store,
            category: widget.list == 'grocery' ? 'Groceries' : 'Shopping',
            method: _method,
            date: today,
            source: 'store',
          ),
        );
        listsRepo.buildClearOps(c, widget.picked, nowMs);
      });
      if (!mounted) return;
      ref
          .read(snackbarProvider)
          .show(
            l10n.storeLogged(Money.format(paise), store),
            undo: res.undo,
          );
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _skip(AppLocalizations l10n) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final nowMs = ref.read(clockProvider).nowMs;
      final listsRepo = ref.read(listsRepoProvider);
      final res = await ref.read(changesProvider).write('Store trip', (c) {
        listsRepo.buildClearOps(c, widget.picked, nowMs);
      });
      if (!mounted) return;
      ref.read(snackbarProvider).show(l10n.storeTripDone, undo: res.undo);
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    const storeKeys = ['dmart', 'kirana', 'sabzi', 'reliance', 'other'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(title: l10n.storeLogTitle, lead: l10n.storeLogLead),
        TextField(
          controller: _amountCtrl,
          focusNode: _amountFocus,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) {
            if (_amountError != null) setState(() => _amountError = null);
          },
          decoration: InputDecoration(
            labelText: l10n.storeBillAmount,
            errorText: _amountError,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.storeStore,
          style: NestText.small12.copyWith(color: c.ink2),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final key in storeKeys)
              NestChip(
                label: _storeLabel(l10n, key),
                selected: _storeKey == key,
                onTap: () => setState(() {
                  _storeKey = key;
                  _nameError = null;
                }),
              ),
          ],
        ),
        if (_storeKey == 'other') ...[
          const SizedBox(height: 12),
          TextField(
            controller: _otherCtrl,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
            decoration: InputDecoration(
              labelText: l10n.storeOtherName,
              errorText: _nameError,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          l10n.storePaidWith,
          style: NestText.small12.copyWith(color: c.ink2),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            NestChip(
              label: l10n.storeCash,
              selected: _method == 'cash',
              onTap: () => setState(() => _method = 'cash'),
            ),
            NestChip(
              label: l10n.storeUpi,
              selected: _method == 'upi',
              onTap: () => setState(() => _method = 'upi'),
            ),
            NestChip(
              label: l10n.storeCard,
              selected: _method == 'card',
              onTap: () => setState(() => _method = 'card'),
            ),
          ],
        ),
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.storeSkip,
              kind: NestButtonKind.ghost,
              onPressed: _saving ? null : () => _skip(l10n),
            ),
            NestButton(
              label: l10n.storeSave,
              kind: NestButtonKind.primary,
              onPressed: _saving ? null : () => _save(l10n),
            ),
          ],
        ),
      ],
    );
  }
}
