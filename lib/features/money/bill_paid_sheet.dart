import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/money_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/bills.dart';
import 'package:nm_flat/core/domain/duplicate_hint.dart';
import 'package:nm_flat/core/domain/money_math.dart';
import 'package:nm_flat/core/domain/salary_months.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/money/bills_section.dart';
import 'package:nm_flat/features/money/widgets/duplicate_hint_box.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showBillPaidSheet(
  BuildContext context,
  WidgetRef ref,
  Bill bill,
) => showNestSheet<void>(context, (_) => _BillPaidSheet(bill: bill));

class _BillPaidSheet extends ConsumerStatefulWidget {
  const _BillPaidSheet({required this.bill});

  final Bill bill;

  @override
  ConsumerState<_BillPaidSheet> createState() => _BillPaidSheetState();
}

class _BillPaidSheetState extends ConsumerState<_BillPaidSheet> {
  late final TextEditingController _amountCtrl;
  final _focus = FocusNode();

  late String _method;
  late String _date;
  late String _forMonth;
  String? _amountError;
  DuplicateHit? _dup;
  bool _dupConfirmed = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final b = widget.bill;
    _amountCtrl = TextEditingController(
      text: b.usualAmountPaise <= 0
          ? ''
          : (b.usualAmountPaise % 100 == 0
                ? '${b.usualAmountPaise ~/ 100}'
                : (b.usualAmountPaise / 100).toStringAsFixed(2)),
    );
    _method = b.method;
    final today = ref.read(todayDateProvider);
    _date = today;
    final allPayments =
        ref.read(billPaymentsProvider).value ?? const <SpendLite>[];
    final billPayments = [
      for (final p in allPayments)
        if (p.billId == b.id) p,
    ];
    _forMonth = defaultForMonth(
      firstDueMonth: b.firstDueMonth,
      payments: billPayments,
      today: today,
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n, String forMonth) async {
    if (_saving) return;
    final paise = Money.parseRupees(_amountCtrl.text);
    if (validateAmount(paise) != null) {
      setState(() => _amountError = l10n.moneyErrAmount);
      _focus.requestFocus();
      return;
    }

    setState(() {
      _saving = true;
      _amountError = null;
    });
    var closed = false;
    try {
      final repo = ref.read(moneyRepoProvider);
      if (!_dupConfirmed) {
        final hit = await repo.checkDuplicate(
          amountPaise: paise!,
          merchant: widget.bill.name,
          date: _date,
        );
        if (!mounted) return;
        if (hit != null) {
          setState(() => _dup = hit);
          return;
        }
      }

      final snack = ref.read(snackbarProvider);
      final bill = widget.bill;
      final method = _method;
      final date = _date;
      final text = l10n.moneyBillPaidSnack(bill.name, Money.format(paise!));
      closed = true;
      Navigator.of(context).pop();
      try {
        final res = await repo.markBillPaid(
          bill: bill,
          amountPaise: paise,
          method: method,
          date: date,
          forMonth: forMonth,
        );
        snack.show(text, undo: res.undo);
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
    final today = ref.watch(todayDateProvider);
    final yesterday = Dates.addDays(today, -1);
    final thisMonth = Dates.month(today);
    final prev = prevMonth(thisMonth);

    final allPayments =
        ref.watch(billPaymentsProvider).value ?? const <SpendLite>[];
    final payments = [
      for (final p in allPayments)
        if (p.billId == widget.bill.id) p,
    ];
    final showForMonth = previousMonthUnpaid(
      firstDueMonth: widget.bill.firstDueMonth,
      payments: payments,
      today: today,
    );
    final effectiveForMonth = showForMonth ? _forMonth : thisMonth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(
          title: l10n.moneyPaidTitle(widget.bill.name),
          lead: l10n.moneyPaidLead(
            Money.format(widget.bill.usualAmountPaise),
            l10n.moneyOrdinal('${widget.bill.dueDay}'),
          ),
        ),
        TextField(
          controller: _amountCtrl,
          focusNode: _focus,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {
            _amountError = null;
            _dupConfirmed = false;
            _dup = null;
          }),
          decoration: InputDecoration(
            prefixText: '₹ ',
            errorText: _amountError,
          ),
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
        const SizedBox(height: 16),
        Text(
          l10n.moneyWhen,
          style: NestText.small12.copyWith(color: c.ink2),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            NestChip(
              label: l10n.moneyToday,
              selected: _date == today,
              onTap: () => setState(() {
                _date = today;
                _dupConfirmed = false;
                _dup = null;
              }),
            ),
            NestChip(
              label: l10n.moneyYesterday,
              selected: _date == yesterday,
              onTap: () => setState(() {
                _date = yesterday;
                _dupConfirmed = false;
                _dup = null;
              }),
            ),
          ],
        ),
        if (showForMonth) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              NestChip(
                label: l10n.moneyForMonth(Formatters.monthName(prev)),
                selected: _forMonth == prev,
                onTap: () => setState(() => _forMonth = prev),
              ),
              NestChip(
                label: l10n.moneyForMonth(Formatters.monthName(thisMonth)),
                selected: _forMonth == thisMonth,
                onTap: () => setState(() => _forMonth = thisMonth),
              ),
            ],
          ),
        ],
        if (_dup != null) ...[
          const SizedBox(height: 16),
          DuplicateHintBox(
            hit: _dup!,
            onDontAdd: () => Navigator.of(context).pop(),
            onAddAnyway: () {
              setState(() {
                _dupConfirmed = true;
                _dup = null;
              });
              _save(l10n, effectiveForMonth);
            },
          ),
        ],
        const SizedBox(height: 20),
        NestButton(
          label: l10n.moneyMarkPaid,
          kind: NestButtonKind.primary,
          size: NestButtonSize.block,
          onPressed: _saving ? null : () => _save(l10n, effectiveForMonth),
        ),
      ],
    );
  }
}
