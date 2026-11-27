import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/features/money/bill_scan_sheet.dart';
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
  bool _openingAction = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_openingAction) return;
    final qp = GoRouterState.of(context).uri.queryParameters;
    final openAdd = qp['add'] == '1';
    final openScan = qp['scan'] == '1';
    if (openAdd || openScan) {
      _openingAction = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        if (openScan) {
          await showBillScanSheet(context, ref);
        } else {
          await showSpendSheet(context, ref);
        }
        if (mounted) context.go(Routes.money);
        _openingAction = false;
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final textScale = MediaQuery.textScalerOf(context).scale(1);
                      final stackButtons =
                          constraints.maxWidth < 330 || textScale >= 1.4;
                      final addButton = NestButton(
                        label: l10n.moneyAddSpend,
                        size: NestButtonSize.block,
                        onPressed: () => showSpendSheet(context, ref),
                      );
                      final scanButton = NestButton(
                        label: l10n.moneyScanBill,
                        icon: Icons.document_scanner_outlined,
                        kind: NestButtonKind.tonal,
                        size: NestButtonSize.block,
                        onPressed: () => showBillScanSheet(context, ref),
                      );
                      if (stackButtons) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            addButton,
                            const SizedBox(height: 10),
                            scanButton,
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: addButton),
                          const SizedBox(width: 10),
                          Expanded(child: scanButton),
                        ],
                      );
                    },
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
            const DraftExpensesSection(),
          ],
        ),
      ),
    );
  }
}
