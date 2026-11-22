import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/features/backup/backup_setup_parts.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class RestoreScreen extends ConsumerWidget {
  const RestoreScreen({super.key});

  void _back(BuildContext context) =>
      context.go(Routes.onboardingStep('welcome'));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nest;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back(context);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: l.commonBack,
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => _back(context),
          ),
          title: Text(
            l.restoreTitle,
            style: NestText.title22.copyWith(color: c.ink),
          ),
          backgroundColor: c.paper.withValues(alpha: 0.92),
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          foregroundColor: c.ink,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Text(
              l.restoreSub,
              style: NestText.body15.copyWith(color: c.ink2),
            ),
            const ProviderList(mode: ConnectMode.restore),
            const SizedBox(height: 20),
            Text(
              l.restoreNote,
              textAlign: TextAlign.center,
              style: NestText.small12.copyWith(color: c.ink3),
            ),
          ],
        ),
      ),
    );
  }
}
