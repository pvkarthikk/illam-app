import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/account/leaving_sheet.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

enum _RemoveChoice { cancel, remove, goMembers }

Future<void> showRemoveHomeSheet(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final home = ref.read(currentHomeProvider).value;
  final homeName = home?.name ?? '';
  final meId = ref.read(myMemberIdProvider);
  final active = ref.read(membersProvider).value ?? const <Member>[];
  final myRow = active.where((m) => m.id == meId).firstOrNull;
  final iAmAdmin = myRow?.role == 'admin';
  final hasOtherAdmin = active.any((m) => m.id != meId && m.role == 'admin');
  final hasOthers = active.any((m) => m.id != meId);
  final blockedSoleAdmin = iAmAdmin && !hasOtherAdmin && hasOthers;

  final choice = await showNestSheet<_RemoveChoice>(
    context,
    (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (blockedSoleAdmin) ...[
          NestSheetHeader(
            title: l10n.profileRemoveTitle(homeName),
            lead: l10n.profileOnlyAdminLead,
          ),
          NestButton(
            label: l10n.profileGoToMembers,
            kind: NestButtonKind.primary,
            size: NestButtonSize.block,
            onPressed: () => Navigator.of(ctx).pop(_RemoveChoice.goMembers),
          ),
        ] else ...[
          NestSheetHeader(
            title: l10n.profileRemoveTitle(homeName),
            lead: l10n.profileRemoveLead,
          ),
          NestSheetActions(
            children: [
              NestButton(
                label: l10n.profileKeep,
                kind: NestButtonKind.ghost,
                onPressed: () => Navigator.of(ctx).pop(_RemoveChoice.cancel),
              ),
              NestButton(
                label: l10n.profileRemove,
                kind: NestButtonKind.danger,
                onPressed: () => Navigator.of(ctx).pop(_RemoveChoice.remove),
              ),
            ],
          ),
        ],
      ],
    ),
  );

  if (!context.mounted) return;
  if (choice == _RemoveChoice.goMembers) {
    context.push(Routes.home);
    return;
  }
  if (choice != _RemoveChoice.remove) return;

  if (ref.read(membersProvider).hasValue && !hasOthers) {
    final snackbar = ref.read(snackbarProvider);
    final res = await ref
        .read(membershipServiceProvider)
        .removeFromThisPhoneNow();
    snackbar.show(
      res.applied ? l10n.homeLeft(homeName) : l10n.profileOnlyAdminLead,
    );
    return;
  }

  final homeId = home?.id ?? ref.read(prefsProvider).currentHomeId ?? '';
  final res = await ref.read(membershipServiceProvider).leaveHome();
  if (!context.mounted) return;
  if (!res.applied) {
    ref.read(snackbarProvider).show(l10n.profileOnlyAdminLead);
  } else {
    await showLeavingSheet(context, homeId: homeId, homeName: homeName);
  }
}
