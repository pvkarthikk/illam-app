import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

String reasonText(AppLocalizations l10n, String? key) => switch (key) {
  'homeLastAdmin' => l10n.homeLastAdmin,
  'homeChooseAdmin' => l10n.homeChooseAdmin,
  'homeNameLength' => l10n.homeNameLength,
  _ => l10n.homeOnlyAdminsRoles,
};

Future<String?> workText(
  WidgetRef ref,
  AppLocalizations l10n,
  String memberId,
) async {
  final w = await ref
      .read(tasksRepoProvider)
      .loadAssignedTo(memberId, assigneeType: 'member');
  final parts = <String>[
    if (w.routineCount > 0) l10n.workRoutines(w.routineCount),
    if (w.todoCount > 0) l10n.workTodos(w.todoCount),
  ];
  if (parts.isEmpty) return null;
  if (parts.length == 1) return parts.single;
  return l10n.workAnd(parts[0], parts[1]);
}

Future<void> showRemoveMemberSheet(
  BuildContext context,
  WidgetRef ref,
  Member m, {
  VoidCallback? onRemoved,
}) async {
  final l10n = AppLocalizations.of(context);
  final homeName = ref.read(currentHomeProvider).value?.name ?? '';
  final firstName = m.firstName ?? Names.firstName(m.fullName ?? '');
  final work = await workText(ref, l10n, m.id);
  if (!context.mounted) return;

  final confirmed = await showNestSheet<bool>(
    context,
    (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NestSheetHeader(
          title: l10n.memberRemoveTitle(firstName),
          lead: work != null
              ? l10n.memberRemoveLeadWork(homeName, work)
              : l10n.memberRemoveLead(homeName),
        ),
        AlertLine(
          icon: Icons.info_outline_rounded,
          text: l10n.memberRemoveInfo,
        ),
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.memberCancel,
              kind: NestButtonKind.ghost,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            NestButton(
              label: l10n.memberRemove,
              kind: NestButtonKind.danger,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
      ],
    ),
  );

  if (confirmed != true) return;
  final res = await ref.read(membershipServiceProvider).removeMember(m.id);
  if (res.applied) {
    onRemoved?.call();
    ref.read(snackbarProvider).show(l10n.memberRemoved(firstName));
  } else {
    ref.read(snackbarProvider).show(reasonText(l10n, res.reasonKey));
  }
}

Future<void> showRenameHomeSheet(
  BuildContext context,
  WidgetRef ref,
  String current,
) async {
  final l10n = AppLocalizations.of(context);
  final ctrl = TextEditingController(text: current);
  String? err;
  try {
    await showNestSheet<void>(
      context,
      (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NestSheetHeader(title: l10n.homeRename, lead: l10n.homeRenameLead),
            TextField(
              controller: ctrl,
              autofocus: true,
              maxLength: 40,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.createHomeName,
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
                final r = await ref
                    .read(membershipServiceProvider)
                    .renameHome(ctrl.text);
                if (!r.applied) {
                  if (ctx.mounted) {
                    setState(() => err = reasonText(l10n, r.reasonKey));
                  }
                  return;
                }
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                ref
                    .read(snackbarProvider)
                    .show(l10n.homeRenamed, undo: r.change?.undo);
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

Future<void> showLeaveSheet(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final homeName = ref.read(currentHomeProvider).value?.name ?? '';
  final meId = ref.read(myMemberIdProvider);
  final active = await ref.read(membershipServiceProvider).members().first;
  if (!context.mounted) return;

  final others = [
    for (final m in active)
      if (m.id != meId) m,
  ];
  final admins = [
    for (final m in active)
      if (m.role == 'admin') m,
  ];
  final iAmOnlyAdmin = admins.length == 1 && admins.single.id == meId;

  if (iAmOnlyAdmin && others.isNotEmpty) {
    final promoted = await showNestSheet<bool>(
      context,
      (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NestSheetHeader(title: l10n.homeChooseAdmin),
          for (var i = 0; i < others.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(
              children: [
                Avatar(
                  name: others[i].fullName ?? '',
                  color: NestPalette.fromHex(
                    (others[i].color != null && others[i].color!.isNotEmpty)
                        ? others[i].color!
                        : '#23503A',
                  ),
                  size: AvatarSize.s32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    others[i].fullName ?? '',
                    style: NestText.itemTitle16.copyWith(
                      color: context.nest.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 165),
                  child: NestButton(
                    label: l10n.memberMakeAdmin,
                    kind: NestButtonKind.tonal,
                    size: NestButtonSize.sm,
                    onPressed: () async {
                      final r = await ref
                          .read(membershipServiceProvider)
                          .setRole(others[i].id, 'admin');
                      if (!ctx.mounted) return;
                      if (!r.applied) {
                        Navigator.of(ctx).pop(false);
                        ref
                            .read(snackbarProvider)
                            .show(reasonText(l10n, r.reasonKey));
                        return;
                      }
                      Navigator.of(ctx).pop(true);
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
    if (promoted == true && context.mounted) {
      await showLeaveSheet(context, ref);
    }
    return;
  }

  if (others.isEmpty) {
    final deleteConfirmed = await showNestSheet<bool>(
      context,
      (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NestSheetHeader(
            title: l10n.homeOnlyOneTitle,
            lead: l10n.homeOnlyOneLead(homeName),
          ),
          NestSheetActions(
            children: [
              NestButton(
                label: l10n.homeStay,
                kind: NestButtonKind.ghost,
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              NestButton(
                label: l10n.homeDeleteHome,
                kind: NestButtonKind.danger,
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
        ],
      ),
    );
    if (deleteConfirmed == true) {
      final r = await ref.read(membershipServiceProvider).deleteHome();
      if (!r.applied) {
        ref.read(snackbarProvider).show(reasonText(l10n, r.reasonKey));
      }
    }
    return;
  }

  final work = await workText(ref, l10n, meId);
  if (!context.mounted) return;
  final otherAdmin = others.firstWhere(
    (m) => m.role == 'admin',
    orElse: () => others.first,
  );
  final adminName =
      otherAdmin.firstName ?? Names.firstName(otherAdmin.fullName ?? '');

  final leaveConfirmed = await showNestSheet<bool>(
    context,
    (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NestSheetHeader(
          title: l10n.homeLeaveTitle(homeName),
          lead: work != null
              ? l10n.homeLeaveLeadWork(work, adminName)
              : l10n.homeLeaveLead,
        ),
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.homeStay,
              kind: NestButtonKind.ghost,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            NestButton(
              label: l10n.homeLeaveConfirm,
              kind: NestButtonKind.danger,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
      ],
    ),
  );
  if (leaveConfirmed == true) {
    final r = await ref.read(membershipServiceProvider).leaveHome();
    if (!r.applied) {
      ref.read(snackbarProvider).show(reasonText(l10n, r.reasonKey));
    } else {
      ref.read(snackbarProvider).show(l10n.homeLeft(homeName));
    }
  }
}

Future<void> showDeleteHomeSheet(
  BuildContext context,
  WidgetRef ref,
  String homeName,
) async {
  final l10n = AppLocalizations.of(context);
  final ctrl = TextEditingController();
  bool? confirmed;
  try {
    confirmed = await showNestSheet<bool>(
      context,
      (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NestSheetHeader(
              title: l10n.homeDeleteTitle(homeName),
              lead: l10n.homeDeleteLead,
            ),
            AlertLine(
              icon: Icons.info_outline_rounded,
              text: l10n.homeDeleteInfo,
              danger: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.homeTypeToConfirm(homeName),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            NestButton(
              label: l10n.homeDeleteConfirm,
              kind: NestButtonKind.danger,
              size: NestButtonSize.block,
              onPressed: ctrl.text.trim() == homeName
                  ? () => Navigator.of(ctx).pop(true)
                  : null,
            ),
          ],
        ),
      ),
    );
  } finally {
    ctrl.dispose();
  }

  if (confirmed != true) return;
  final r = await ref.read(membershipServiceProvider).deleteHome();
  if (!r.applied) {
    ref.read(snackbarProvider).show(reasonText(l10n, r.reasonKey));
  }
}
