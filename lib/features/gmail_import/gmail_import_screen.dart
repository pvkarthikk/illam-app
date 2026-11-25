import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/gmail/gmail_import_config.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/gmail_import/draft_review_sheet.dart';
import 'package:nm_flat/features/gmail_import/gmail_import_controller.dart';
import 'package:nm_flat/features/gmail_import/gmail_import_parts.dart';
import 'package:nm_flat/features/gmail_import/gmail_oauth_form.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Experimental settings & review screen for Gmail Invoice Import (BYO OAuth).
class GmailImportScreen extends ConsumerWidget {
  const GmailImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cfgAsync = ref.watch(gmailImportConfigProvider);
    final uiState = ref.watch(gmailImportControllerProvider);
    final ctrl = ref.read(gmailImportControllerProvider.notifier);

    return Scaffold(
      appBar: NestTopBar.sub(
        title: l10n.gmailImportTitle,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: NestTag(
              label: l10n.gmailImportExperimental,
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
            child: Text(l10n.gmailImportErrAuthOther),
          ),
        ),
        data: (config) => _GmailImportBody(
          config: config,
          uiState: uiState,
          controller: ctrl,
        ),
      ),
    );
  }
}

class _GmailImportBody extends ConsumerWidget {
  const _GmailImportBody({
    required this.config,
    required this.uiState,
    required this.controller,
  });

  final GmailImportConfig config;
  final GmailImportUiState uiState;
  final GmailImportController controller;

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
            title: l10n.gmailImportToggleTitle,
            subtitle: l10n.gmailImportToggleSubtitle,
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
                        Icon(Icons.mail_lock_outlined, color: c.ink2),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.gmailImportTitle,
                            style: NestText.itemTitle16.copyWith(color: c.ink),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.gmailImportOffHint,
                      style: NestText.body15.copyWith(color: c.ink2),
                    ),
                  ],
                ),
              ),
            ),
          )
        else ...[
          GmailStatusCard(
            config: config,
            uiState: uiState,
            onConnect: () async {
              final email = await controller.connectGmail();
              if (!context.mounted || email == null) return;
              snack.show(l10n.gmailImportConnectedSnack(email));
            },
            onCancelConnect: controller.cancelConnect,
            onScanNow: () async {
              final added = await controller.scanNow();
              if (!context.mounted || added == null) return;
              snack.show(l10n.gmailImportScanSummary(added));
            },
            onDisconnect: () async {
              await controller.disconnectGmail();
              if (!context.mounted) return;
              snack.show(l10n.gmailImportDisconnectedSnack);
            },
            onScanDaysChanged: controller.setScanDays,
            onPasteInvoice: () => showPasteInvoiceSheet(context, ref),
          ),
          const SizedBox(height: 20),
          SectionHeader(
            title: l10n.gmailImportDraftsSectionTitle(config.drafts.length),
          ),
          const SizedBox(height: 8),
          if (config.drafts.isEmpty)
            NestCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.gmailImportDraftsEmpty,
                  style: NestText.body15.copyWith(color: c.ink2),
                ),
              ),
            )
          else ...[
            Text(
              l10n.gmailImportDraftsMoneyNote,
              style: NestText.meta13.copyWith(color: c.ink3),
            ),
            const SizedBox(height: 8),
            for (final draft in config.drafts) ...[
              GmailDraftCard(
                draft: draft,
                accounting: uiState.accountingDraftId == draft.id,
                onReview: () => showDraftReviewSheet(context, ref, draft),
                onAccountIt: () async {
                  final res = await controller.accountDraft(draft);
                  if (!context.mounted || res == null) return;
                  snack.show(
                    l10n.gmailImportAccountedSnack(
                      res.count,
                      Money.formatPaise(res.totalPaise),
                    ),
                  );
                },
                onDiscard: () => controller.discardDraft(draft.id),
              ),
              const SizedBox(height: 10),
            ],
          ],
          const SizedBox(height: 12),
          const GmailSetupGuideCard(),
          const SizedBox(height: 16),
          GmailOAuthFormCard(config: config),
        ],
      ],
    );
  }
}
