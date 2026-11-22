import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showMarkPaidSheet(
  BuildContext context, {
  required SalaryView view,
  required String month,
}) => showNestSheet<void>(
  context,
  (_) => _MarkPaidSheet(view: view, month: month),
);

class _MarkPaidSheet extends ConsumerStatefulWidget {
  const _MarkPaidSheet({required this.view, required this.month});

  final SalaryView view;
  final String month;

  @override
  ConsumerState<_MarkPaidSheet> createState() => _MarkPaidSheetState();
}

class _MarkPaidSheetState extends ConsumerState<_MarkPaidSheet> {
  String _method = 'upi';
  bool _saving = false;

  Future<void> _confirm(AppLocalizations l10n, String amountText) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final today = Dates.today(ref.read(clockProvider));
      final name = widget.view.staff.name ?? '';
      final monthName = Formatters.monthName(widget.month);
      await ref
          .read(salaryRepoProvider)
          .markPaid(
            staffId: widget.view.staff.id,
            month: widget.month,
            r: widget.view.payroll,
            method: _method,
            merchantText: l10n.salaryExpenseMerchant(name, monthName),
            today: today,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ref
          .read(snackbarProvider)
          .show(l10n.salaryPaidSnack(amountText, name));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final amountText = Money.format(widget.view.payroll.toPayRupees * 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(title: l10n.salaryMarkPaidTitle(amountText)),
        Text(
          l10n.salaryPaidWith,
          style: NestText.small12.copyWith(color: c.ink2),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            NestChip(
              label: l10n.salaryMethodCash,
              selected: _method == 'cash',
              onTap: () => setState(() => _method = 'cash'),
            ),
            NestChip(
              label: l10n.salaryMethodUpi,
              selected: _method == 'upi',
              onTap: () => setState(() => _method = 'upi'),
            ),
            NestChip(
              label: l10n.salaryMethodBank,
              selected: _method == 'bank',
              onTap: () => setState(() => _method = 'bank'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        NestButton(
          label: l10n.salaryMarkPaidConfirm,
          kind: NestButtonKind.primary,
          size: NestButtonSize.block,
          onPressed: _saving ? null : () => _confirm(l10n, amountText),
        ),
      ],
    );
  }
}
