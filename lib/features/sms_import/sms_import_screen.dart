import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sms/sms_import_config.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/sms_import/sms_draft_review_sheet.dart';
import 'package:nm_flat/features/sms_import/sms_import_controller.dart';
import 'package:nm_flat/features/sms_import/sms_import_parts.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Experimental settings & one-by-one review screen for on-device SMS Spend Import.
class SmsImportScreen extends ConsumerStatefulWidget {
  const SmsImportScreen({super.key});

  @override
  ConsumerState<SmsImportScreen> createState() => _SmsImportScreenState();
}

class _SmsImportScreenState extends ConsumerState<SmsImportScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (!mounted) return;
        unawaited(
          ref.read(smsImportControllerProvider.notifier).refreshPermission(),
        );
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref.read(smsImportControllerProvider.notifier).refreshPermission(),
      );
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cfgAsync = ref.watch(smsImportConfigProvider);
    final uiState = ref.watch(smsImportControllerProvider);
    final ctrl = ref.read(smsImportControllerProvider.notifier);

    return Scaffold(
      appBar: NestTopBar.sub(
        title: l10n.smsImportTitle,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: NestTag(
              label: l10n.smsImportExperimental,
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
            child: Text(l10n.smsImportStatusNeeded),
          ),
        ),
        data: (config) => _SmsImportBody(
          config: config,
          uiState: uiState,
          controller: ctrl,
        ),
      ),
    );
  }
}

class _SmsImportBody extends ConsumerWidget {
  const _SmsImportBody({
    required this.config,
    required this.uiState,
    required this.controller,
  });

  final SmsImportConfig config;
  final SmsImportUiState uiState;
  final SmsImportController controller;

  Future<void> _confirmClear(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.smsImportClearTitle),
        content: Text(l10n.smsImportClearBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.smsImportClearConfirm),
          ),
        ],
      ),
    );
    if (!context.mounted || confirmed != true) return;
    await controller.clearAll();
  }

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
            title: l10n.smsImportToggleTitle,
            subtitle: l10n.smsImportToggleSubtitle,
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
                        Icon(Icons.sms_outlined, color: c.ink2),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.smsImportTitle,
                            style: NestText.itemTitle16.copyWith(color: c.ink),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.smsImportOffHint,
                      style: NestText.body15.copyWith(color: c.ink2),
                    ),
                  ],
                ),
              ),
            ),
          )
        else ...[
          SmsStatusCard(
            config: config,
            uiState: uiState,
            onRequestPermission: controller.requestPermission,
            onOpenSettings: controller.openAppSettings,
            onAutoCaptureChanged: controller.setAutoCapture,
            onScanDaysChanged: controller.setScanDays,
            onScanNow: () async {
              final added = await controller.scanNow();
              if (!context.mounted || added == null) return;
              snack.show(l10n.smsImportScanSummary(added));
            },
            onPasteSms: () => showPasteSmsSheet(context, ref),
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
                  l10n.smsImportDraftsEmpty,
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
              SmsDraftCard(
                draft: draft,
                accounting: uiState.accountingDraftId == draft.id,
                onReview: () => showSmsDraftReviewSheet(context, ref, draft),
                onAccountIt: () async {
                  final res = await controller.accountDraft(draft);
                  if (!context.mounted || res == null) return;
                  snack.show(
                    l10n.smsImportAccountedSnack(
                      res.merchant,
                      Money.formatPaise(res.amountPaise),
                    ),
                  );
                },
                onDiscard: () => controller.discardDraft(draft.id),
              ),
              const SizedBox(height: 10),
            ],
          ],
          if (config.drafts.isNotEmpty ||
              config.processedFingerprints.isNotEmpty) ...[
            const SizedBox(height: 12),
            NestButton(
              label: l10n.smsImportClearBtn,
              kind: NestButtonKind.dangerGhost,
              size: NestButtonSize.block,
              onPressed: () => _confirmClear(context, l10n),
            ),
          ],
        ],
      ],
    );
  }
}
