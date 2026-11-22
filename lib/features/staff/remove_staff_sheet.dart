import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showRemoveStaffSheet(
  BuildContext context,
  WidgetRef ref,
  StaffData staff,
) async {
  final l10n = AppLocalizations.of(context);
  final name = staff.name ?? '';
  final confirmed = await showNestSheet<bool>(
    context,
    (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(
          title: l10n.staffRemoveTitle(name),
          lead: l10n.staffRemoveLead,
        ),
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.commonCancel,
              kind: NestButtonKind.ghost,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            NestButton(
              label: l10n.commonRemove,
              kind: NestButtonKind.danger,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  final today = ref.read(todayDateProvider);
  final res = await ref.read(staffRepoProvider).removeStaff(staff.id, today);
  if (context.mounted) context.pop();
  ref.read(snackbarProvider).show(l10n.staffRemoved(name), undo: res.undo);
}
