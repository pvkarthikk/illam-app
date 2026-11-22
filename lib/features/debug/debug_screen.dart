import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: NestTopBar.sub(title: l10n.debugTitle),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NestCard(
            child: Column(
              children: [
                SettingsRow(
                  label: l10n.debugGallery,
                  value: l10n.debugGallerySub,
                  onTap: () => context.push(Routes.debugGallery),
                ),
                // later phases add rows here (Data lab, Load demo home, Viewing as…, Wipe this phone…)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
