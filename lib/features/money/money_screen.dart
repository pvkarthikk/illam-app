import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/features/money/bills_section.dart';
import 'package:nm_flat/features/money/draft_expenses_section.dart';
import 'package:nm_flat/features/money/money_hero.dart';
import 'package:nm_flat/features/money/money_sections.dart';
import 'package:nm_flat/features/money/spend_sheet.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class MoneyScreen extends ConsumerStatefulWidget {
  const MoneyScreen({super.key});

  @override
  ConsumerState<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends ConsumerState<MoneyScreen> {
  bool _openingAdd = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_openingAdd &&
        GoRouterState.of(context).uri.queryParameters['add'] == '1') {
      _openingAdd = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await showSpendSheet(context, ref);
        if (mounted) context.go(Routes.money);
        _openingAdd = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final today = ref.watch(todayDateProvider);
    final month = Dates.month(today);
    final empty = ref.watch(
      monthExpensesProvider(month).select((a) => a.value?.isEmpty ?? true),
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          controller:
              ref.watch(tabScrollControllersProvider)[NestTab.money.index],
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            NestTopBar.tab(eyebrow: l10n.moneyEyebrow, title: l10n.moneyTitle),
            const SizedBox(height: 8),
            const MoneyHero(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NestButton(
                    label: l10n.moneyAddSpend,
                    size: NestButtonSize.block,
                    onPressed: () => showSpendSheet(context, ref),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.moneyQuickAddHint,
                    style: NestText.meta13.copyWith(color: c.ink3),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const DraftExpensesSection(),
            const BillsSection(),
            if (empty) ...[
              const StaffPaySection(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: NestCard(
                  child: EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: l10n.moneyEmptyTitle,
                    body: l10n.moneyEmptyBody,
                  ),
                ),
              ),
            ] else ...[
              const WhereItWentSection(),
              const StaffPaySection(),
              const RecentSection(),
            ],
          ],
        ),
      ),
    );
  }
}
