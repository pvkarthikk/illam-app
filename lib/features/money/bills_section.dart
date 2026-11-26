import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/bills.dart';
import 'package:nm_flat/core/domain/duplicate_hint.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/money/bill_paid_sheet.dart';
import 'package:nm_flat/features/money/bill_sheet.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class CategoryLetterBadge extends StatelessWidget {
  const CategoryLetterBadge({
    super.key,
    required this.name,
    required this.category,
  });

  final String name;
  final String category;

  @override
  Widget build(BuildContext context) {
    final bg = NestPalette.categoryColor(category);
    final trimmed = name.trim();
    final letter = trimmed.isEmpty
        ? '?'
        : String.fromCharCode(trimmed.runes.first).toUpperCase();

    return ExcludeSemantics(
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          letter,
          style: const TextStyle(
            fontFamily: NestText.sans,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontVariations: [FontVariation.weight(700)],
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

String methodLabel(AppLocalizations l10n, String m) => switch (m) {
  'cash' => l10n.moneyMethodCash,
  'card' => l10n.moneyMethodCard,
  'bank' => l10n.moneyMethodBank,
  _ => l10n.moneyMethodUpi,
};

class BillsSection extends ConsumerWidget {
  const BillsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final statuses = ref.watch(billStatusesProvider).value ?? const [];
    final allBills = ref.watch(billsProvider).value ?? const <Bill>[];
    final stopped = [
      for (final b in allBills)
        if (!b.active) b,
    ];

    var n = 0;
    var k = 0;
    for (final item in statuses) {
      if (item.$2.kind != BillDue.firstDue) {
        n++;
        if (item.$2.kind == BillDue.paid) k++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 12, 4),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 4,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.moneyBills.toUpperCase(),
                      style: NestText.section13.copyWith(color: c.ink2),
                    ),
                  ),
                  if (n > 0)
                    Text(
                      l10n.moneyBillsPaid(k, n),
                      style: NestText.meta13.copyWith(color: c.ink3),
                    ),
                ],
              ),
              TextButton(
                onPressed: () => showBillSheet(context, ref),
                child: Text(l10n.moneyAddBill),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: statuses.isEmpty
              ? NestCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.moneyBillsEmpty,
                        style: NestText.meta13.copyWith(color: c.ink3),
                      ),
                      const SizedBox(height: 12),
                      NestButton(
                        label: l10n.moneyAddBill,
                        kind: NestButtonKind.tonal,
                        size: NestButtonSize.sm,
                        onPressed: () => showBillSheet(context, ref),
                      ),
                    ],
                  ),
                )
              : NestCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < statuses.length; i++) ...[
                        if (i > 0) Container(height: 1, color: c.line),
                        _BillRow(
                          bill: statuses[i].$1,
                          status: statuses[i].$2,
                        ),
                      ],
                    ],
                  ),
                ),
        ),
        if (stopped.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: NestCard(
              child: ExpansionTile(
                title: Text(
                  l10n.moneyStoppedBills(stopped.length),
                  style: NestText.meta13.copyWith(color: c.ink2),
                ),
                children: [
                  for (var i = 0; i < stopped.length; i++) ...[
                    Container(height: 1, color: c.line),
                    _StoppedBillRow(bill: stopped[i]),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BillRow extends ConsumerWidget {
  const _BillRow({required this.bill, required this.status});

  final Bill bill;
  final BillStatus status;

  String _fmtDate(String iso) =>
      DateFormat('d MMM', 'en').format(Dates.parse(iso));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final kind = status.kind;

    final SpendLite? latest = status.payments.isEmpty
        ? null
        : status.payments.reduce(
            (a, b) =>
                (a.date.compareTo(b.date) > 0 ||
                    (a.date == b.date && a.createdAt > b.createdAt))
                ? a
                : b,
          );

    final String sub = switch (kind) {
      BillDue.paid when latest != null => l10n.moneyBillPaidOn(
        _fmtDate(latest.date),
        methodLabel(l10n, latest.method),
      ),
      BillDue.firstDue => l10n.moneyFirstDue(
        _fmtDate(status.dueDate),
        Money.format(bill.usualAmountPaise),
      ),
      _ => l10n.moneyBillDue(
        _fmtDate(status.dueDate),
        Money.format(bill.usualAmountPaise),
      ),
    };

    return InkWell(
      onTap: () => showBillSheet(context, ref, bill: bill),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              CategoryLetterBadge(name: bill.name, category: bill.category),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          bill.name,
                          style: NestText.itemTitle16.copyWith(color: c.ink),
                        ),
                        if (kind == BillDue.overdue)
                          NestTag(
                            label: l10n.moneyOverdue,
                            kind: NestTagKind.danger,
                          )
                        else if (kind == BillDue.today)
                          NestTag(
                            label: l10n.moneyToday,
                            kind: NestTagKind.accent,
                          ),
                        if (kind == BillDue.paid && status.paidTwice)
                          NestTag(
                            label: l10n.moneyPaidTwice,
                            kind: NestTagKind.accent,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: NestText.meta13.copyWith(color: c.ink3),
                    ),
                    if (kind == BillDue.paid && status.paidTwice) ...[
                      const SizedBox(height: 4),
                      for (final p in status.payments)
                        Text(
                          '${_fmtDate(p.date)} · ${methodLabel(l10n, p.method)} · ${Money.format(p.amountPaise)}',
                          style: NestText.small12.copyWith(color: c.ink2),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (kind == BillDue.paid && latest != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Money.format(latest.amountPaise),
                      style: NestText.figures16.copyWith(color: c.ink),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: c.primary,
                    ),
                  ],
                )
              else if (kind != BillDue.firstDue)
                NestButton(
                  label: l10n.moneyPaid,
                  size: NestButtonSize.sm,
                  kind: (kind == BillDue.today || kind == BillDue.overdue)
                      ? NestButtonKind.accent
                      : NestButtonKind.ghost,
                  semanticLabel: l10n.moneyMarkBillPaid(bill.name),
                  onPressed: () => showBillPaidSheet(context, ref, bill),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoppedBillRow extends ConsumerWidget {
  const _StoppedBillRow({required this.bill});

  final Bill bill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bill.name,
                    style: NestText.itemTitle16.copyWith(color: c.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.moneyStoppedRow(
                      Money.format(bill.usualAmountPaise),
                      bill.dueDay,
                    ),
                    style: NestText.meta13.copyWith(color: c.ink3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            NestButton(
              label: l10n.moneyTrackAgain,
              kind: NestButtonKind.ghost,
              size: NestButtonSize.sm,
              onPressed: () async {
                final res = await ref
                    .read(moneyRepoProvider)
                    .setBillActive(bill.id, true);
                if (!context.mounted) return;
                ref
                    .read(snackbarProvider)
                    .show(l10n.moneyTrackingAgain(bill.name), undo: res.undo);
              },
            ),
          ],
        ),
      ),
    );
  }
}
