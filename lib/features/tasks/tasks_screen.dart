import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/ui/coming_soon.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          controller: ref.watch(tabScrollControllersProvider)[NestTab.tasks.index],
          children: [
            NestTopBar.tab(title: l10n.tabTasks),
            const ComingSoon(phase: 'P08'),
          ],
        ),
      ),
    );
  }
}
