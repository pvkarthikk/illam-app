import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/remote_sync_config_parser.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/remote/remote_sync_config.dart';
import 'package:nm_flat/core/sync/remote/remote_sync_engine.dart';
import 'package:nm_flat/features/remote_sync/remote_sync_controller.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/today/sections/sync_tag.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class RemoteSyncStatusCard extends ConsumerWidget {
  const RemoteSyncStatusCard({
    super.key,
    required this.config,
    required this.state,
    required this.onSyncNow,
    required this.onShare,
  });

  final RemoteSyncConfig config;
  final RemoteSyncState state;
  final VoidCallback onSyncNow;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    ref.watch(minuteTickProvider);
    final nowMs = ref.read(clockProvider).nowMs;

    final errorCode = state.lastError ?? config.lastError;
    final lastAt = state.lastSyncAt ?? config.lastSyncAt;
    final hasError = errorCode != null && errorCode.isNotEmpty;

    final String title;
    final String subtitle;
    final Color iconBg;
    final Color iconFg;
    if (!config.isConfigured) {
      title = l10n.remoteSyncStatusTitle;
      subtitle = l10n.remoteSyncStatusNeedsSetup;
      iconBg = c.accentSoft;
      iconFg = c.accentInk;
    } else if (hasError) {
      title = l10n.remoteSyncStatusError(config.projectId);
      subtitle = remoteSyncErrorText(l10n, errorCode);
      iconBg = c.dangerSoft;
      iconFg = c.danger;
    } else {
      title = l10n.remoteSyncStatusConnected(config.projectId);
      subtitle = (lastAt == null || lastAt == 0)
          ? l10n.remoteSyncStatusNever
          : l10n.remoteSyncStatusLastSynced(agoText(l10n, nowMs, lastAt));
      iconBg = c.primarySoft;
      iconFg = c.primary;
    }

    return NestCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.cloud_sync_outlined, color: iconFg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: NestText.itemTitle16.copyWith(color: c.ink)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: NestText.meta13.copyWith(
                        color: hasError ? c.danger : c.ink3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (config.isConfigured) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                NestButton(
                  label: state.syncing
                      ? l10n.remoteSyncSyncing
                      : l10n.remoteSyncSyncNow,
                  icon: Icons.sync_rounded,
                  kind: NestButtonKind.tonal,
                  size: NestButtonSize.sm,
                  onPressed: state.syncing ? null : onSyncNow,
                ),
                NestButton(
                  label: l10n.remoteSyncShareFamily,
                  icon: Icons.qr_code_2_rounded,
                  kind: NestButtonKind.ghost,
                  size: NestButtonSize.sm,
                  onPressed: onShare,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class RemoteSyncGuideCard extends StatefulWidget {
  const RemoteSyncGuideCard({super.key, required this.onCopiedRules});

  final VoidCallback onCopiedRules;

  @override
  State<RemoteSyncGuideCard> createState() => _RemoteSyncGuideCardState();
}

class _RemoteSyncGuideCardState extends State<RemoteSyncGuideCard> {
  bool _showRules = false;

  Future<void> _copyRules() async {
    await Clipboard.setData(const ClipboardData(text: kRemoteSyncFirestoreRules));
    if (mounted) widget.onCopiedRules();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final steps = [
      l10n.remoteSyncGuideStep1,
      l10n.remoteSyncGuideStep2,
      l10n.remoteSyncGuideStep3,
      l10n.remoteSyncGuideStep4,
    ];

    return NestCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.remoteSyncGuideTitle,
            style: NestText.itemTitle16.copyWith(color: c.ink),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Text(steps[i], style: NestText.body15.copyWith(color: c.ink2)),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              NestButton(
                label: l10n.remoteSyncCopyRules,
                icon: Icons.copy_rounded,
                kind: NestButtonKind.tonal,
                size: NestButtonSize.sm,
                onPressed: _copyRules,
              ),
              NestButton(
                label: _showRules
                    ? l10n.remoteSyncHideRules
                    : l10n.remoteSyncShowRules,
                icon: _showRules
                    ? Icons.expand_less_rounded
                    : Icons.code_rounded,
                kind: NestButtonKind.ghost,
                size: NestButtonSize.sm,
                onPressed: () => setState(() => _showRules = !_showRules),
              ),
            ],
          ),
          if (_showRules) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.paper2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.line),
              ),
              child: SelectableText(
                kRemoteSyncFirestoreRules,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: c.ink,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shows a manual paste sheet returning a parsed [ParsedFirebaseConfig], or `null`.
Future<ParsedFirebaseConfig?> showPasteFirebaseConfigSheet(
  BuildContext context,
) async {
  final ctrl = TextEditingController();
  String? errorText;
  try {
    return await showNestSheet<ParsedFirebaseConfig>(
      context,
      (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final l10n = AppLocalizations.of(ctx);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NestSheetHeader(
                title: l10n.remoteSyncPasteSheetTitle,
                lead: l10n.remoteSyncPasteSheetLead,
              ),
              TextField(
                controller: ctrl,
                maxLines: 6,
                minLines: 4,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.remoteSyncPasteFieldLabel,
                  errorText: errorText,
                ),
                onChanged: (_) {
                  if (errorText != null) setState(() => errorText = null);
                },
              ),
              NestSheetActions(
                children: [
                  NestButton(
                    label: l10n.commonCancel,
                    kind: NestButtonKind.ghost,
                    size: NestButtonSize.block,
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                  NestButton(
                    label: l10n.remoteSyncApplyConfig,
                    kind: NestButtonKind.primary,
                    size: NestButtonSize.block,
                    onPressed: () {
                      final parsed = parseFirebaseConfigSnippet(ctrl.text);
                      if (parsed == null) {
                        setState(() => errorText = l10n.remoteSyncConfigNotFound);
                        return;
                      }
                      Navigator.of(ctx).pop(parsed);
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  } finally {
    ctrl.dispose();
  }
}
