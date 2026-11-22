import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/ui/coming_soon.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          controller: ref.watch(tabScrollControllersProvider)[NestTab.today.index],
          children: [
            NestTopBar.tab(
              eyebrow: l10n.appName,
              title: l10n.tabToday,
              onTitleLongPress: kDebugMode ? () => context.push(Routes.debug) : null,
            ),
            const ComingSoon(phase: 'P03'),
          ],
        ),
      ),
    );
  }
}
