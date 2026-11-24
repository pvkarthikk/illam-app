import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/expenses_repo.dart';
import 'package:nm_flat/core/data/repo/money_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/money/widgets/duplicate_hint_box.dart';
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
  bool _dupConfirmed = false;
  DuplicateHit? _dup;

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

    var closed = false;
    try {
      final clock = ref.read(clockProvider);
      final today = Dates.today(clock);
      final nowMs = clock.nowMs;
      final expenses = ref.read(expensesRepoProvider);
      final listsRepo = ref.read(listsRepoProvider);
      // Duplicate spend hint check via MoneyRepo.checkDuplicate.
      if (!_dupConfirmed) {
        final hit = await ref
            .read(moneyRepoProvider)
            .checkDuplicate(
              amountPaise: paise,
              merchant: store,
              date: today,
            );
        if (!mounted) return;
        if (hit != null) {
          setState(() => _dup = hit);
          return;
        }
      }
      final rows = await listsRepo.loadClearRows(widget.picked);
      if (!mounted) return;
      final snack = ref.read(snackbarProvider);
      final changes = ref.read(changesProvider);
      final list = widget.list;
      final picked = widget.picked;
      final method = _method;
      final msg = l10n.storeLogged(Money.format(paise), store);
      closed = true;
      Navigator.of(context).pop(true);
      try {
        final res = await changes.write('Store bill', (c) {
          expenses.createIn(
            c,
            NewExpense(
              amountPaise: paise,
              merchant: store,
              category: list == 'grocery' ? 'Groceries' : 'Shopping',
              method: method,
              date: today,
              source: 'store',
            ),
          );
          listsRepo.buildClearOps(
            c,
            picked,
            nowMs,
            history: rows.history,
            pantry: rows.pantry,
          );
        });
        snack.show(msg, undo: res.undo);
      } on Object {
        snack.show(rejectText('other'));
      }
    } finally {
      if (!closed && mounted) setState(() => _saving = false);
    }
  }

  Future<void> _skip(AppLocalizations l10n) async {
    if (_saving) return;
    setState(() => _saving = true);
    var closed = false;
    try {
      final nowMs = ref.read(clockProvider).nowMs;
      final listsRepo = ref.read(listsRepoProvider);
      final rows = await listsRepo.loadClearRows(widget.picked);
      if (!mounted) return;
      final snack = ref.read(snackbarProvider);
      final changes = ref.read(changesProvider);
      final picked = widget.picked;
      final msg = l10n.storeTripDone;
      closed = true;
      Navigator.of(context).pop(true);
      try {
        final res = await changes.write('Store trip', (c) {
          listsRepo.buildClearOps(
            c,
            picked,
            nowMs,
            history: rows.history,
            pantry: rows.pantry,
          );
        });
        snack.show(msg, undo: res.undo);
      } on Object {
        snack.show(rejectText('other'));
      }
    } finally {
      if (!closed && mounted) setState(() => _saving = false);
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
            if (_amountError != null || _dup != null || _dupConfirmed) {
              setState(() {
                _amountError = null;
                _dup = null;
                _dupConfirmed = false;
              });
            }
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
                  _dup = null;
                  _dupConfirmed = false;
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
              if (_nameError != null || _dup != null || _dupConfirmed) {
                setState(() {
                  _nameError = null;
                  _dup = null;
                  _dupConfirmed = false;
                });
              }
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
        if (_dup != null) ...[
          const SizedBox(height: 16),
          DuplicateHintBox(
            hit: _dup!,
            onDontAdd: () => _skip(l10n),
            onAddAnyway: () {
              setState(() {
                _dupConfirmed = true;
                _dup = null;
              });
              _save(l10n);
            },
          ),
        ],
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
