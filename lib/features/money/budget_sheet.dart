import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/money_math.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showBudgetSheet(BuildContext context, WidgetRef ref) =>
    showNestSheet<void>(context, (_) => const _BudgetSheet());

class _BudgetSheet extends ConsumerStatefulWidget {
  const _BudgetSheet();

  @override
  ConsumerState<_BudgetSheet> createState() => _BudgetSheetState();
}

class _BudgetSheetState extends ConsumerState<_BudgetSheet> {
  late final TextEditingController _ctrl;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final current = ref.read(budgetPaiseProvider);
    final initial = current == null
        ? ''
        : (current % 100 == 0
              ? '${current ~/ 100}'
              : (current / 100).toStringAsFixed(2));
    _ctrl = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (_saving) return;
    final raw = _ctrl.text.trim();
    final int? paise;
    if (raw.isEmpty) {
      paise = null;
    } else {
      final parsed = Money.parseRupees(raw);
      if (validateAmount(parsed) != null) {
        setState(() => _error = l10n.moneyErrAmount);
        return;
      }
      paise = parsed;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final res = await ref.read(moneyRepoProvider).setBudget(paise);
      if (!mounted) return;
      Navigator.of(context).pop();
      ref.read(snackbarProvider).show(l10n.moneyBudgetSaved, undo: res.undo);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(title: l10n.moneyBudgetTitle),
        TextField(
          controller: _ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          decoration: InputDecoration(
            prefixText: '₹ ',
            errorText: _error,
          ),
        ),
        const SizedBox(height: 20),
        NestButton(
          label: l10n.moneySave,
          kind: NestButtonKind.primary,
          size: NestButtonSize.block,
          onPressed: _saving ? null : () => _save(l10n),
        ),
      ],
    );
  }
}
