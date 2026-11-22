import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/repo/expenses_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/lists/lists_text.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showOrderAmountSheet(
  BuildContext context,
  String channel,
  String list,
) => showNestSheet<void>(
  context,
  (_) => _OrderAmountSheet(channel: channel, list: list),
);

class _OrderAmountSheet extends ConsumerStatefulWidget {
  const _OrderAmountSheet({required this.channel, required this.list});

  final String channel;
  final String list;

  @override
  ConsumerState<_OrderAmountSheet> createState() => _OrderAmountSheetState();
}

class _OrderAmountSheetState extends ConsumerState<_OrderAmountSheet> {
  final _amountCtrl = TextEditingController();
  final _focus = FocusNode();
  String _method = 'upi';
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n, String store) async {
    if (_saving) return;
    final paise = Money.parseRupees(_amountCtrl.text);
    if (paise == null || paise <= 0 || paise > 100000000) {
      setState(() => _error = l10n.storeCheckAmount);
      _focus.requestFocus();
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final today = Dates.today(ref.read(clockProvider));
      // P10: ALG-21 duplicate hint here (FR-EXP-4).
      final res = await ref.read(changesProvider).write('Order amount', (c) {
        ref
            .read(expensesRepoProvider)
            .createIn(
              c,
              NewExpense(
                amountPaise: paise,
                merchant: store,
                category: widget.list == 'grocery' ? 'Groceries' : 'Shopping',
                method: _method,
                date: today,
                source: 'order',
                orderChannel: widget.channel,
              ),
            );
      });
      if (!mounted) return;
      ref
          .read(snackbarProvider)
          .show(
            l10n.storeOrderAdded(Money.format(paise), store),
            undo: res.undo,
          );
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final store = channelName(l10n, widget.channel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(
          title: l10n.storeOrderedOn(store),
          lead: l10n.storeHowMuch,
        ),
        TextField(
          controller: _amountCtrl,
          focusNode: _focus,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          decoration: InputDecoration(
            labelText: l10n.storeAmount,
            errorText: _error,
          ),
        ),
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
              label: l10n.storeUpi,
              selected: _method == 'upi',
              onTap: () => setState(() => _method = 'upi'),
            ),
            NestChip(
              label: l10n.storeCard,
              selected: _method == 'card',
              onTap: () => setState(() => _method = 'card'),
            ),
            NestChip(
              label: l10n.storeCashOnDelivery,
              selected: _method == 'cash',
              onTap: () => setState(() => _method = 'cash'),
            ),
          ],
        ),
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.storeAddLater,
              kind: NestButtonKind.ghost,
              onPressed: _saving ? null : () => Navigator.of(context).pop(),
            ),
            NestButton(
              label: l10n.storeSave,
              kind: NestButtonKind.primary,
              onPressed: _saving ? null : () => _save(l10n, store),
            ),
          ],
        ),
      ],
    );
  }
}
