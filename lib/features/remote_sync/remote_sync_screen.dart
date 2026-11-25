import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/remote/remote_sync_config.dart';
import 'package:nm_flat/core/sync/remote/remote_sync_engine.dart';
import 'package:nm_flat/features/remote_sync/remote_sync_config_form.dart';
import 'package:nm_flat/features/remote_sync/remote_sync_controller.dart';
import 'package:nm_flat/features/remote_sync/remote_sync_parts.dart';
import 'package:nm_flat/features/remote_sync/remote_sync_qr_sheet.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class RemoteSyncScreen extends ConsumerWidget {
  const RemoteSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cfgAsync = ref.watch(remoteSyncConfigProvider);
    final syncState =
        ref.watch(remoteSyncStateProvider).value ?? const RemoteSyncState();
    final uiState = ref.watch(remoteSyncControllerProvider);
    final ctrl = ref.read(remoteSyncControllerProvider.notifier);

    return Scaffold(
      appBar: NestTopBar.sub(
        title: l10n.remoteSyncTitle,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: NestTag(
              label: l10n.remoteSyncExperimental,
              kind: NestTagKind.accent,
            ),
          ),
        ],
      ),
      body: cfgAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(l10n.remoteSyncErrOther),
          ),
        ),
        data: (config) => _RemoteSyncBody(
          config: config,
          syncState: syncState,
          uiState: uiState,
          controller: ctrl,
        ),
      ),
    );
  }
}

class _RemoteSyncBody extends ConsumerWidget {
  const _RemoteSyncBody({
    required this.config,
    required this.syncState,
    required this.uiState,
    required this.controller,
  });

  final RemoteSyncConfig config;
  final RemoteSyncState syncState;
  final RemoteSyncUiState uiState;
  final RemoteSyncController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final snack = ref.read(snackbarProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        NestCard(
          child: SwitchRow(
            title: l10n.remoteSyncToggleTitle,
            subtitle: l10n.remoteSyncToggleSub,
            value: config.enabled,
            onChanged: controller.setEnabled,
          ),
        ),
        const SizedBox(height: 16),
        if (!config.enabled)
          NestCard(
            child: KolamBackground(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud_off_outlined, color: c.ink2),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.remoteSyncOffTitle,
                            style: NestText.itemTitle16.copyWith(color: c.ink),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.remoteSyncOffBody,
                      style: NestText.body15.copyWith(color: c.ink2),
                    ),
                  ],
                ),
              ),
            ),
          )
        else ...[
          RemoteSyncStatusCard(
            config: config,
            state: syncState,
            onSyncNow: () async {
              final res = await controller.syncNow();
              if (!context.mounted || !res.ran) return;
              if (res.error != null) {
                snack.show(remoteSyncErrorText(l10n, res.error!.name));
                return;
              }
              final total = res.pushed + res.pulled;
              snack.show(
                total > 0
                    ? l10n.remoteSyncSyncedCount(total)
                    : l10n.remoteSyncSyncedNone,
              );
            },
            onShare: () {
              final creds = config.parsedCredentials;
              if (creds == null) return;
              showRemoteSyncShareSheet(
                context,
                creds,
                onCopiedLink: () => snack.show(l10n.remoteSyncShareLinkCopied),
              );
            },
          ),
          const SizedBox(height: 16),
          RemoteSyncGuideCard(
            onCopiedRules: () => snack.show(l10n.remoteSyncRulesCopied),
          ),
          const SizedBox(height: 16),
          RemoteSyncConfigForm(
            config: config,
            uiState: uiState,
            controller: controller,
          ),
        ],
      ],
    );
  }
}
