import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/money/money_sections.dart';
import 'package:nm_flat/features/money/spend_sheet.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

final _txMonthsProvider = StreamProvider.autoDispose<List<String>>((ref) {
  final today = ref.watch(todayDateProvider);
  final minDate = Dates.monthStart(Dates.addMonths(Dates.month(today), -13));
  return ref.watch(moneyRepoProvider).watchExpenseMonths(minDate);
});

final _txRowsProvider = StreamProvider.autoDispose
    .family<List<ExpenseRow>, String>(
      (ref, month) =>
          ref.watch(moneyRepoProvider).watchExpensesInMonth(month),
    );

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key, this.category});

  final String? category;

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchCtrl = TextEditingController();
  late String _month;
  String _query = '';
  String? _category;

  @override
  void initState() {
    super.initState();
    _month = Dates.month(ref.read(todayDateProvider));
    _category = widget.category;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final today = ref.watch(todayDateProvider);
    final thisMonth = Dates.month(today);
    final dbMonths = ref.watch(_txMonthsProvider).value ?? const <String>[];
    final rows =
        ref.watch(_txRowsProvider(_month)).value ?? const <ExpenseRow>[];

    final monthSet = <String>{thisMonth, _month, ...dbMonths};
    final months = monthSet.toList()..sort((a, b) => b.compareTo(a));

    final q = _query.trim().toLowerCase();
    final filtered = [
      for (final e in rows)
        if ((_category == null || e.category == _category) &&
            (q.isEmpty ||
                e.merchant.toLowerCase().contains(q) ||
                e.category.toLowerCase().contains(q) ||
                (e.note ?? '').toLowerCase().contains(q)))
          e,
    ]..sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
      });

    var sum = 0;
    for (final e in filtered) {
      sum += e.amountPaise;
    }

    return Scaffold(
      appBar: NestTopBar.sub(title: l10n.moneyAllSpends),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < months.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      NestChip(
                        label: Formatters.monthName(months[i]),
                        selected: months[i] == _month,
                        onTap: () => setState(() => _month = months[i]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: l10n.moneySearch,
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                ),
              ),
            ),
            if (_category != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Semantics(
                      label: l10n.moneyClearFilter(_category!),
                      button: true,
                      child: NestChip(
                        label: '× ${_category!}',
                        selected: true,
                        onTap: () => setState(() => _category = null),
                      ),
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text(
                  l10n.moneyCount(filtered.length, Money.format(sum)),
                  style: NestText.meta13.copyWith(color: c.ink3),
                ),
              ),
            ),
            if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 32,
                  ),
                  child: Center(
                    child: Text(
                      l10n.moneyNoMatch,
                      style: NestText.body15.copyWith(color: c.ink3),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: DecoratedSliver(
                  decoration: NestCard.cardDecoration(context),
                  sliver: SliverPadding(
                    padding: const EdgeInsets.all(1),
                    sliver: SliverList.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final row = filtered[i];
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (i > 0) Container(height: 1, color: c.line),
                            SpendRow(
                              e: row,
                              onTap: () => showSpendSheet(
                                context,
                                ref,
                                existing: row,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
