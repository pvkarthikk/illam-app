import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/sync_status.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/account/appearance_controller.dart';
import 'package:nm_flat/features/account/profile_controller.dart';
import 'package:nm_flat/features/account/profile_parts.dart';
import 'package:nm_flat/features/account/remove_home_sheet.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _showRenameSheet(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: currentName);
    String? err;
    try {
      await showNestSheet<void>(
        context,
        (ctx) => StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NestSheetHeader(
                title: l10n.profileNameSheetTitle,
                lead: l10n.profileNameSheetLead,
              ),
              TextField(
                controller: ctrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                decoration: InputDecoration(
                  labelText: l10n.profileName,
                  errorText: err,
                ),
                onChanged: (_) {
                  if (err != null) setState(() => err = null);
                },
              ),
              const SizedBox(height: 16),
              NestButton(
                label: l10n.profileSave,
                kind: NestButtonKind.primary,
                size: NestButtonSize.block,
                onPressed: () async {
                  final res = await ref
                      .read(profileControllerProvider.notifier)
                      .rename(ctrl.text);
                  if (res == null) {
                    setState(() => err = l10n.profileNameError);
                    return;
                  }
                  if (!ctx.mounted) return;
                  Navigator.of(ctx).pop();
                  ref
                      .read(snackbarProvider)
                      .show(l10n.profileNameUpdated, undo: res.undo);
                },
              ),
            ],
          ),
        ),
      );
    } finally {
      ctrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final member = ref.watch(myMemberProvider).value;
    final home = ref.watch(currentHomeProvider).value;

    if (member == null || home == null) {
      return Scaffold(
        appBar: NestTopBar.sub(title: l10n.profileTitle),
        body: ListView(),
      );
    }

    final fullName = member.fullName ?? '';
    final colorHex = (member.color != null && member.color!.isNotEmpty)
        ? member.color!
        : '#23503A';
    final avatarColor = NestPalette.fromHex(colorHex);
    final homeName = home.name ?? '';
    final roleText = member.role == 'admin' ? l10n.roleAdmin : l10n.roleMember;
    final fingerprint = ref.watch(myFingerprintProvider).value ?? '';
    final familyCount =
        (ref.watch(membersProvider).value ?? const <Member>[]).length;
    final helpCount =
        (ref.watch(activeStaffProvider).value ?? const <StaffData>[]).length;
    final syncSummary = ref.watch(syncSummaryProvider).value;

    final Widget thisPhoneTag;
    if (syncSummary == null || syncSummary.onlyThisPhone) {
      thisPhoneTag = NestTag(label: l10n.profileOnlyThisPhone);
    } else if (syncSummary.allInSync) {
      thisPhoneTag = NestTag(label: l10n.profileInSync, kind: NestTagKind.ok);
    } else if (syncSummary.notUpToDate == 1) {
      final behindPeer = syncSummary.rows
          .where(
            (r) =>
                r.state != PeerState.thisPhone &&
                (r.behindBy > 0 || r.state == PeerState.never),
          )
          .firstOrNull;
      thisPhoneTag = NestTag(
        label: behindPeer != null
            ? l10n.profileOneBehind(behindPeer.device.name)
            : l10n.profileManyBehind(syncSummary.notUpToDate),
        kind: NestTagKind.accent,
      );
    } else {
      thisPhoneTag = NestTag(
        label: l10n.profileManyBehind(syncSummary.notUpToDate),
        kind: NestTagKind.accent,
      );
    }

    return Scaffold(
      appBar: NestTopBar.sub(title: l10n.profileTitle),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Avatar(
                  name: fullName,
                  color: avatarColor,
                  size: AvatarSize.s72,
                ),
                const SizedBox(height: 12),
                Text(
                  fullName,
                  textAlign: TextAlign.center,
                  style: NestText.title28.copyWith(color: c.ink),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.profileRoleHome(roleText, homeName),
                  textAlign: TextAlign.center,
                  style: NestText.meta13.copyWith(color: c.ink3),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: NestCard(
              child: Column(
                children: [
                  SettingsRow(
                    label: l10n.profileName,
                    value: fullName,
                    trailing: Icon(
                      Icons.edit_outlined,
                      color: c.ink3,
                      semanticLabel: l10n.profileEditName,
                    ),
                    onTap: () => _showRenameSheet(context, ref, fullName),
                  ),
                  Divider(height: 1, color: c.line),
                  SettingsRow(
                    label: l10n.profileThisPhone,
                    value: member.deviceModel ?? '',
                    trailing: thisPhoneTag,
                  ),
                  Divider(height: 1, color: c.line),
                  SettingsRow(
                    label: l10n.profileDeviceKey,
                    value: '',
                    sub: l10n.profileDeviceKeySub,
                    trailing: Text(
                      fingerprint,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: c.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: l10n.profileYourHomes),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: NestCard(
              onTap: () => context.push(Routes.home),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.home_outlined, color: c.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              homeName,
                              style: NestText.itemTitle16.copyWith(color: c.ink),
                            ),
                            NestTag(
                              label: l10n.profileCurrent,
                              kind: NestTagKind.ok,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.profileHomeSub(familyCount, helpCount, roleText),
                          style: NestText.meta13.copyWith(color: c.ink3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, color: c.ink3),
                ],
              ),
            ),
          ),
          const ProfileNotificationsSection(),
          const ProfileOnThisPhoneSection(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: TextButton.icon(
                  onPressed: () => showRemoveHomeSheet(context, ref),
                  icon: Icon(Icons.logout_rounded, color: c.danger, size: 18),
                  label: Text(
                    l10n.profileRemoveHome(homeName),
                    style: NestText.button15.copyWith(color: c.danger),
                  ),
                ),
              ),
            ),
          ),
          const ProfileFooter(),
        ],
      ),
    );
  }
}
