import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/attendance.dart';
import 'package:nm_flat/core/domain/staff_text.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';
import 'package:nm_flat/features/staff/staff_actions.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/staff/visit_sheet.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

String roleLabel(AppLocalizations l10n, String? role) => switch (role) {
  'House help' => l10n.staffRoleHouseHelp,
  'Cook' => l10n.staffRoleCook,
  'Driver' => l10n.staffRoleDriver,
  'Nanny' => l10n.staffRoleNanny,
  'Gardener' => l10n.staffRoleGardener,
  _ => role ?? '',
};

class StaffRow extends ConsumerWidget {
  const StaffRow({super.key, required this.staff, this.showTopDivider = true});

  final StaffData staff;
  final bool showTopDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final today = ref.watch(todayDateProvider);
    final visits = (ref.watch(visitsTodayProvider).value ?? const [])
        .where((v) => v.staffId == staff.id)
        .toList();
    final leaves = ref.watch(leavesTodayProvider).value ?? const [];
    final leaveToday = leaves.any((l) => l.staffId == staff.id);

    final lites = [for (final v in visits) toLite(v)];
    final status = staffStatusToday(
      today: today,
      workDays:
          ref.watch(workDaysProvider((staff.id, Dates.month(today)))) ??
          parseWorkDays(staff.workDays),
      visitsToday: lites,
      leaveToday: leaveToday,
    );
    final times = timesText(
      parseTimes(staff.expectedTimes),
      staff.usualEndTime,
    );
    final avatarColor = staff.color != null
        ? NestPalette.fromHex(staff.color!)
        : c.primary;
    final actions = ref.read(staffActionsProvider.notifier);
    final pending = ref.watch(
      staffActionsProvider.select((ids) => ids.contains(staff.id)),
    );

    Visit? newestOpen;
    for (final v in visits) {
      if (v.outAt == null &&
          (newestOpen == null || (v.inAt ?? 0) > (newestOpen.inAt ?? 0))) {
        newestOpen = v;
      }
    }

    final tickNow = ref.watch(minuteTickProvider).value;
    final nowMs =
        tickNow?.millisecondsSinceEpoch ?? ref.read(clockProvider).nowMs;

    final Widget statusLine = switch (status) {
      StatusExpected() => Text(
        l10n.staffExpected(times),
        style: NestText.meta13.copyWith(color: c.ink2),
      ),
      StatusIn(:final sinceMs) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _BlinkingDot(color: c.ok),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n.staffInSince(
                Formatters.time12Ms(sinceMs),
                Formatters.duration(liveMinutes(lites, nowMs)),
              ),
              style: TextStyle(
                fontFamily: NestText.sans,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                fontVariations: const [FontVariation.weight(800)],
                color: c.ok,
              ),
            ),
          ),
        ],
      ),
      StatusDone(:final totalMinutes, :final lastOutMs) => Text(
        l10n.staffDoneToday(
          Formatters.duration(totalMinutes),
          Formatters.time12Ms(lastOutMs),
        ),
        style: NestText.meta13.copyWith(color: c.ink2),
      ),
      StatusLeave() => Text(
        l10n.staffOnLeaveToday,
        style: NestText.meta13.copyWith(color: c.ink2),
      ),
      StatusOff() => Text(
        l10n.staffDayOff,
        style: NestText.meta13.copyWith(color: c.ink2),
      ),
    };

    final Widget actionButton = switch (status) {
      StatusExpected() => NestButton(
        label: l10n.staffMarkIn,
        icon: Icons.login_rounded,
        kind: NestButtonKind.primary,
        size: NestButtonSize.sm,
        onPressed: pending ? null : () => actions.markIn(staff),
      ),
      StatusIn() => NestButton(
        label: l10n.staffMarkOut,
        icon: Icons.logout_rounded,
        kind: NestButtonKind.accent,
        size: NestButtonSize.sm,
        onPressed: pending || newestOpen == null
            ? null
            : () => actions.markOut(staff, newestOpen!),
      ),
      StatusDone() => NestButton(
        label: '+ ${l10n.staffVisitButton}',
        kind: NestButtonKind.ghost,
        size: NestButtonSize.sm,
        semanticLabel: l10n.staffStartAnother(staff.name ?? ''),
        onPressed: pending ? null : () => actions.markIn(staff),
      ),
      StatusLeave() => NestButton(
        label: l10n.staffChange,
        kind: NestButtonKind.ghost,
        size: NestButtonSize.sm,
        onPressed: () =>
            showVisitSheet(context, staffId: staff.id, date: today),
      ),
      StatusOff() => NestButton(
        label: l10n.staffMarkIn,
        kind: NestButtonKind.primary,
        size: NestButtonSize.sm,
        onPressed: pending ? null : () => actions.markIn(staff),
      ),
    };

    final roleStr = roleLabel(l10n, staff.role);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTopDivider) Divider(height: 1, color: c.line),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.push(Routes.staff(staff.id)),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 56),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Avatar(
                              name: staff.name ?? '',
                              color: avatarColor,
                              size: AvatarSize.s52,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: staff.name ?? '',
                                          style: TextStyle(
                                            fontFamily: NestText.sans,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            fontVariations: const [
                                              FontVariation.weight(800),
                                            ],
                                            color: c.ink,
                                          ),
                                        ),
                                        if (roleStr.isNotEmpty)
                                          TextSpan(
                                            text: ' · $roleStr',
                                            style: NestText.meta13.copyWith(
                                              color: c.ink3,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  statusLine,
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              actionButton,
            ],
          ),
        ),
      ],
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot({required this.color});

  final Color color;

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disable = MediaQuery.disableAnimationsOf(context);
    if (disable) {
      _ctrl?.dispose();
      _ctrl = null;
    } else {
      _ctrl ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1600),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
    );
    final ctrl = _ctrl;
    if (ctrl == null) return dot;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1.0).animate(ctrl),
      child: dot,
    );
  }
}
