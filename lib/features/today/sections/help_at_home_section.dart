import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/attendance.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/features/staff/add_staff_sheet.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/staff/visit_sheet.dart';
import 'package:nm_flat/features/staff/widgets/staff_row.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class HelpAtHomeSection extends ConsumerWidget {
  const HelpAtHomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final staffAsync = ref.watch(activeStaffProvider);
    final openVisits = ref.watch(openVisitsProvider).value ?? const [];
    final today = ref.watch(todayDateProvider);
    final isAdmin = ref.watch(isAdminProvider);

    final header = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.staffHelpTitle,
                  style: NestText.cardTitle20.copyWith(color: c.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.staffHelpSub,
                  style: NestText.meta13.copyWith(color: c.ink3),
                ),
              ],
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(width: 8),
            NestButton(
              label: '+ ${l10n.commonAdd}',
              kind: NestButtonKind.ghost,
              size: NestButtonSize.sm,
              onPressed: () => showAddStaffSheet(context),
            ),
          ],
        ],
      ),
    );

    final staffList = staffAsync.value;
    if (staffList == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: NestCard(child: header),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: NestCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            if (staffList.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  l10n.staffNoneYet,
                  style: NestText.meta13.copyWith(color: c.ink3),
                ),
              )
            else
              for (final staff in staffList) ...[
                for (final alert in alertsFor(
                  openVisits: [
                    for (final v in openVisits)
                      if (v.staffId == staff.id &&
                          (v.date?.isNotEmpty ?? false))
                        toLite(v),
                  ],
                  today: today,
                ))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: AlertLine(
                      icon: Icons.schedule_rounded,
                      text: switch (alert) {
                        NotMarkedOut(:final date) => l10n.staffAlertNotMarkedOut(
                          staff.name ?? '',
                          Formatters.dayLabel(date, today, l10n),
                        ),
                        TwoOpenVisits() => l10n.staffAlertTwoOpen(
                          staff.name ?? '',
                        ),
                      },
                      actionLabel: l10n.commonFix,
                      onAction: () => showVisitSheet(
                        context,
                        staffId: staff.id,
                        date: alert.date,
                      ),
                    ),
                  ),
                StaffRow(staff: staff),
              ],
          ],
        ),
      ),
    );
  }
}
