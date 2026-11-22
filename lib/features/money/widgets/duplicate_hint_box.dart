import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/repo/money_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class DuplicateHintBox extends ConsumerWidget {
  const DuplicateHintBox({
    super.key,
    required this.hit,
    required this.onDontAdd,
    required this.onAddAnyway,
  });

  final DuplicateHit hit;
  final VoidCallback onDontAdd;
  final VoidCallback onAddAnyway;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final today = ref.watch(todayDateProvider);

    final who = hit.whoFirstName ?? l10n.moneyWhoYou;
    final amount = Money.format(hit.amountPaise);
    final d = Dates.daysBetween(today, hit.date);
    final when = switch (d) {
      0 => l10n.moneyWhenToday,
      -1 => l10n.moneyWhenYesterday,
      _ => l10n.moneyWhenOn(Formatters.dayLabel(hit.date, today, l10n)),
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.accentSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.moneyDuplicate(who, amount, hit.merchant, when),
              style: const TextStyle(
                fontFamily: NestText.sans,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontVariations: [FontVariation.weight(600)],
              ).copyWith(color: c.accentInk),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              children: [
                NestButton(
                  label: l10n.moneyDontAdd,
                  kind: NestButtonKind.ghost,
                  onPressed: onDontAdd,
                ),
                NestButton(
                  label: l10n.moneyAddAnyway,
                  kind: NestButtonKind.primary,
                  onPressed: onAddAnyway,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
