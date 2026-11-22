import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/notify/notifications.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<bool> ensureNotificationPermission(
  BuildContext context,
  WidgetRef ref,
) async {
  final android = androidNotificationsPlugin();
  if (android == null) return true;

  try {
    if ((await android.areNotificationsEnabled()) == true) {
      return true;
    }
  } on MissingPluginException {
    return true;
  }

  if (!context.mounted) return false;
  final l10n = AppLocalizations.of(context);
  final firstStaff =
      (ref.read(activeStaffProvider).value ?? const <StaffData>[]).firstOrNull;
  final name = (firstStaff?.name != null && firstStaff!.name!.isNotEmpty)
      ? firstStaff.name!
      : l10n.notifYourHelp;

  final accepted = await showNestSheet<bool>(
    context,
    (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NestSheetHeader(
          title: l10n.notifExplainerTitle,
          lead: l10n.notifExplainerBody(name),
        ),
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.notifNotNow,
              kind: NestButtonKind.ghost,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            NestButton(
              label: l10n.notifContinue,
              kind: NestButtonKind.primary,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
      ],
    ),
  );

  bool? granted;
  if (accepted == true) {
    try {
      granted = await android.requestNotificationsPermission();
    } on MissingPluginException {
      granted = false;
    }
  }

  await ref.read(prefsProvider).setNotifAsked(true);
  if (!context.mounted) return false;
  return accepted == true && (granted ?? false);
}
