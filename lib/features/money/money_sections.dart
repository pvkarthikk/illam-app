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
import 'package:nm_flat/features/money/widgets/spend_pie_chart.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class WhereItWentSection extends ConsumerStatefulWidget {
  const WhereItWentSection({super.key});

  @override
  ConsumerState<WhereItWentSection> createState() => _WhereItWentSectionState();
}

class _WhereItWentSectionState extends ConsumerState<WhereItWentSection> {
  bool _showChart = false;
  SpendChartMode _chartMode = SpendChartMode.item;

  List<SpendPieSlice> _buildSlices({
    required AppLocalizations l10n,
    required List<ExpenseRow> rows,
    required List<(String, int)> catTotals,
    required String month,
    required MoneyRepo repo,
    required Set<String> dupAttempts,
  }) {
    final lites = [for (final r in rows) repo.toSpendLite(r)];
    final excluded = duplicateSalaryExpenseIds(rows, dupAttempts);

    switch (_chartMode) {
      case SpendChartMode.category:
        return [
          for (final (cat, amt) in catTotals)
            SpendPieSlice(
              label: cat,
              amountPaise: amt,
              color: NestPalette.categoryColor(cat),
            ),
        ];
      case SpendChartMode.item:
        final items = itemTotals(
          lites,
          month,
          excluded,
          otherLabel: l10n.moneyChartOther,
        );
        return [
          for (var i = 0; i < items.length; i++)
            SpendPieSlice(
              label: items[i].$1,
              amountPaise: items[i].$2,
              color: items[i].$1.toLowerCase() ==
                      l10n.moneyChartOther.toLowerCase()
                  ? NestPalette.categories['Other']!
                  : NestPalette.avatars[i % NestPalette.avatars.length],
            ),
        ];
      case SpendChartMode.people:
        final members = ref.watch(membersProvider).value ?? const <Member>[];
        final me = ref.watch(myMemberIdProvider);
        final memberLabels = <String, String>{};
        final memberColors = <String, Color>{};
        for (final m in members) {
          final rawName = m.id == me
              ? l10n.moneyYou
              : ((m.firstName ?? '').trim().isNotEmpty
                    ? m.firstName!.trim()
                    : (m.fullName ?? '').trim());
          if (rawName.isNotEmpty) memberLabels[m.id] = rawName;
          final hex = m.color ?? '';
          if (hex.isNotEmpty) memberColors[m.id] = NestPalette.fromHex(hex);
        }
        if (me.isNotEmpty) {
          memberLabels.putIfAbsent(me, () => l10n.moneyYou);
        }
        final people = peopleTotals(
          lites,
          {for (final r in rows) r.id: r.paidBy},
          memberLabels,
          month,
          excluded,
          unknownLabel: l10n.moneyChartUnknown,
        );
        return [
          for (var i = 0; i < people.length; i++)
            SpendPieSlice(
              label: people[i].label,
              amountPaise: people[i].amountPaise,
              color: memberColors[people[i].id] ??
                  NestPalette.avatars[i % NestPalette.avatars.length],
            ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final today = ref.watch(todayDateProvider);
    final month = Dates.month(today);
    final rows = ref.watch(monthExpensesProvider(month)).value;
    if (rows == null || rows.isEmpty) return const SizedBox.shrink();

    final repo = ref.watch(moneyRepoProvider);
    final dupAttempts =
        ref.watch(duplicateSalaryAttemptIdsProvider).value ?? const <String>{};
    final lites = [for (final r in rows) repo.toSpendLite(r)];
    final excluded = duplicateSalaryExpenseIds(rows, dupAttempts);
    final totals = categoryTotals(
      lites,
      {for (final r in rows) r.id: r.category},
      month,
      excluded,
    );
    if (totals.isEmpty) return const SizedBox.shrink();

    final maxAmount = totals.first.$2;
    final slices = _showChart
        ? _buildSlices(
            l10n: l10n,
            rows: rows,
            catTotals: totals,
            month: month,
            repo: repo,
            dupAttempts: dupAttempts,
          )
        : const <SpendPieSlice>[];
    final chartTotal = slices.fold<int>(0, (sum, s) => sum + s.amountPaise);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.moneyWhereItWent.toUpperCase(),
                    style: NestText.section13.copyWith(color: c.ink2),
                  ),
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                ),
                icon: Icon(
                  _showChart
                      ? Icons.pie_chart_rounded
                      : Icons.pie_chart_outline_rounded,
                  size: 18,
                ),
                label: Text(
                  _showChart ? l10n.moneyHideChart : l10n.moneyShowChart,
                  style: NestText.small12.copyWith(color: c.primary),
                ),
                onPressed: () => setState(() => _showChart = !_showChart),
              ),
            ],
          ),
        ),
        if (_showChart)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SpendPieChartCard(
              mode: _chartMode,
              onModeChanged: (m) => setState(() => _chartMode = m),
              slices: slices,
              totalPaise: chartTotal,
            ),
          ),
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
    final barColor = NestPalette.categoryColor(category);
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

/// Latest 8 expenses for [month]. [MoneyRepo.watchExpensesInMonth] already
/// orders rows by `date DESC, created_at DESC` in SQL, so no sorting is done here.
final recentMonthExpensesProvider = Provider.family<List<ExpenseRow>, String>((
  ref,
  month,
) {
  final rows = ref.watch(monthExpensesProvider(month)).value;
  if (rows == null || rows.isEmpty) return const <ExpenseRow>[];
  return rows.length <= 8 ? rows : rows.sublist(0, 8);
});

class RecentSection extends ConsumerWidget {
  const RecentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final today = ref.watch(todayDateProvider);
    final month = Dates.month(today);
    final recent = ref.watch(recentMonthExpensesProvider(month));
    if (recent.isEmpty) return const SizedBox.shrink();

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
