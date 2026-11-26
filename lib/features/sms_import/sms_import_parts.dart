import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sms/sms_import_config.dart';
import 'package:nm_flat/core/sms/sms_platform_bridge.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/sms_import/sms_import_controller.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/today/sections/sync_tag.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Displays Android SMS permissions, auto-capture switch, window chips, and
/// inbox / paste scan actions.
class SmsStatusCard extends ConsumerWidget {
  const SmsStatusCard({
    super.key,
    required this.config,
    required this.uiState,
    required this.onRequestPermission,
    required this.onOpenSettings,
    required this.onAutoCaptureChanged,
    required this.onScanDaysChanged,
    required this.onScanNow,
    required this.onPasteSms,
  });

  final SmsImportConfig config;
  final SmsImportUiState uiState;
  final VoidCallback onRequestPermission;
  final VoidCallback onOpenSettings;
  final ValueChanged<bool> onAutoCaptureChanged;
  final ValueChanged<int> onScanDaysChanged;
  final VoidCallback onScanNow;
  final VoidCallback onPasteSms;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    ref.watch(minuteTickProvider);
    final nowMs = ref.read(clockProvider).nowMs;
    final perm = uiState.permission ?? const SmsPermissionStatus.unsupported();

    final String statusText;
    final Color iconBg;
    final Color iconFg;
    if (!perm.supported) {
      statusText = l10n.smsImportStatusUnsupported;
      iconBg = c.paper2;
      iconFg = c.ink2;
    } else if (perm.allGranted) {
      statusText = l10n.smsImportStatusGranted;
      iconBg = c.primarySoft;
      iconFg = c.primary;
    } else if (perm.canScanInbox) {
      statusText = l10n.smsImportStatusPartial;
      iconBg = c.accentSoft;
      iconFg = c.accentInk;
    } else if (perm.permanentlyDenied) {
      statusText = l10n.smsImportStatusRestricted;
      iconBg = c.dangerSoft;
      iconFg = c.danger;
    } else {
      statusText = l10n.smsImportStatusNeeded;
      iconBg = c.accentSoft;
      iconFg = c.accentInk;
    }

    final scanInfo = (config.lastScanAtMs == null || config.lastScanAtMs == 0)
        ? l10n.smsImportNeverScanned
        : l10n.smsImportLastScan(agoText(l10n, nowMs, config.lastScanAtMs!));

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
                  child: Icon(Icons.sms_outlined, color: iconFg),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.smsImportStatusTitle,
                        style: NestText.itemTitle16.copyWith(color: c.ink),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statusText,
                        style: NestText.body15.copyWith(color: c.ink2),
                      ),
                      if (perm.canScanInbox) ...[
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
            const SizedBox(height: 10),
            Divider(height: 1, color: c.line),
            SwitchRow(
              title: l10n.smsImportAutoCaptureTitle,
              subtitle: l10n.smsImportAutoCaptureSub,
              value: config.autoCapture,
              onChanged: onAutoCaptureChanged,
            ),
            Divider(height: 1, color: c.line),
            const SizedBox(height: 12),
            Text(
              l10n.smsImportWindowLabel,
              style: NestText.meta13.copyWith(color: c.ink3),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final days in const [7, 30, 90])
                  NestChip(
                    label: l10n.smsImportWindowDays(days),
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
                if (perm.supported && !perm.allGranted)
                  NestButton(
                    label: perm.permanentlyDenied
                        ? l10n.smsImportOpenSettingsBtn
                        : l10n.smsImportGrantBtn,
                    icon: perm.permanentlyDenied
                        ? Icons.settings_outlined
                        : Icons.verified_user_outlined,
                    onPressed: uiState.requestingPermission
                        ? null
                        : (perm.permanentlyDenied
                              ? onOpenSettings
                              : onRequestPermission),
                  ),
                if (perm.canScanInbox)
                  NestButton(
                    label: uiState.scanning
                        ? l10n.smsImportScanningBtn
                        : l10n.smsImportScanNowBtn,
                    icon: Icons.refresh_rounded,
                    onPressed: uiState.scanning ? null : onScanNow,
                  ),
                NestButton(
                  label: l10n.smsImportPasteBtn,
                  kind: NestButtonKind.tonal,
                  icon: Icons.content_paste_rounded,
                  onPressed: onPasteSms,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact SMS spend draft card shared across [SmsImportScreen] and [MoneyScreen].
class SmsDraftCard extends ConsumerWidget {
  const SmsDraftCard({
    super.key,
    required this.draft,
    required this.onReview,
    required this.onAccountIt,
    required this.onDiscard,
    this.accounting = false,
  });

  final SmsDraftSpend draft;
  final VoidCallback onReview;
  final VoidCallback onAccountIt;
  final VoidCallback onDiscard;
  final bool accounting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final today = ref.watch(todayDateProvider);

    final methodLabel = switch (draft.method) {
      'cash' => l10n.moneyMethodCash,
      'card' => l10n.moneyMethodCard,
      'bank' => l10n.moneyMethodBank,
      _ => l10n.moneyMethodUpi,
    };
    final accountLabel = draft.accountLabel();
    final metaParts = [
      Formatters.dayLabel(draft.date, today, l10n),
      methodLabel,
      ?accountLabel,
    ];

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
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        draft.merchant,
                        style: NestText.itemTitle16.copyWith(color: c.ink),
                      ),
                      NestTag(
                        label: l10n.gmailImportDraftBadge,
                        kind: NestTagKind.accent,
                      ),
                      NestTag(
                        label: l10n.smsImportTagLabel,
                        kind: NestTagKind.info,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  Money.formatPaise(draft.amountPaise),
                  style: NestText.itemTitle16.copyWith(color: c.ink),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${metaParts.join(' · ')} · ${draft.category}',
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

/// Modal sheet to paste an SMS string offline and create a draft spend.
Future<void> showPasteSmsSheet(BuildContext context, WidgetRef ref) async {
  await showNestSheet<void>(
    context,
    (_) => _PasteSmsSheet(ref: ref),
  );
}

class _PasteSmsSheet extends StatefulWidget {
  const _PasteSmsSheet({required this.ref});

  final WidgetRef ref;

  @override
  State<_PasteSmsSheet> createState() => _PasteSmsSheetState();
}

class _PasteSmsSheetState extends State<_PasteSmsSheet> {
  final _ctrl = TextEditingController();
  bool _notMatched = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _parse() async {
    final l10n = AppLocalizations.of(context);
    final draft = await widget.ref
        .read(smsImportControllerProvider.notifier)
        .importPastedSms(_ctrl.text);
    if (!mounted) return;
    if (draft == null) {
      setState(() => _notMatched = true);
      return;
    }
    Navigator.of(context).pop();
    widget.ref
        .read(snackbarProvider)
        .show(l10n.smsImportPasteAddedSnack(draft.merchant));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(
          title: l10n.smsImportPasteTitle,
          lead: l10n.smsImportPasteLead,
        ),
        TextField(
          controller: _ctrl,
          maxLines: 6,
          minLines: 4,
          decoration: InputDecoration(
            labelText: l10n.smsImportPasteField,
            alignLabelWithHint: true,
          ),
          onChanged: (_) {
            if (_notMatched) setState(() => _notMatched = false);
          },
        ),
        if (_notMatched) ...[
          const SizedBox(height: 10),
          AlertLine(
            icon: Icons.error_outline,
            text: l10n.smsImportPasteNotMatched,
            danger: true,
          ),
        ],
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.commonCancel,
              kind: NestButtonKind.ghost,
              size: NestButtonSize.block,
              onPressed: () => Navigator.of(context).pop(),
            ),
            NestButton(
              label: l10n.gmailImportParseToDraftBtn,
              size: NestButtonSize.block,
              onPressed: _parse,
            ),
          ],
        ),
      ],
    );
  }
}
