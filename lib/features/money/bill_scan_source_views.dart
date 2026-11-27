import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/features/money/bill_scan_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class BillScanSourceChooser extends StatelessWidget {
  const BillScanSourceChooser({
    super.key,
    required this.state,
    required this.pasteCtrl,
    required this.onCamera,
    required this.onGallery,
    required this.onOpenPaste,
    required this.onCancelPaste,
    required this.onExtractPaste,
  });

  final BillScanState state;
  final TextEditingController pasteCtrl;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onOpenPaste;
  final VoidCallback onCancelPaste;
  final VoidCallback onExtractPaste;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final errText = switch (state.errorKind) {
      'permissionDenied' => l10n.billScanErrPermission,
      'noCameraApp' => l10n.billScanErrNoCamera,
      'unsupported' => l10n.billScanErrUnsupported,
      'failed' => l10n.billScanErrFailed,
      'emptyPaste' => l10n.billScanErrEmptyPaste,
      _ => null,
    };

    if (state.pasteMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          NestSheetHeader(title: l10n.billScanPasteText),
          if (errText != null) ...[
            BillScanNoticeBanner(message: errText, danger: true),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: pasteCtrl,
            minLines: 5,
            maxLines: 10,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.billScanPasteHint,
              alignLabelWithHint: true,
            ),
          ),
          NestSheetActions(
            children: [
              NestButton(
                label: l10n.commonBack,
                kind: NestButtonKind.ghost,
                onPressed: onCancelPaste,
              ),
              NestButton(
                label: l10n.billScanExtractAction,
                onPressed: onExtractPaste,
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(
          title: l10n.billScanSheetTitle,
          lead: l10n.billScanChooseHint,
        ),
        if (errText != null) ...[
          BillScanNoticeBanner(message: errText, danger: true),
          const SizedBox(height: 12),
        ],
        NestButton(
          label: l10n.billScanTakePhoto,
          icon: Icons.photo_camera_outlined,
          size: NestButtonSize.block,
          onPressed: onCamera,
        ),
        const SizedBox(height: 10),
        NestButton(
          label: l10n.billScanFromGallery,
          icon: Icons.photo_library_outlined,
          kind: NestButtonKind.tonal,
          size: NestButtonSize.block,
          onPressed: onGallery,
        ),
        const SizedBox(height: 10),
        NestButton(
          label: l10n.billScanPasteText,
          icon: Icons.content_paste_outlined,
          kind: NestButtonKind.ghost,
          size: NestButtonSize.block,
          onPressed: onOpenPaste,
        ),
      ],
    );
  }
}

class BillScanProgressView extends StatelessWidget {
  const BillScanProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(title: l10n.billScanSheetTitle),
        const SizedBox(height: 20),
        const Center(child: CircularProgressIndicator()),
        const SizedBox(height: 16),
        Text(
          l10n.billScanScanning,
          style: NestText.body15.copyWith(color: c.ink2),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class BillScanNoticeBanner extends StatelessWidget {
  const BillScanNoticeBanner({
    super.key,
    required this.message,
    this.danger = false,
  });

  final String message;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: danger ? c.danger.withValues(alpha: 0.1) : c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: danger ? c.danger.withValues(alpha: 0.35) : c.line,
        ),
      ),
      child: Text(
        message,
        style: NestText.meta13.copyWith(color: danger ? c.danger : c.ink2),
      ),
    );
  }
}

class BillScanRawOcrBox extends StatelessWidget {
  const BillScanRawOcrBox({
    super.key,
    required this.rawText,
    required this.confidence,
    required this.expanded,
    required this.onToggle,
  });

  final String rawText;
  final int confidence;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onToggle,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    expanded
                        ? l10n.billScanRawOcrHide
                        : l10n.billScanRawOcrShow,
                    style: NestText.meta13.copyWith(color: c.ink2),
                  ),
                ),
                if (confidence > 0 && confidence < 100) ...[
                  Text(
                    l10n.billScanConfidenceLabel(confidence),
                    style: NestText.small12.copyWith(color: c.ink3),
                  ),
                  const SizedBox(width: 6),
                ],
                Icon(
                  expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 20,
                  color: c.ink2,
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.line),
            ),
            child: SelectableText(
              rawText.trim().isEmpty ? l10n.billScanNoTextFound : rawText,
              style: NestText.small12.copyWith(color: c.ink2),
            ),
          ),
      ],
    );
  }
}
