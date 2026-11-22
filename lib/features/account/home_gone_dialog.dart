import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/control_store.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Non-dismissible alert shown when this phone was removed from a home or the home was deleted.
Future<void> showHomeGoneDialog(BuildContext context, Tombstone t) async {
  final l10n = AppLocalizations.of(context);
  final store = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(controlStoreProvider);
  final title = t.reason == 'deleted'
      ? l10n.homeGoneDeleted(t.homeName, t.byName ?? '')
      : l10n.homeGoneRemoved(t.homeName);

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(title),
        actions: [
          NestButton(
            label: l10n.homeGoneOk,
            kind: NestButtonKind.primary,
            onPressed: () async {
              final router = GoRouter.of(ctx);
              await store.markShown(t.homeId);
              if (!ctx.mounted) return;
              Navigator.of(ctx).pop();
              router.go(Routes.onboardingStep('welcome'));
            },
          ),
        ],
      ),
    ),
  );
}
