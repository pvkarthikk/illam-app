import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/backup/backup_health.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/staff_text.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/features/account/home_sheets.dart';
import 'package:nm_flat/features/account/member_sheet.dart';
import 'package:nm_flat/features/backup/backup_texts.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';
import 'package:nm_flat/features/staff/add_staff_sheet.dart';
import 'package:nm_flat/features/staff/former_staff_section.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/staff/widgets/staff_row.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

String adminNames(List<String> firstNames, AppLocalizations l10n) {
  if (firstNames.isEmpty) return '';
  if (firstNames.length == 1) return firstNames.single;
  if (firstNames.length == 2) return l10n.homeOr(firstNames[0], firstNames[1]);
  final head = firstNames.sublist(0, firstNames.length - 1).join(', ');
  return l10n.homeOr(head, firstNames.last);
}

Color _memberColor(NestColors c, String? hex) =>
    (hex != null && hex.isNotEmpty) ? NestPalette.fromHex(hex) : c.primary;

Widget _pad(Widget child) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child);

Widget _iconTile(IconData icon, Color bg, Color fg) => Container(
  width: 44,
  height: 44,
  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
  child: Icon(icon, color: fg),
);

Widget _cardRow(
  BuildContext context, {
  required Widget leading,
  required String title,
  required String sub,
  Widget? trailing,
  VoidCallback? onTap,
}) {
  final c = context.nest;
  final row = Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        leading,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: NestText.itemTitle16.copyWith(color: c.ink)),
              const SizedBox(height: 2),
              Text(sub, style: NestText.meta13.copyWith(color: c.ink3)),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ],
    ),
  );
  return onTap == null ? row : InkWell(onTap: onTap, child: row);
}

Widget _dividedCard(BuildContext context, List<Widget> rows) {
  final line = context.nest.line;
  return _pad(
    NestCard(
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, color: line),
            rows[i],
          ],
        ],
      ),
    ),
  );
}

class HomeBackupCard extends ConsumerWidget {
  const HomeBackupCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    ref.watch(minuteTickProvider);
    final nowMs = ref.read(clockProvider).nowMs;
    final health =
        ref.watch(backupHealthProvider).value ??
        const BackupHealth(state: HealthState.none);
    final texts = healthTexts(l10n, health, nowMs);

    return _pad(
      NestCard(
        onTap: () => context.push(Routes.backup),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _iconTile(Icons.cloud_outlined, c.paper2, c.ink2),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      texts.title,
                      style: NestText.itemTitle16.copyWith(
                        color: texts.ok ? c.ink : c.accentInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      texts.thisPhone,
                      style: NestText.meta13.copyWith(color: c.ink3),
                    ),
                    for (final other in texts.others) ...[
                      const SizedBox(height: 2),
                      Text(
                        other,
                        style: NestText.meta13.copyWith(color: c.ink2),
                      ),
                    ],
                    if (texts.hint != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        texts.hint!,
                        style: NestText.small12.copyWith(color: c.ink3),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: c.ink3),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeInviteSection extends ConsumerWidget {
  const HomeInviteSection({
    super.key,
    required this.isAdmin,
    required this.adminFirstNames,
  });

  final bool isAdmin;
  final List<String> adminFirstNames;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return _pad(
      isAdmin
          ? NestButton(
              label: l10n.homeInvite,
              kind: NestButtonKind.primary,
              size: NestButtonSize.block,
              onPressed: () => context.push(Routes.invite),
            )
          : AlertLine(
              icon: Icons.lock_outline_rounded,
              text: l10n.homeAskAdmins(adminNames(adminFirstNames, l10n)),
            ),
    );
  }
}

class HomeFamilySection extends StatelessWidget {
  const HomeFamilySection({
    super.key,
    required this.members,
    required this.myMemberId,
  });

  final List<Member> members;
  final String myMemberId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: '${l10n.homeFamily} (${members.length})'),
        const SizedBox(height: 8),
        _dividedCard(context, [
          for (final m in members)
            _cardRow(
              context,
              onTap: () => showMemberSheet(context, m),
              leading: Avatar(
                name: m.fullName ?? '',
                color: _memberColor(c, m.color),
                size: AvatarSize.s52,
              ),
              title: m.id == myMemberId
                  ? '${m.fullName ?? ''} ${l10n.homeYou}'
                  : (m.fullName ?? ''),
              sub: l10n.homeMemberSub(
                m.deviceModel ?? '',
                DateFormat('MMM yyyy', 'en').format(
                  DateTime.fromMillisecondsSinceEpoch(m.joinedAt ?? 0),
                ),
              ),
              trailing: NestTag(
                label: m.role == 'admin' ? l10n.roleAdmin : l10n.roleMember,
                kind: m.role == 'admin'
                    ? NestTagKind.accent
                    : NestTagKind.neutral,
              ),
            ),
        ]),
      ],
    );
  }
}

class HomeHouseHelpSection extends ConsumerWidget {
  const HomeHouseHelpSection({super.key, required this.isAdmin});

  final bool isAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final staff = ref.watch(activeStaffProvider).value ?? const <StaffData>[];
    final month = Dates.month(ref.watch(todayDateProvider));
    final shorts = [
      l10n.weekdayShortMon,
      l10n.weekdayShortTue,
      l10n.weekdayShortWed,
      l10n.weekdayShortThu,
      l10n.weekdayShortFri,
      l10n.weekdayShortSat,
      l10n.weekdayShortSun,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: '${l10n.homeHouseHelp} (${staff.length})'),
        const SizedBox(height: 8),
        if (staff.isEmpty)
          _pad(
            NestCard(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.homeNoHelp,
                style: NestText.body15.copyWith(color: c.ink3),
              ),
            ),
          )
        else
          _dividedCard(context, [
            for (final s in staff)
              _cardRow(
                context,
                onTap: () => context.push(Routes.staff(s.id)),
                leading: Avatar(
                  name: s.name ?? '',
                  color: _memberColor(c, s.color),
                  size: AvatarSize.s32,
                ),
                title: s.name ?? '',
                sub: [
                  if (roleLabel(l10n, s.role).isNotEmpty)
                    roleLabel(l10n, s.role),
                  if (daysText(
                    ref.watch(workDaysProvider((s.id, month))) ??
                        parseWorkDays(s.workDays),
                    short: shorts,
                    daily: l10n.staffDaily,
                  ).isNotEmpty)
                    daysText(
                      ref.watch(workDaysProvider((s.id, month))) ??
                          parseWorkDays(s.workDays),
                      short: shorts,
                      daily: l10n.staffDaily,
                    ),
                  if (timesText(
                    parseTimes(s.expectedTimes),
                    s.usualEndTime,
                  ).isNotEmpty)
                    timesText(parseTimes(s.expectedTimes), s.usualEndTime),
                ].join(' · '),
                trailing: Icon(Icons.chevron_right_rounded, color: c.ink3),
              ),
          ]),
        if (isAdmin) ...[
          const SizedBox(height: 12),
          _pad(
            NestButton(
              label: l10n.homeAddHelp,
              kind: NestButtonKind.ghost,
              size: NestButtonSize.block,
              onPressed: () => showAddStaffSheet(context),
            ),
          ),
        ],
        const SizedBox(height: 12),
        _pad(const FormerStaffSection()),
      ],
    );
  }
}

class HomeRolesSection extends StatelessWidget {
  const HomeRolesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    Widget roleBox(String title, String body) => NestCard(
      fill: c.paper2,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: NestText.button15.copyWith(color: c.ink)),
          const SizedBox(height: 4),
          Text(body, style: NestText.body15.copyWith(color: c.ink2)),
        ],
      ),
    );

    return _pad(
      NestCard(
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          title: Text(
            l10n.homeRolesTitle,
            style: NestText.itemTitle16.copyWith(color: c.ink),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            roleBox(l10n.roleAdmin, l10n.homeRolesAdmin),
            const SizedBox(height: 10),
            roleBox(l10n.roleMember, l10n.homeRolesMember),
            const SizedBox(height: 10),
            Text(
              l10n.homeRolesFootnote,
              style: NestText.small12.copyWith(color: c.ink3),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeLeaveDeleteSection extends ConsumerWidget {
  const HomeLeaveDeleteSection({
    super.key,
    required this.homeName,
    required this.isAdmin,
  });

  final String homeName;
  final bool isAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: l10n.homeLeaveDelete),
          const SizedBox(height: 8),
          _pad(
            NestButton(
              label: l10n.homeLeave(homeName),
              kind: NestButtonKind.dangerGhost,
              size: NestButtonSize.block,
              onPressed: () => showLeaveSheet(context, ref),
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 8),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: TextButton.icon(
                  onPressed: () => showDeleteHomeSheet(context, ref, homeName),
                  icon: Icon(
                    Icons.delete_forever_outlined,
                    color: c.danger,
                    size: 18,
                  ),
                  label: Text(
                    l10n.homeDelete,
                    style: NestText.button15.copyWith(color: c.danger),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
