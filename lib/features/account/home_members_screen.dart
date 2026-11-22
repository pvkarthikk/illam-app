import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/home_ids.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/account/home_members_parts.dart';
import 'package:nm_flat/features/account/home_sheets.dart';
import 'package:nm_flat/features/account/home_sync_card.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class HomeMembersScreen extends ConsumerWidget {
  const HomeMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final home = ref.watch(currentHomeProvider).value;
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final myMemberId = ref.watch(myMemberIdProvider);
    final isAdmin = ref.watch(isAdminProvider);

    final homeName = home?.name ?? '';
    final subtitle = home == null
        ? null
        : l10n.homeSubtitle(members.length, HomeIds.display(home.id));
    final adminFirstNames = [
      for (final m in members)
        if (m.role == 'admin') m.firstName ?? Names.firstName(m.fullName ?? ''),
    ].where((s) => s.isNotEmpty).toList();

    return Scaffold(
      appBar: NestTopBar.sub(
        title: homeName,
        subtitle: subtitle,
        actions: [
          if (isAdmin && home != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.homeRename,
              onPressed: () => showRenameHomeSheet(context, ref, homeName),
            ),
        ],
      ),
      body: home == null
          ? ListView()
          : ListView(
              children: [
                const SizedBox(height: 16),
                const HomeSyncCard(),
                const SizedBox(height: 12),
                const HomeBackupCard(),
                const SizedBox(height: 16),
                HomeInviteSection(
                  isAdmin: isAdmin,
                  adminFirstNames: adminFirstNames,
                ),
                const SizedBox(height: 24),
                HomeFamilySection(members: members, myMemberId: myMemberId),
                const SizedBox(height: 24),
                HomeHouseHelpSection(isAdmin: isAdmin),
                const SizedBox(height: 20),
                const HomeRolesSection(),
                const SizedBox(height: 24),
                HomeLeaveDeleteSection(homeName: homeName, isAdmin: isAdmin),
              ],
            ),
    );
  }
}
