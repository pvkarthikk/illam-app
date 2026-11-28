import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/payroll.dart';
import 'package:nm_flat/core/domain/staff_text.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class PaySlipData {
  const PaySlipData({
    required this.month,
    required this.name,
    required this.r,
  });

  final String month;
  final String name;
  final PayrollResult r;
}

String buildPaySlip(AppLocalizations l10n, PaySlipData d) {
  final r = d.r;
  final rules = r.rules;
  final monthName = Formatters.monthName(d.month);
  final lines = <String>[l10n.salarySlipHeader(monthName, d.name)];

  if (rules?.type == PayType.hourly) {
    final billed = Formatters.duration(r.billedMinutes);
    lines.add(l10n.salarySlipDaysHours(r.presentDays, billed));
    lines.add(
      l10n.salarySlipHoursCalc(
        billed,
        Money.format(rules!.ratePerHourPaise),
        Money.format(r.grossPaise),
      ),
    );
  } else if (rules != null) {
    lines.add(l10n.salarySlipSalary(Money.format(rules.amountPerMonthPaise)));
    final taken = r.absentDays + r.leaveDays + r.paidLeaveDays;
    final paid = r.paidLeaveDays > 0
        ? (taken - r.unpaidDays)
        : rules.paidLeavesPerMonth;
    lines.add(l10n.salarySlipLeaves(taken, paid));
  }

  for (final e in r.extras) {
    final label = e.note.trim().isEmpty ? l10n.salaryKindExtra : e.note;
    lines.add(l10n.salarySlipExtra(label, Money.format(e.amountPaise)));
  }
  for (final a in r.advances) {
    lines.add(l10n.salarySlipAdvance(Money.format(a.amountPaise)));
  }
  for (final ded in r.deductions) {
    final label =
        ded.note.trim().isEmpty ? l10n.salaryKindDeduction : ded.note;
    lines.add(l10n.salarySlipDeduction(label, Money.format(ded.amountPaise)));
  }

  lines.add(l10n.salarySlipTotal(Money.format(r.netRupees * 100)));
  return lines.join('\n');
}

Future<void> showPaySlipSheet(
  BuildContext context, {
  required SalaryView view,
  required String month,
}) => showNestSheet<void>(
  context,
  (_) => _PaySlipSheet(view: view, month: month),
);

class _PaySlipSheet extends ConsumerStatefulWidget {
  const _PaySlipSheet({required this.view, required this.month});

  final SalaryView view;
  final String month;

  @override
  ConsumerState<_PaySlipSheet> createState() => _PaySlipSheetState();
}

class _PaySlipSheetState extends ConsumerState<_PaySlipSheet> {
  bool _sending = false;

  Future<void> _send(BuildContext context, String slipText) async {
    if (_sending) return;
    _sending = true;
    try {
      final phone = widget.view.staff.phoneE164;
      if (phone != null && phone.isNotEmpty) {
        final digits = IndianMobile.waDigits(phone);
        final uri = Uri.parse(
          'https://wa.me/$digits?text=${Uri.encodeComponent(slipText)}',
        );
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await SharePlus.instance.share(ShareParams(text: slipText));
      }
    } catch (_) {
      _sending = false;
      rethrow;
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final name = widget.view.staff.name ?? '';
    final slipText = buildPaySlip(
      l10n,
      PaySlipData(month: widget.month, name: name, r: widget.view.shown),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(title: l10n.salarySlipTitle, lead: l10n.salarySlipLead),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.paper2,
              border: Border(left: BorderSide(color: c.ok, width: 3)),
            ),
            child: SelectableText(
              slipText,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.45,
                color: c.ink,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        NestButton(
          label: l10n.salarySlipSend,
          icon: Icons.send_rounded,
          kind: NestButtonKind.primary,
          size: NestButtonSize.block,
          onPressed: () => _send(context, slipText),
        ),
      ],
    );
  }
}
