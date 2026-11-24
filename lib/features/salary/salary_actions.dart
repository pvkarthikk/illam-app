import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/salary_months.dart';
import 'package:nm_flat/core/domain/settlement_state.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/salary/mark_paid_sheet.dart';
import 'package:nm_flat/features/salary/pay_slip.dart';
import 'package:nm_flat/features/salary/salary_controller.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class SalaryActions extends ConsumerStatefulWidget {
  const SalaryActions({super.key, required this.view, required this.month});

  final SalaryView view;
  final String month;

  @override
  ConsumerState<SalaryActions> createState() => _SalaryActionsState();
}

class _SalaryActionsState extends ConsumerState<SalaryActions> {
  bool _closing = false;

  SalaryView get view => widget.view;
  String get month => widget.month;

  Future<void> _undoAttemptById(
    WidgetRef ref,
    String staffId,
    String attemptId, {
    List<String> transferIds = const [],
  }) async {
    final rows = ref.read(salaryAttemptsProvider(staffId)).value ?? const [];
    for (final row in rows) {
      if (row.id == attemptId) {
        await ref
            .read(salaryRepoProvider)
            .undoPayment(row, transferIds: transferIds);
        return;
      }
    }
  }

  Future<void> _confirmUndo(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AttemptData effective,
    String monthName,
  ) {
    var busy = false;
    return showNestSheet<void>(
      context,
      (sheetCtx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          NestSheetHeader(
            title: l10n.salaryUndoTitle,
            lead: l10n.salaryUndoLead(
              Money.format(effective.amountPaise),
              monthName,
            ),
          ),
          NestSheetActions(
            children: [
              NestButton(
                label: l10n.commonCancel,
                kind: NestButtonKind.ghost,
                onPressed: () => Navigator.of(sheetCtx).pop(),
              ),
              NestButton(
                label: l10n.salaryUndoPayment,
                kind: NestButtonKind.danger,
                onPressed: () async {
                  if (busy) return;
                  busy = true;
                  await _undoAttemptById(
                    ref,
                    view.staff.id,
                    effective.id,
                    transferIds: [
                      for (final t in view.settlement.effectiveTransfers) t.id,
                    ],
                  );
                  if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                  ref.read(snackbarProvider).show(l10n.salaryUndoneSnack);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _adminDisplayNames(WidgetRef ref, AppLocalizations l10n) {
    final list = [
      for (final n in ref.watch(adminNamesProvider))
        if (n == 'you') l10n.salaryYou else if (n.isNotEmpty) n,
    ];
    if (list.isEmpty) return l10n.salaryYou;
    if (list.length == 1) return list.first;
    return l10n.salaryNamesOr(list[0], list[1]);
  }

  String _methodLabel(AppLocalizations l10n, String? method) => switch (method) {
    'cash' => l10n.salaryMethodCash,
    'bank' => l10n.salaryMethodBank,
    _ => l10n.salaryMethodUpi,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final isAdmin = ref.watch(isAdminProvider);
    final r = view.payroll;
    final status = view.settlement.status;
    final unsettled = status == SettlementStatus.unsettled;
    final name = view.staff.name ?? '';
    final monthName = Formatters.monthName(month);
    final effective = view.settlement.effective;
    final members = ref.watch(membersProvider).value ?? const <Member>[];

    String firstNameOf(String id) {
      for (final m in members) {
        if (m.id == id) return m.firstName ?? '?';
      }
      return '?';
    }

    String? paidTagLabel;
    if (effective != null) {
      if (status == SettlementStatus.paid) {
        final exp = effective.expenseId == null
            ? null
            : ref.watch(salaryExpenseProvider(effective.expenseId!)).value;
        final dateIso = exp?.date ?? Dates.dateOfMs(effective.createdAt);
        final dateText = DateFormat('d MMM', 'en').format(Dates.parse(dateIso));
        paidTagLabel = l10n.salaryPaidTag(
          Money.format(effective.amountPaise),
          dateText,
          _methodLabel(l10n, effective.method),
        );
      } else {
        final dateText = DateFormat(
          'd MMM',
          'en',
        ).format(Dates.parse(Dates.dateOfMs(effective.createdAt)));
        paidTagLabel = l10n.salaryClosedTag(dateText);
      }
    }

    final nextM = nextMonth(month);
    final nextMonthName = Formatters.monthName(nextM);
    final endDate = view.staff.endDate;
    final canCarry =
        endDate == null || nextM.compareTo(Dates.month(endDate)) <= 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (unsettled) ...[
            if (isAdmin && r.toPayRupees > 0)
              NestButton(
                label: l10n.salaryMarkPaidButton(
                  Money.format(r.toPayRupees * 100),
                ),
                icon: Icons.currency_rupee_rounded,
                kind: NestButtonKind.primary,
                size: NestButtonSize.block,
                onPressed: () {
                  ref
                      .read(salaryMonthProvider.notifier)
                      .select(view.staff.id, month);
                  showMarkPaidSheet(context, view: view, month: month);
                },
              )
            else if (isAdmin)
              NestButton(
                label: l10n.salaryCloseAtZero(monthName),
                kind: NestButtonKind.ghost,
                size: NestButtonSize.block,
                onPressed: () async {
                  if (_closing) return;
                  setState(() => _closing = true);
                  try {
                    ref
                        .read(salaryMonthProvider.notifier)
                        .select(view.staff.id, month);
                    await ref
                        .read(salaryRepoProvider)
                        .closeAtZero(
                          staffId: view.staff.id,
                          month: month,
                          r: r,
                          carryNote: l10n.salaryCarryNote(monthName),
                        );
                    if (!context.mounted) return;
                    ref
                        .read(snackbarProvider)
                        .show(l10n.salaryClosedSnack(monthName));
                  } finally {
                    if (mounted) setState(() => _closing = false);
                  }
                },
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.infoSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, size: 20, color: c.info),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.salaryMemberNote(_adminDisplayNames(ref, l10n)),
                        style: NestText.body15.copyWith(color: c.info),
                      ),
                    ),
                  ],
                ),
              ),
          ] else if (effective != null && paidTagLabel != null) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                NestTag(
                  label: paidTagLabel,
                  kind: NestTagKind.ok,
                  icon: Icons.check_rounded,
                ),
                if (isAdmin)
                  TextButton(
                    onPressed: () =>
                        _confirmUndo(context, ref, l10n, effective, monthName),
                    child: Text(l10n.salaryUndoPayment),
                  ),
              ],
            ),
            for (final d in view.settlement.duplicates)
              if (d.kind == 'settle') ...[
                const SizedBox(height: 10),
                AlertLine(
                  icon: Icons.warning_amber_rounded,
                  danger: true,
                  text: l10n.salaryDuplicateAlert(
                    name,
                    monthName,
                    Money.format(effective.amountPaise),
                    firstNameOf(effective.byMember),
                    Money.format(d.amountPaise),
                    firstNameOf(d.byMember),
                  ),
                  actionLabel: isAdmin ? l10n.salaryUndoSecond : null,
                  onAction: isAdmin
                      ? () async {
                          await _undoAttemptById(ref, view.staff.id, d.id);
                          if (!context.mounted) return;
                          ref
                              .read(snackbarProvider)
                              .show(l10n.salaryUndoneSnack);
                        }
                      : null,
                ),
              ],
            if (view.differencePaise != 0) ...[
              const SizedBox(height: 10),
              AlertLine(
                icon: Icons.info_outline,
                text: l10n.salaryDifferenceAlert(
                  Money.format(view.payroll.netRupees * 100),
                  Money.format(
                    effective.netPaise + view.settlement.transferredDeltaPaise,
                  ),
                  Money.format(view.differencePaise),
                ),
                actionLabel: isAdmin && canCarry
                    ? l10n.salaryAddToMonth(nextMonthName)
                    : null,
                onAction: isAdmin && canCarry
                    ? () async {
                        await ref
                            .read(salaryRepoProvider)
                            .transferDifference(
                              staffId: view.staff.id,
                              month: month,
                              deltaPaise: view.differencePaise,
                              effectiveTransferIds: [
                                for (final t
                                    in view.settlement.effectiveTransfers)
                                  t.id,
                              ],
                              note: l10n.salaryDifferenceNote(monthName),
                            );
                        if (!context.mounted) return;
                        ref
                            .read(snackbarProvider)
                            .show(l10n.salaryDifferenceSnack(nextMonthName));
                      }
                    : null,
              ),
            ],
          ],
          const SizedBox(height: 10),
          NestButton(
            label: l10n.salarySharePaySlip(name),
            icon: Icons.share_outlined,
            kind: NestButtonKind.ghost,
            size: NestButtonSize.block,
            onPressed: () =>
                showPaySlipSheet(context, view: view, month: month),
          ),
        ],
      ),
    );
  }
}
