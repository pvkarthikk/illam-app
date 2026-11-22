import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/money_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/money_math.dart';
import 'package:nm_flat/core/domain/salary_months.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/money/budget_sheet.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class MoneyHero extends ConsumerWidget {
  const MoneyHero({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final cs = Theme.of(context).colorScheme;
    final spent = ref.watch(monthSpentProvider);
    final budget = ref.watch(budgetPaiseProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final today = ref.watch(todayDateProvider);
    final month = Dates.month(today);
    final prev = prevMonth(month);
    final prevRows =
        ref.watch(monthExpensesProvider(prev)).value ?? const <ExpenseRow>[];
    final dupAttempts =
        ref.watch(duplicateSalaryAttemptIdsProvider).value ?? const <String>{};
    final repo = ref.watch(moneyRepoProvider);
    final prevTotal = monthTotal(
      [for (final r in prevRows) repo.toSpendLite(r)],
      prev,
      duplicateSalaryExpenseIds(prevRows, dupAttempts),
    );

    final fg = cs.onPrimary;
    final onPrimaryMuted = fg.withValues(alpha: 0.85);
    final overBudget = budget != null && spent > budget;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(26),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -40,
              child: ClipOval(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: KolamBackground(
                    color: fg.withValues(alpha: 0.18),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n
                        .moneySpentIn(Formatters.monthName(month))
                        .toUpperCase(),
                    style: NestText.eyebrow12.copyWith(color: onPrimaryMuted),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Money.format(spent),
                    style: NestText.bigNumber54.copyWith(
                      fontSize: 46,
                      color: fg,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (budget != null)
                    _BudgetProgress(
                      spent: spent,
                      budget: budget,
                      overBudget: overBudget,
                      today: today,
                      fg: fg,
                      barColor: overBudget ? c.danger : c.accent,
                      onTap: isAdmin
                          ? () => showBudgetSheet(context, ref)
                          : null,
                    )
                  else if (isAdmin)
                    NestButton(
                      label: l10n.moneySetBudget,
                      kind: NestButtonKind.tonal,
                      size: NestButtonSize.sm,
                      onPressed: () => showBudgetSheet(context, ref),
                    )
                  else
                    Text(
                      l10n.moneyNoBudget,
                      style: NestText.meta13.copyWith(color: onPrimaryMuted),
                    ),
                  if (prevTotal > 0) ...[
                    const SizedBox(height: 12),
                    Text(
                      spent <= prevTotal
                          ? l10n.moneyBelowPrev(
                              Money.format(prevTotal - spent),
                              Formatters.monthName(prev),
                            )
                          : l10n.moneyAbovePrev(
                              Money.format(spent - prevTotal),
                              Formatters.monthName(prev),
                            ),
                      style: NestText.meta13.copyWith(color: onPrimaryMuted),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  const _BudgetProgress({
    required this.spent,
    required this.budget,
    required this.overBudget,
    required this.today,
    required this.fg,
    required this.barColor,
    this.onTap,
  });

  final int spent;
  final int budget;
  final bool overBudget;
  final String today;
  final Color fg;
  final Color barColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ratio = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final labelText = overBudget
        ? l10n.moneyOverBudget(Money.format(spent - budget))
        : '${l10n.moneyLeftOf(Money.format(budget - spent), Money.format(budget))} · ${l10n.moneyDaysToGo(daysToGo(today))}';

    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NestProgressBar(
            value: ratio,
            color: barColor,
            track: fg.withValues(alpha: 0.20),
          ),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              Text(
                labelText,
                style: NestText.meta13.copyWith(
                  color: fg.withValues(alpha: 0.92),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: content,
      ),
    );
  }
}
