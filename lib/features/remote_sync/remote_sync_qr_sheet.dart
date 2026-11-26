import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/remote_sync_config_parser.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Displays a QR code and setup link to copy Firebase config onto another family phone.
Future<void> showRemoteSyncShareSheet(
  BuildContext context,
  ParsedFirebaseConfig cfg, {
  required VoidCallback onCopiedLink,
}) async {
  final shareUri = encodeRemoteShareUri(cfg);
  await showNestSheet<void>(
    context,
    (ctx) {
      final l10n = AppLocalizations.of(ctx);
      final c = ctx.nest;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NestSheetHeader(
            title: l10n.remoteSyncShareTitle,
            lead: l10n.remoteSyncShareLead,
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.line),
              ),
              child: QrImageView(
                data: shareUri,
                size: 204,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AlertLine(
            icon: Icons.shield_outlined,
            text: l10n.remoteSyncShareWarning,
          ),
          NestSheetActions(
            children: [
              NestButton(
                label: l10n.remoteSyncCopyShareLink,
                icon: Icons.copy_rounded,
                kind: NestButtonKind.tonal,
                size: NestButtonSize.block,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: shareUri));
                  if (!ctx.mounted) return;
                  Navigator.of(ctx).pop();
                  onCopiedLink();
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}

/// Opens a camera QR scanner sheet returning a parsed [ParsedFirebaseConfig], or `null`.
Future<ParsedFirebaseConfig?> showRemoteSyncScanSheet(BuildContext context) {
  return showModalBottomSheet<ParsedFirebaseConfig>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) => const _RemoteSyncScanSheet(),
  );
}

class _RemoteSyncScanSheet extends StatefulWidget {
  const _RemoteSyncScanSheet();

  @override
  State<_RemoteSyncScanSheet> createState() => _RemoteSyncScanSheetState();
}

class _RemoteSyncScanSheetState extends State<_RemoteSyncScanSheet> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'remote-sync-qr');
  StreamSubscription<Barcode>? _scanSub;
  bool _handled = false;
  String? _errorText;

  @override
  void dispose() {
    unawaited(_scanSub?.cancel());
    super.dispose();
  }

  void _onCreated(QRViewController controller, AppLocalizations l10n) {
    _scanSub = controller.scannedDataStream.listen(
      (barcode) => _onDetect(barcode, l10n),
    );
  }

  void _onDetect(Barcode barcode, AppLocalizations l10n) {
    if (_handled || !mounted) return;
    final raw = barcode.code;
    if (raw == null) return;
    final parsed = parseFirebaseConfigSnippet(raw);
    if (parsed != null) {
      _handled = true;
      Navigator.of(context).pop(parsed);
      return;
    }
    if (_errorText != l10n.remoteSyncScanInvalid) {
      setState(() => _errorText = l10n.remoteSyncScanInvalid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NestSheetHeader(
            title: l10n.remoteSyncScanTitle,
            lead: l10n.remoteSyncScanHint,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 260,
              child: QRView(
                key: _qrKey,
                onQRViewCreated: (c) => _onCreated(c, l10n),
                formatsAllowed: const [BarcodeFormat.qrcode],
              ),
            ),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 12),
            AlertLine(
              icon: Icons.error_outline_rounded,
              danger: true,
              text: _errorText!,
            ),
          ],
          const SizedBox(height: 12),
          NestButton(
            label: l10n.commonCancel,
            kind: NestButtonKind.ghost,
            size: NestButtonSize.block,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              l10n.remoteSyncTitle,
              style: NestText.small12.copyWith(color: c.ink3),
            ),
          ),
        ],
      ),
    );
  }
}
