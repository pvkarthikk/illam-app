import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/staff_text.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/staff/attendance_calendar_card.dart';
import 'package:nm_flat/features/staff/edit_staff_sheet.dart';
import 'package:nm_flat/features/staff/remove_staff_sheet.dart';
import 'package:nm_flat/features/staff/staff_controller.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/staff/visit_log_card.dart';
import 'package:nm_flat/features/staff/widgets/staff_row.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key, required this.staffId});

  final String staffId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final staffAsync = ref.watch(staffByIdProvider(staffId));
    if (staffAsync.isLoading && !staffAsync.hasValue) {
      return Scaffold(appBar: NestTopBar.sub(title: l10n.staffTitle));
    }

    final staff = staffAsync.value;
    if (staff == null) {
      return Scaffold(
        appBar: NestTopBar.sub(title: l10n.staffTitle),
        body: Center(
          child: EmptyState(
            icon: Icons.person_off_outlined,
            title: l10n.staffNotFound,
            body: '',
          ),
        ),
      );
    }

    final name = staff.name ?? '';
    final ctrl = ref.read(staffControllerProvider(staffId).notifier);
    final month = ref.watch(staffControllerProvider(staffId));
    final isAdmin = ref.watch(isAdminProvider);
    final avatarColor = staff.color != null
        ? NestPalette.fromHex(staff.color!)
        : c.primary;

    final shortDays = [
      l10n.weekdayShortMon,
      l10n.weekdayShortTue,
      l10n.weekdayShortWed,
      l10n.weekdayShortThu,
      l10n.weekdayShortFri,
      l10n.weekdayShortSat,
      l10n.weekdayShortSun,
    ];
    final window =
        '${daysText(parseWorkDays(staff.workDays), short: shortDays, daily: l10n.staffDaily)} · '
        '${timesText(parseTimes(staff.expectedTimes), staff.usualEndTime)}';
    final paise = staff.initialPayPaise ?? 0;
    final payLine = staff.initialPayType == 'hourly'
        ? l10n.staffPayHourlyLine(Money.format(paise))
        : l10n.staffPayMonthlyLine(Money.format(paise));

    return Scaffold(
      appBar: NestTopBar.sub(
        title: l10n.staffTitle,
        actions: [
          if (staff.phoneE164 != null) ...[
            IconButton(
              tooltip: l10n.staffCall(name),
              icon: const Icon(Icons.call_outlined),
              onPressed: () => ctrl.call(staff),
            ),
            IconButton(
              tooltip: l10n.staffWhatsApp(name),
              icon: const Icon(Icons.chat_outlined),
              onPressed: () => ctrl.whatsapp(staff),
            ),
          ],
          if (isAdmin)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') showEditStaffSheet(context, staff);
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Text(l10n.staffEditDetails),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Avatar(
                  name: name,
                  color: avatarColor,
                  size: AvatarSize.s72,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: NestText.title28.copyWith(color: c.ink),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.staffRoleWindow(
                          roleLabel(l10n, staff.role),
                          window,
                        ),
                        style: NestText.meta13.copyWith(color: c.ink3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        payLine,
                        style: TextStyle(
                          fontFamily: NestText.sans,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontVariations: const [FontVariation.weight(700)],
                          color: c.ink2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: staff.active
                ? NestCard(
                    child: StaffRow(staff: staff, showTopDivider: false),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NestTag(
                        label: l10n.staffFormerTag,
                        kind: NestTagKind.neutral,
                      ),
                      if (isAdmin) ...[
                        const SizedBox(height: 8),
                        NestButton(
                          label: l10n.staffRestore,
                          kind: NestButtonKind.ghost,
                          size: NestButtonSize.sm,
                          onPressed: () async {
                            final res = await ref
                                .read(staffRepoProvider)
                                .restoreStaff(staff.id);
                            ref
                                .read(snackbarProvider)
                                .show(
                                  l10n.staffRestored(name),
                                  undo: res.undo,
                                );
                          },
                        ),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AttendanceCalendarCard(staff: staff),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: VisitLogCard(staff: staff),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NestButton(
                  label: l10n.staffSalaryButton(Formatters.monthName(month)),
                  icon: Icons.currency_rupee_rounded,
                  kind: NestButtonKind.primary,
                  size: NestButtonSize.block,
                  onPressed: () => ref
                      .read(snackbarProvider)
                      .show(l10n.commonArrivesIn('P05')),
                ),
                if (isAdmin && staff.active) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: () =>
                          showRemoveStaffSheet(context, ref, staff),
                      icon: Icon(Icons.delete_outline, color: c.danger),
                      label: Text(
                        l10n.staffRemoveButton(name),
                        style: NestText.button15.copyWith(color: c.danger),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
