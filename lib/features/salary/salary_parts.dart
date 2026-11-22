import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/payroll.dart';
import 'package:nm_flat/core/domain/salary_months.dart';
import 'package:nm_flat/core/domain/settlement_state.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/salary/pay_rules_sheet.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class ReceiptCard extends ConsumerWidget {
  const ReceiptCard({super.key, required this.view, required this.month});

  final SalaryView view;
  final String month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final r = view.shown;
    final rules = r.rules;
    final settled = view.settlement.status != SettlementStatus.unsettled;
    final isAdmin = ref.watch(isAdminProvider);
    final rows = _ledgerRows(l10n, r);

    return NestCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KolamBackground(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (settled ? l10n.salaryEyebrowPaid : l10n.salaryEyebrowPayable)
                        .toUpperCase(),
                    style: NestText.eyebrow12.copyWith(color: c.ink3),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Money.format(r.toPayRupees * 100),
                    style: NestText.bigNumber54.copyWith(color: c.ink),
                  ),
                  if (r.carryRupees > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.salaryCarryPreview(
                        Money.format(r.carryRupees * 100),
                        Formatters.monthName(nextMonth(month)),
                      ),
                      style: NestText.meta13.copyWith(
                        fontSize: 14,
                        color: c.danger,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    l10n.salaryDaysLine(
                      r.presentDays,
                      r.absentDays,
                      r.leaveDays,
                    ),
                    style: NestText.meta13.copyWith(color: c.ink2),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: c.line),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) Divider(height: 1, thickness: 1, color: c.line),
                  rows[i],
                ],
                _TotalRow(
                  label: l10n.salaryToPay,
                  amount: Money.format(r.toPayRupees * 100),
                ),
              ],
            ),
          ),
          if (rules != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (rules.type == PayType.hourly) ...[
                    NestTag(
                      icon: Icons.schedule_rounded,
                      label: l10n.salaryChipRate(
                        Money.format(rules.ratePerHourPaise),
                      ),
                    ),
                    NestTag(
                      label: rules.roundingMin == 1
                          ? l10n.salaryChipExact
                          : l10n.salaryChipRound(rules.roundingMin),
                    ),
                  ] else ...[
                    NestTag(
                      label: l10n.salaryChipMonthly(
                        Money.format(rules.amountPerMonthPaise),
                      ),
                    ),
                    NestTag(
                      label: l10n.salaryChipPaidLeaves(
                        rules.paidLeavesPerMonth,
                      ),
                    ),
                  ],
                  if (isAdmin)
                    TextButton.icon(
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text(l10n.salaryEditRules),
                      onPressed: () => showPayRulesSheet(
                        context,
                        staffId: view.staff.id,
                        name: view.staff.name ?? '',
                        month: month,
                      ),
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline, size: 14, color: c.ink3),
                        const SizedBox(width: 4),
                        Text(
                          l10n.salaryAdminsSetRules,
                          style: NestText.meta13.copyWith(color: c.ink3),
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<_LedgerRow> _ledgerRows(AppLocalizations l10n, PayrollResult r) {
    final rules = r.rules;
    final list = <_LedgerRow>[];
    if (rules?.type == PayType.hourly) {
      final rounding = rules!.roundingMin == 1
          ? l10n.salaryRoundTheMinute
          : l10n.salaryRoundMinutes(rules.roundingMin);
      final minimum = rules.minHoursPerVisit == 0
          ? ''
          : l10n.salaryMinimumPart(rules.minHoursPerVisit);
      list.add(
        _LedgerRow(
          label: l10n.salaryHoursWorked,
          detail: l10n.salaryHoursDetail(
            Formatters.duration(r.billedMinutes),
            Money.format(rules.ratePerHourPaise),
            r.visitCount,
            Formatters.duration(r.actualMinutes),
            rounding,
            minimum,
          ),
          amount: Money.format(r.grossPaise),
        ),
      );
    } else if (rules?.type == PayType.monthly) {
      list.add(
        _LedgerRow(
          label: l10n.salaryMonthlyLine,
          detail: l10n.salaryMonthlyDetail(
            r.eligibleWorkDays,
            Money.format(r.perDayPaise),
          ),
          amount: Money.format(r.grossPaise + r.leaveDeductionPaise),
        ),
      );
      final taken = r.absentDays + r.leaveDays;
      final paid = taken - r.unpaidDays;
      list.add(
        _LedgerRow(
          label: l10n.salaryLeavesLine,
          detail: l10n.salaryLeavesDetail(taken, paid, r.unpaidDays),
          amount: r.leaveDeductionPaise == 0
              ? Money.format(0)
              : '−${Money.format(r.leaveDeductionPaise)}',
          danger: r.leaveDeductionPaise > 0,
        ),
      );
    }

    for (final e in r.extras) {
      list.add(
        _LedgerRow(
          label: e.note.trim().isEmpty ? l10n.salaryKindExtra : e.note,
          detail: l10n.salaryExtraDetail,
          amount: '+${Money.format(e.amountPaise)}',
        ),
      );
    }
    for (final a in r.advances) {
      list.add(
        _LedgerRow(
          label: l10n.salaryAdvanceLine,
          detail: l10n.salaryAdvanceDetail,
          amount: '−${Money.format(a.amountPaise)}',
          danger: true,
        ),
      );
    }
    for (final d in r.deductions) {
      list.add(
        _LedgerRow(
          label: d.note.trim().isEmpty ? l10n.salaryKindDeduction : d.note,
          detail: l10n.salaryDeductionDetail,
          amount: '−${Money.format(d.amountPaise)}',
          danger: true,
        ),
      );
    }
    return list;
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.label,
    required this.detail,
    required this.amount,
    this.danger = false,
  });

  final String label;
  final String detail;
  final String amount;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: NestText.sans,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontVariations: const [FontVariation.weight(700)],
                    color: c.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: NestText.meta13.copyWith(fontSize: 12.5, color: c.ink3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: TextStyle(
              fontFamily: NestText.sans,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontVariations: const [FontVariation.weight(700)],
              fontFeatures: const [FontFeature.tabularFigures()],
              color: danger ? c.danger : c.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    final style = TextStyle(
      fontFamily: NestText.sans,
      fontSize: 18,
      fontWeight: FontWeight.w800,
      fontVariations: const [FontVariation.weight(800)],
      fontFeatures: const [FontFeature.tabularFigures()],
      color: c.ink,
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.ink, width: 2)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(amount, style: style),
        ],
      ),
    );
  }
}

class ReceiptEdge extends StatelessWidget {
  const ReceiptEdge({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const ReceiptEdgeClipper(),
      child: Container(
        width: double.infinity,
        height: 10,
        color: context.nest.card,
      ),
    );
  }
}

class ReceiptEdgeClipper extends CustomClipper<Path> {
  const ReceiptEdgeClipper();

  @override
  Path getClip(Size size) {
    const r = 6.0;
    const step = 16.0;
    final path = Path()..moveTo(0, 0);
    for (var cx = 8.0; cx + r <= size.width; cx += step) {
      path.lineTo(cx - r, 0);
      path.arcToPoint(
        Offset(cx + r, 0),
        radius: const Radius.circular(r),
        clockwise: false,
      );
    }
    path
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
