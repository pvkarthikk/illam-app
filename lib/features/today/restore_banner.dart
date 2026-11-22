import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/backup/separate_copy.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/member_op.dart';
import 'package:nm_flat/features/account/home_sheets.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

const int thirtyDaysMs = 30 * 24 * 60 * 60 * 1000;

/// Shared helper to fork an unresolved/dead-kit restored home into a standalone copy.
Future<void> forkSeparateHome(
  BuildContext context,
  WidgetRef ref, {
  required String oldHomeId,
  required String homeName,
  required int createdAtMs,
}) async {
  final l = AppLocalizations.of(context);
  final dateStr = DateFormat(
    'd MMM yyyy',
    'en',
  ).format(DateTime.fromMillisecondsSinceEpoch(createdAtMs));
  await SeparateCopy(ref.read).make(
    oldHomeId,
    newHomeName: l.restoreSeparateName(homeName, dateStr),
  );
  if (context.mounted) {
    context.go(Routes.today);
  }
}

/// Displays the <30-day provisional restore banner on Today and triggers the once-per-run dead-kit sheet.
class RestoreBanner extends ConsumerStatefulWidget {
  const RestoreBanner({super.key});

  @override
  ConsumerState<RestoreBanner> createState() => _RestoreBannerState();
}

class _RestoreBannerState extends ConsumerState<RestoreBanner> {
  static final Set<String> _shownDeadThisStart = {};

  Future<void> _showDeadSheet({
    required String homeId,
    required String homeName,
    required int deadAtMs,
    required int backupCreatedAtMs,
  }) async {
    final l = AppLocalizations.of(context);
    final dateStr = DateFormat(
      'd MMM yyyy',
      'en',
    ).format(DateTime.fromMillisecondsSinceEpoch(deadAtMs));

    await showNestSheet<void>(
      context,
      (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NestSheetHeader(
            title: homeName,
            lead: l.restoreDeadKit(dateStr, homeName),
          ),
          NestButton(
            label: l.restoreSeparateCopy,
            kind: NestButtonKind.primary,
            size: NestButtonSize.block,
            onPressed: () async {
              Navigator.of(ctx).pop();
              await forkSeparateHome(
                context,
                ref,
                oldHomeId: homeId,
                homeName: homeName,
                createdAtMs: backupCreatedAtMs,
              );
            },
          ),
          const SizedBox(height: 10),
          NestButton(
            label: l.restoreRemoveFromPhone,
            kind: NestButtonKind.dangerGhost,
            size: NestButtonSize.block,
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(homeEraserProvider).erase(homeId);
              await ref.read(prefsProvider).setText('recoverDead_$homeId', null);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prefs = ref.watch(prefsProvider);
    ref.watch(minuteTickProvider);
    final home = ref.watch(currentHomeProvider).value;
    final homeId =
        home?.id ??
        ref.watch(currentHomeIdProvider).value ??
        prefs.currentHomeId;
    if (homeId == null || homeId.isEmpty) return const SizedBox.shrink();

    final homeName = home?.name ?? '';
    final provRaw = prefs.getText('provisionalRestore_$homeId');
    final provAtRaw = prefs.getText('provisionalRestoreAt_$homeId');
    final provCreatedMs = int.tryParse(provRaw ?? '');
    final provAtMs = int.tryParse(provAtRaw ?? '');
    final nowMs = ref.read(clockProvider).nowMs;

    final deadRaw = prefs.getText('recoverDead_$homeId');
    if (deadRaw != null &&
        deadRaw.isNotEmpty &&
        !_shownDeadThisStart.contains(homeId)) {
      _shownDeadThisStart.add(homeId);
      int deadAtMs = nowMs;
      try {
        final decoded = jsonDecode(deadRaw) as Map<String, Object?>;
        deadAtMs = (decoded['at'] as num?)?.toInt() ?? nowMs;
      } on Object {
        // Fallback to current time if JSON malformed.
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(
          _showDeadSheet(
            homeId: homeId,
            homeName: homeName,
            deadAtMs: deadAtMs,
            backupCreatedAtMs: provCreatedMs ?? deadAtMs,
          ),
        );
      });
    }

    if (provCreatedMs == null || provAtMs == null) {
      return const SizedBox.shrink();
    }
    if (nowMs - provAtMs >= thirtyDaysMs) {
      return const SizedBox.shrink();
    }

    final dateStr = DateFormat(
      'd MMM yyyy',
      'en',
    ).format(DateTime.fromMillisecondsSinceEpoch(provCreatedMs));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: InfoBanner(
        icon: Icons.cloud_done_outlined,
        title: l.restoreBanner(dateStr, homeName),
        subtitle: '',
        info: true,
      ),
    );
  }
}

final effectiveRecoversProvider = FutureProvider<List<MemberOp>>((ref) async {
  final homeId = ref.watch(currentHomeIdProvider).value;
  if (homeId == null) return const [];
  ref.watch(membersProvider);
  return ref.read(membershipLogProvider).effectiveRecovers(homeId);
});

class HomeRestoreNotices extends ConsumerWidget {
  const HomeRestoreNotices({
    super.key,
    required this.homeId,
    required this.homeName,
    required this.members,
    required this.isAdmin,
  });

  final String homeId;
  final String homeName;
  final List<Member> members;
  final bool isAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    final prefs = ref.watch(prefsProvider);
    ref.watch(minuteTickProvider);
    final nowMs = ref.read(clockProvider).nowMs;

    final provCreatedMs = int.tryParse(
      prefs.getText('provisionalRestore_$homeId') ?? '',
    );
    final provAtMs = int.tryParse(
      prefs.getText('provisionalRestoreAt_$homeId') ?? '',
    );
    final showQuietNote =
        provCreatedMs != null &&
        provAtMs != null &&
        nowMs - provAtMs >= thirtyDaysMs;

    final recovers = isAdmin
        ? (ref.watch(effectiveRecoversProvider).value ?? const <MemberOp>[])
        : const <MemberOp>[];
    final myDeviceId = prefs.deviceId;
    final byId = {for (final m in members) m.id: m};
    final visibleRecovers = <({MemberOp op, Member member})>[];
    for (final op in recovers) {
      if (op.authorDeviceId == myDeviceId) continue;
      if (prefs.getFlag('recoverSeen_${op.opId}')) continue;
      final mId = op.payload['memberId'] as String?;
      final m = mId == null ? null : byId[mId];
      if (m == null) continue;
      visibleRecovers.add((op: op, member: m));
    }

    if (!showQuietNote && visibleRecovers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showQuietNote) ...[
            Builder(
              builder: (_) {
                final dateStr = DateFormat(
                  'd MMM yyyy',
                  'en',
                ).format(DateTime.fromMillisecondsSinceEpoch(provCreatedMs));
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.restoreBanner(dateStr, homeName),
                      style: NestText.meta13.copyWith(color: c.ink3),
                    ),
                    TextButton(
                      onPressed: () => forkSeparateHome(
                        context,
                        ref,
                        oldHomeId: homeId,
                        homeName: homeName,
                        createdAtMs: provCreatedMs,
                      ),
                      child: Text(
                        l.restoreSeparateCopy,
                        style: NestText.button15.copyWith(color: c.primary),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
          for (final item in visibleRecovers) ...[
            if (showQuietNote) const SizedBox(height: 8),
            NestCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.restoreOtherAdmin(
                      item.member.firstName ??
                          Names.firstName(item.member.fullName ?? ''),
                      homeName,
                    ),
                    style: NestText.body15.copyWith(color: c.ink),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: NestButton(
                          label: l.restoreKeep,
                          kind: NestButtonKind.ghost,
                          size: NestButtonSize.sm,
                          onPressed: () async {
                            await prefs.setFlag(
                              'recoverSeen_${item.op.opId}',
                              true,
                            );
                            ref.invalidate(effectiveRecoversProvider);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NestButton(
                          label: l.restoreRemove,
                          kind: NestButtonKind.danger,
                          size: NestButtonSize.sm,
                          onPressed: () => showRemoveMemberSheet(
                            context,
                            ref,
                            item.member,
                            onRemoved: () async {
                              await prefs.setFlag(
                                'recoverSeen_${item.op.opId}',
                                true,
                              );
                              ref.invalidate(effectiveRecoversProvider);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
