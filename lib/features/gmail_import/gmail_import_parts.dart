import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/gmail/gmail_import_config.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/gmail_import/gmail_import_controller.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/today/sections/sync_tag.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Displays Gmail OAuth connection status, scan window chips, and scan triggers.
class GmailStatusCard extends ConsumerWidget {
  const GmailStatusCard({
    super.key,
    required this.config,
    required this.uiState,
    required this.onConnect,
    required this.onCancelConnect,
    required this.onScanNow,
    required this.onDisconnect,
    required this.onScanDaysChanged,
    required this.onPasteInvoice,
  });

  final GmailImportConfig config;
  final GmailImportUiState uiState;
  final VoidCallback onConnect;
  final VoidCallback onCancelConnect;
  final VoidCallback onScanNow;
  final VoidCallback onDisconnect;
  final ValueChanged<int> onScanDaysChanged;
  final VoidCallback onPasteInvoice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    ref.watch(minuteTickProvider);
    final nowMs = ref.read(clockProvider).nowMs;

    final errorCode = uiState.errorCode ?? config.lastError;
    final hasError = errorCode != null && errorCode.isNotEmpty;

    final String subtitle;
    final Color iconBg;
    final Color iconFg;
    if (!config.hasOAuth) {
      subtitle = l10n.gmailImportStatusNeedsOAuth;
      iconBg = c.accentSoft;
      iconFg = c.accentInk;
    } else if (!config.isConnected) {
      subtitle = l10n.gmailImportStatusReadyToConnect;
      iconBg = c.accentSoft;
      iconFg = c.accentInk;
    } else {
      final email = config.connectedEmail;
      subtitle = (email != null && email.isNotEmpty)
          ? l10n.gmailImportStatusConnected(email)
          : l10n.gmailImportStatusConnectedFallback;
      iconBg = hasError ? c.dangerSoft : c.primarySoft;
      iconFg = hasError ? c.danger : c.primary;
    }

    final scanInfo = (config.lastScanAtMs == null || config.lastScanAtMs == 0)
        ? l10n.gmailImportNeverScanned
        : l10n.gmailImportLastScan(agoText(l10n, nowMs, config.lastScanAtMs!));

    return NestCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.mail_outline_rounded, color: iconFg),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.gmailImportStatusTitle,
                        style: NestText.itemTitle16.copyWith(color: c.ink),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: NestText.body15.copyWith(color: c.ink2),
                      ),
                      if (config.isConnected) ...[
                        const SizedBox(height: 2),
                        Text(
                          scanInfo,
                          style: NestText.meta13.copyWith(color: c.ink3),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (hasError) ...[
              const SizedBox(height: 12),
              AlertLine(
                icon: Icons.error_outline,
                text: gmailImportErrorText(l10n, errorCode),
                danger: true,
              ),
            ],
            const SizedBox(height: 14),
            Text(
              l10n.gmailImportWindowLabel,
              style: NestText.meta13.copyWith(color: c.ink3),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final days in const [7, 30, 90])
                  NestChip(
                    label: l10n.gmailImportWindowDays(days),
                    selected: config.scanDays == days,
                    onTap: () => onScanDaysChanged(days),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (config.hasOAuth && !config.isConnected) ...[
                  if (uiState.connecting)
                    NestButton(
                      label: l10n.gmailImportCancelAuthBtn,
                      kind: NestButtonKind.dangerGhost,
                      onPressed: onCancelConnect,
                    )
                  else
                    NestButton(
                      label: l10n.gmailImportConnectBtn,
                      icon: Icons.login_rounded,
                      onPressed: onConnect,
                    ),
                ],
                if (config.isConnected) ...[
                  NestButton(
                    label: uiState.scanning
                        ? l10n.gmailImportScanningBtn
                        : l10n.gmailImportScanNowBtn,
                    icon: Icons.refresh_rounded,
                    onPressed: uiState.scanning ? null : onScanNow,
                  ),
                  NestButton(
                    label: l10n.gmailImportDisconnectBtn,
                    kind: NestButtonKind.ghost,
                    onPressed: uiState.scanning ? null : onDisconnect,
                  ),
                ],
                NestButton(
                  label: l10n.gmailImportPasteInvoiceBtn,
                  kind: NestButtonKind.tonal,
                  icon: Icons.receipt_long_outlined,
                  onPressed: onPasteInvoice,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact draft order card displayed on both [GmailImportScreen] and [MoneyScreen].
class GmailDraftCard extends ConsumerWidget {
  const GmailDraftCard({
    super.key,
    required this.draft,
    required this.onReview,
    required this.onAccountIt,
    required this.onDiscard,
    this.accounting = false,
  });

  final DraftExpenseOrder draft;
  final VoidCallback onReview;
  final VoidCallback onAccountIt;
  final VoidCallback onDiscard;
  final bool accounting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final today = ref.watch(todayDateProvider);

    return NestCard(
      onTap: accounting ? null : onReview,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        draft.channel.displayName,
                        style: NestText.itemTitle16.copyWith(color: c.ink),
                      ),
                      NestTag(
                        label: l10n.gmailImportDraftBadge,
                        kind: NestTagKind.accent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  Money.formatPaise(draft.effectiveTotalPaise),
                  style: NestText.itemTitle16.copyWith(color: c.ink),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${Formatters.dayLabel(draft.date, today, l10n)} · '
              '${l10n.gmailImportDraftItemsCount(draft.items.length)} · '
              '${draft.itemsSummaryLine()}',
              style: NestText.meta13.copyWith(color: c.ink3),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                NestButton(
                  label: l10n.gmailImportAccountItBtn,
                  size: NestButtonSize.sm,
                  onPressed: accounting ? null : onAccountIt,
                ),
                NestButton(
                  label: l10n.gmailImportEditDraftBtn,
                  kind: NestButtonKind.tonal,
                  size: NestButtonSize.sm,
                  onPressed: accounting ? null : onReview,
                ),
                NestButton(
                  label: l10n.gmailImportDiscardBtn,
                  kind: NestButtonKind.ghost,
                  size: NestButtonSize.sm,
                  onPressed: accounting ? null : onDiscard,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Four-step guide explaining Google Cloud Desktop App OAuth creation.
class GmailSetupGuideCard extends StatelessWidget {
  const GmailSetupGuideCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final steps = [
      l10n.gmailImportGuideStep1,
      l10n.gmailImportGuideStep2,
      l10n.gmailImportGuideStep3,
      l10n.gmailImportGuideStep4,
    ];

    return NestCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.gmailImportGuideTitle,
              style: NestText.itemTitle16.copyWith(color: c.ink),
            ),
            const SizedBox(height: 10),
            for (final step in steps) ...[
              Text(step, style: NestText.body15.copyWith(color: c.ink2)),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }
}
