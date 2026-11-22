import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/fingerprint.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/account/appearance_controller.dart';
import 'package:nm_flat/features/account/home_sheets.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

final _memberKeyProvider =
    FutureProvider.family<String, ({String homeId, String memberId})>((
      ref,
      args,
    ) async {
      final db = ref.watch(dbProvider);
      final row =
          await (db.select(db.memberDevices)
                ..where(
                  (d) =>
                      d.homeId.equals(args.homeId) &
                      d.memberId.equals(args.memberId) &
                      d.active.equals(true),
                )
                ..orderBy([(d) => OrderingTerm.asc(d.addedAt)])
                ..limit(1))
              .getSingleOrNull();
      if (row == null || row.signPub.isEmpty) return '';
      return fingerprintOf(decodeKey(row.signPub));
    });

Future<void> showMemberSheet(BuildContext context, Member m) =>
    showNestSheet<void>(
      context,
      (ctx) => _MemberSheetBody(member: m, sheetContext: ctx),
    );

class _MemberSheetBody extends ConsumerWidget {
  const _MemberSheetBody({required this.member, required this.sheetContext});

  final Member member;
  final BuildContext sheetContext;

  String _howJoined(
    AppLocalizations l10n,
    Member live,
    List<Member> activeMembers,
  ) {
    switch (live.joinedVia) {
      case 'created':
        return l10n.memberHowCreated;
      case 'qr':
        return l10n.memberHowQr;
      case 'phrase':
        return l10n.memberHowPhrase;
      default:
        final inviterId = live.invitedBy;
        if (inviterId != null) {
          final inviter = activeMembers
              .where((x) => x.id == inviterId)
              .firstOrNull;
          if (inviter != null) {
            final name =
                inviter.firstName ?? Names.firstName(inviter.fullName ?? '');
            return l10n.memberHowInvited(name);
          }
        }
        return l10n.memberHowQr;
    }
  }

  Future<void> _confirmStepDown(
    BuildContext context,
    WidgetRef ref,
    String meId,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showNestSheet<bool>(
      context,
      (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NestSheetHeader(
            title: l10n.memberStepDown,
            lead: l10n.memberStepDownLead,
          ),
          NestSheetActions(
            children: [
              NestButton(
                label: l10n.memberCancel,
                kind: NestButtonKind.ghost,
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              NestButton(
                label: l10n.memberStepDownConfirm,
                kind: NestButtonKind.danger,
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final res = await ref
        .read(membershipServiceProvider)
        .setRole(meId, 'member');
    if (sheetContext.mounted) {
      Navigator.of(sheetContext).pop();
    }
    if (res.applied) {
      ref.read(snackbarProvider).show(l10n.memberNowMemberSelf);
    } else {
      ref.read(snackbarProvider).show(reasonText(l10n, res.reasonKey));
    }
  }

  Future<void> _changeRole(
    WidgetRef ref,
    AppLocalizations l10n,
    String memberId,
    String firstName,
    String role,
  ) async {
    final res = await ref
        .read(membershipServiceProvider)
        .setRole(memberId, role);
    if (sheetContext.mounted) {
      Navigator.of(sheetContext).pop();
    }
    if (res.applied) {
      final msg = role == 'admin'
          ? l10n.memberNowAdmin(firstName)
          : l10n.memberNowMember(firstName);
      ref.read(snackbarProvider).show(msg, undo: res.change?.undo);
    } else {
      ref.read(snackbarProvider).show(reasonText(l10n, res.reasonKey));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final live = members.where((x) => x.id == member.id).firstOrNull ?? member;
    final meId = ref.watch(myMemberIdProvider);
    final isMe = live.id == meId;
    final isAdmin = ref.watch(isAdminProvider);
    final homeId =
        ref.watch(currentHomeIdProvider).value ??
        ref.watch(prefsProvider).currentHomeId ??
        '';
    final devFp =
        ref
            .watch(_memberKeyProvider((homeId: homeId, memberId: live.id)))
            .value ??
        '';
    final fp = devFp.isNotEmpty
        ? devFp
        : (isMe ? (ref.watch(myFingerprintProvider).value ?? '') : '');

    final fullName = live.fullName ?? '';
    final firstName = live.firstName ?? Names.firstName(fullName);
    final roleText = live.role == 'admin' ? l10n.roleAdmin : l10n.roleMember;
    final color = NestPalette.fromHex(
      (live.color != null && live.color!.isNotEmpty) ? live.color! : '#23503A',
    );
    final monthStr = DateFormat(
      'MMM yyyy',
      'en',
    ).format(DateTime.fromMillisecondsSinceEpoch(live.joinedAt ?? 0));
    final howStr = _howJoined(l10n, live, members);
    final hasOtherAdmin = members.any(
      (x) => x.id != meId && x.role == 'admin' && x.status == 'active',
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Avatar(name: fullName, color: color, size: AvatarSize.s72),
        ),
        const SizedBox(height: 12),
        Text(
          fullName,
          textAlign: TextAlign.center,
          style: NestText.title22.copyWith(color: c.ink),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.profileRoleHome(roleText, live.deviceModel ?? ''),
          textAlign: TextAlign.center,
          style: NestText.meta13.copyWith(color: c.ink3),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.memberJoined(monthStr, howStr),
          textAlign: TextAlign.center,
          style: NestText.body15.copyWith(color: c.ink2),
        ),
        if (fp.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            l10n.memberDeviceKey(fp),
            textAlign: TextAlign.center,
            style: NestText.meta13.copyWith(
              fontFamily: 'monospace',
              color: c.ink3,
            ),
          ),
        ],
        const SizedBox(height: 20),
        if (isMe) ...[
          NestButton(
            label: l10n.memberEditProfile,
            kind: NestButtonKind.ghost,
            size: NestButtonSize.block,
            onPressed: () {
              Navigator.of(sheetContext).pop();
              context.push(Routes.profile);
            },
          ),
          if (live.role == 'admin') ...[
            const SizedBox(height: 10),
            if (hasOtherAdmin)
              NestButton(
                label: l10n.memberStepDown,
                kind: NestButtonKind.ghost,
                size: NestButtonSize.block,
                onPressed: () => _confirmStepDown(context, ref, meId),
              )
            else
              AlertLine(
                icon: Icons.info_outline_rounded,
                text: l10n.homeLastAdmin,
              ),
          ],
        ] else if (isAdmin) ...[
          if (live.role != 'admin')
            NestButton(
              label: l10n.memberMakeAdmin,
              kind: NestButtonKind.tonal,
              size: NestButtonSize.block,
              onPressed: () =>
                  _changeRole(ref, l10n, live.id, firstName, 'admin'),
            )
          else
            NestButton(
              label: l10n.memberRemoveAdmin,
              kind: NestButtonKind.ghost,
              size: NestButtonSize.block,
              onPressed: () =>
                  _changeRole(ref, l10n, live.id, firstName, 'member'),
            ),
          const SizedBox(height: 10),
          NestButton(
            label: l10n.memberRemove,
            kind: NestButtonKind.dangerGhost,
            size: NestButtonSize.block,
            onPressed: () => showRemoveMemberSheet(
              sheetContext,
              ref,
              live,
              onRemoved: () {
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
            ),
          ),
        ] else
          AlertLine(
            icon: Icons.lock_outline_rounded,
            text: l10n.homeOnlyAdminsRoles,
          ),
      ],
    );
  }
}
