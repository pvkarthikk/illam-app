import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/money/budget_sheet.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class MonthSoFarSection extends ConsumerWidget {
  const MonthSoFarSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final spent = ref.watch(monthSpentProvider);
    final budget = ref.watch(budgetPaiseProvider);
    final billsDue = ref.watch(billsDueCountProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final today = ref.watch(todayDateProvider);
    final month = Dates.month(today);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        SectionHeader(
          title: l10n.todayMonthSoFar(Formatters.monthName(month)),
          actionLabel: l10n.todayMoneyLink,
          onAction: () => context.go(Routes.money),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: NestCard(
            padding: const EdgeInsets.all(16),
            onTap: () => context.go(Routes.money),
            child: budget != null
                ? _BudgetCardBody(
                    spent: spent,
                    budget: budget,
                    billsDue: billsDue,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            l10n.todaySpentSoFar(Money.format(spent)),
                            style: NestText.itemTitle16.copyWith(color: c.ink),
                          ),
                          if (billsDue > 0)
                            NestTag(
                              label: l10n.todayBillsDue(billsDue),
                              kind: NestTagKind.accent,
                            ),
                        ],
                      ),
                      if (isAdmin) ...[
                        const SizedBox(height: 12),
                        NestButton(
                          label: l10n.todaySetBudget,
                          kind: NestButtonKind.tonal,
                          size: NestButtonSize.sm,
                          onPressed: () => showBudgetSheet(context, ref),
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

class _BudgetCardBody extends StatelessWidget {
  const _BudgetCardBody({
    required this.spent,
    required this.budget,
    required this.billsDue,
  });

  final int spent;
  final int budget;
  final int billsDue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final pct = (spent * 100 / budget).round();
    final over = spent > budget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Money.format(spent),
          style: NestText.bigNumber30.copyWith(color: c.ink),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              l10n.todayOfBudget(Money.format(budget), pct),
              style: NestText.meta13.copyWith(color: c.ink2),
            ),
            if (billsDue > 0)
              NestTag(
                label: l10n.todayBillsDue(billsDue),
                kind: NestTagKind.accent,
              ),
          ],
        ),
        const SizedBox(height: 10),
        NestProgressBar(
          value: min(1.0, spent / budget),
          color: over ? c.danger : c.primary,
        ),
      ],
    );
  }
}
