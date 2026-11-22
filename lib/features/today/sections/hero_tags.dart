import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/attendance.dart';
import 'package:nm_flat/core/domain/staff_text.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/today/sections/sync_tag.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Hero tag showing sync freshness and opening Home details.
class SyncPulseTag extends StatelessWidget {
  const SyncPulseTag({super.key});

  @override
  Widget build(BuildContext context) => const SyncTag();
}

/// Banner shown at the top of Today when the device has no connectivity.
class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isOfflineProvider)) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: AlertLine(icon: Icons.cloud_off_rounded, text: l10n.todayOffline),
    );
  }
}

class HeroTags extends ConsumerWidget {
  const HeroTags({super.key});

  Widget _tappableTag({
    required String label,
    required VoidCallback onTap,
    NestTagKind kind = NestTagKind.neutral,
  }) => Semantics(
    button: true,
    excludeSemantics: true,
    label: label,
    onTap: onTap,
    child: InkWell(
      customBorder: const StadiumBorder(),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: Center(
          widthFactor: 1.0,
          child: NestTag(label: label, kind: kind),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final staffList =
        ref.watch(activeStaffProvider).value ?? const <StaffData>[];
    final visits = ref.watch(visitsTodayProvider).value ?? const <Visit>[];
    final leaves = ref.watch(leavesTodayProvider).value ?? const <Leave>[];
    final today = ref.watch(todayDateProvider);

    var atHomeCount = 0;
    for (final s in staffList) {
      final lites = [
        for (final v in visits)
          if (v.staffId == s.id) toLite(v),
      ];
      final leaveToday = leaves.any((l) => l.staffId == s.id);
      final st = staffStatusToday(
        today: today,
        workDays: parseWorkDays(s.workDays),
        visitsToday: lites,
        leaveToday: leaveToday,
      );
      if (st is StatusIn) atHomeCount++;
    }

    final budget = ref.watch(budgetPaiseProvider);
    final spent = ref.watch(monthSpentProvider);
    final billsDue = ref.watch(billsDueCountProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const SyncPulseTag(),
        if (atHomeCount > 0)
          NestTag(
            label: l10n.todayStaffAtHome(atHomeCount),
            kind: NestTagKind.ok,
          )
        else
          NestTag(label: l10n.todayNoStaff),
        if (budget == null)
          _tappableTag(
            label: l10n.todaySetABudget,
            onTap: () => context.go(Routes.money),
          )
        else if (spent <= budget)
          NestTag(label: l10n.todayBudgetLeft(Money.format(budget - spent)))
        else
          NestTag(
            label: l10n.todayBudgetOver(Money.format(spent - budget)),
            kind: NestTagKind.danger,
          ),
        if (billsDue > 0)
          _tappableTag(
            label: l10n.todayBillsDue(billsDue),
            kind: NestTagKind.accent,
            onTap: () => context.go(Routes.money),
          ),
      ],
    );
  }
}
