import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/money_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/money_math.dart';
import 'package:nm_flat/core/domain/payroll.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/money/bills_section.dart';
import 'package:nm_flat/features/money/spend_sheet.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class WhereItWentSection extends ConsumerWidget {
  const WhereItWentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final today = ref.watch(todayDateProvider);
    final month = Dates.month(today);
    final rows = ref.watch(monthExpensesProvider(month)).value;
    if (rows == null || rows.isEmpty) return const SizedBox.shrink();

    final repo = ref.watch(moneyRepoProvider);
    final dupAttempts =
        ref.watch(duplicateSalaryAttemptIdsProvider).value ?? const <String>{};
    final totals = categoryTotals(
      [for (final r in rows) repo.toSpendLite(r)],
      {for (final r in rows) r.id: r.category},
      month,
      duplicateSalaryExpenseIds(rows, dupAttempts),
    );
    if (totals.isEmpty) return const SizedBox.shrink();

    final maxAmount = totals.first.$2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        SectionHeader(title: l10n.moneyWhereItWent),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: NestCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < totals.length; i++) ...[
                  if (i > 0) Container(height: 1, color: c.line),
                  _CategoryTotalRow(
                    category: totals[i].$1,
                    amountPaise: totals[i].$2,
                    maxAmountPaise: maxAmount,
                    onTap: () => context.push(
                      '${Routes.moneyTransactions}?category=${Uri.encodeQueryComponent(totals[i].$1)}',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryTotalRow extends StatelessWidget {
  const _CategoryTotalRow({
    required this.category,
    required this.amountPaise,
    required this.maxAmountPaise,
    required this.onTap,
  });

  final String category;
  final int amountPaise;
  final int maxAmountPaise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    final barColor =
        NestPalette.categories[category] ?? NestPalette.categories['Other']!;
    final ratio = maxAmountPaise > 0 ? amountPaise / maxAmountPaise : 0.0;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      category,
                      style: NestText.itemTitle16.copyWith(color: c.ink),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    Money.format(amountPaise),
                    style: NestText.figures16.copyWith(color: c.ink),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              NestProgressBar(
                value: ratio,
                height: 6,
                color: barColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StaffPaySection extends ConsumerWidget {
  const StaffPaySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final staffList =
        ref.watch(activeStaffProvider).value ?? const <StaffData>[];
    if (staffList.isEmpty) return const SizedBox.shrink();

    final today = ref.watch(todayDateProvider);
    final month = Dates.month(today);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        SectionHeader(
          title: l10n.moneyStaffPay(Formatters.monthName(month)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: NestCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < staffList.length; i++) ...[
                  if (i > 0) Container(height: 1, color: c.line),
                  _StaffPayRow(staff: staffList[i], month: month),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StaffPayRow extends ConsumerWidget {
  const _StaffPayRow({required this.staff, required this.month});

  final StaffData staff;
  final String month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final name = staff.name ?? '';
    final colorHex = staff.color;
    final avatarColor = (colorHex == null || colorHex.isEmpty)
        ? c.primary
        : NestPalette.fromHex(colorHex);

    final viewAsync = ref.watch(salaryViewProvider((staff.id, month)));
    final settled =
        ref.watch(settledMonthsProvider(staff.id)).value ?? const <String>{};

    final view = viewAsync.value;
    String? sub;
    Widget? trailingValue;

    if (view != null) {
      final payroll = view.payroll;
      final rules = payroll.rules;
      if (rules != null) {
        sub = rules.type == PayType.hourly
            ? l10n.moneyBilledRate(
                Formatters.duration(payroll.billedMinutes),
                Money.format(rules.ratePerHourPaise),
              )
            : l10n.moneyMonthlyLeaves(payroll.leaveDays);
      }
      trailingValue = settled.contains(month)
          ? NestTag(label: l10n.moneyPaid, kind: NestTagKind.ok)
          : Text(
              Money.format(payroll.netPaise),
              style: NestText.figures16.copyWith(color: c.ink),
            );
    }

    return InkWell(
      onTap: () => context.push(Routes.staffSalary(staff.id)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Avatar(name: name, color: avatarColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: NestText.itemTitle16.copyWith(color: c.ink),
                    ),
                    if (sub != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: NestText.meta13.copyWith(color: c.ink3),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailingValue != null) ...[
                const SizedBox(width: 8),
                trailingValue,
              ],
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: c.ink3),
            ],
          ),
        ),
      ),
    );
  }
}

class SpendRow extends ConsumerWidget {
  const SpendRow({super.key, required this.e, required this.onTap});

  final ExpenseRow e;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final today = ref.watch(todayDateProvider);
    final me = ref.watch(myMemberIdProvider);
    final members = ref.watch(membersProvider).value ?? const <Member>[];

    final firstNames = <String, String>{
      for (final m in members)
        if ((m.firstName ?? '').isNotEmpty) m.id: m.firstName!,
    };

    final String sourceText = switch (e.source) {
      'manual' => e.addedBy == me
          ? l10n.moneySrcYou
          : l10n.moneySrcManual(firstNames[e.addedBy] ?? ''),
      'order' => l10n.moneySrcOrder(e.merchant),
      'store' => l10n.moneySrcStore,
      'bill' => l10n.moneySrcBill,
      'salary' => l10n.moneySrcSalary,
      _ => e.addedBy == me
          ? l10n.moneySrcYou
          : l10n.moneySrcManual(firstNames[e.addedBy] ?? ''),
    };

    final channel = e.orderChannel;
    final leading = (e.source == 'order' && channel != null && channel.isNotEmpty)
        ? ChannelBadge(channel: channel)
        : CategoryLetterBadge(name: e.merchant, category: e.category);

    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        e.merchant,
                        style: NestText.itemTitle16.copyWith(color: c.ink),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.moneyRowSub(
                          Formatters.dayLabel(e.date, today, l10n),
                          e.category,
                          sourceText,
                        ),
                        style: NestText.meta13.copyWith(color: c.ink3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  Money.format(e.amountPaise),
                  style: NestText.figures16.copyWith(color: c.ink),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RecentSection extends ConsumerWidget {
  const RecentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final today = ref.watch(todayDateProvider);
    final month = Dates.month(today);
    final rows = ref.watch(monthExpensesProvider(month)).value;
    if (rows == null || rows.isEmpty) return const SizedBox.shrink();

    final sorted = rows.toList()
      ..sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
      });
    final recent = sorted.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        SectionHeader(
          title: l10n.moneyRecent,
          actionLabel: l10n.moneySeeAll,
          onAction: () => context.push(Routes.moneyTransactions),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: NestCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < recent.length; i++) ...[
                  if (i > 0) Container(height: 1, color: c.line),
                  SpendRow(
                    e: recent[i],
                    onTap: () => showSpendSheet(
                      context,
                      ref,
                      existing: recent[i],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
