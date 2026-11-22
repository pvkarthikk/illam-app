import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/http_tools.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/util/ids.dart';
import 'package:nm_flat/features/backup/backup_setup_parts.dart';
import 'package:nm_flat/features/backup/servers/server_connect_controller.dart';
import 'package:nm_flat/features/backup/servers/server_error_text.dart';
import 'package:nm_flat/features/backup/servers/trust_sheet.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showWebDavSheet(
  BuildContext context,
  WidgetRef ref,
  ConnectMode mode, {
  DestinationConfig? existing,
  VoidCallback? onPicked,
}) {
  ref.read(serverConnectControllerProvider.notifier).reset();
  return showNestSheet<void>(
    context,
    (ctx) => _WebDavSheet(
      pageContext: context,
      sheetContext: ctx,
      mode: mode,
      existing: existing,
      onPicked: onPicked,
    ),
  );
}

class _WebDavSheet extends ConsumerStatefulWidget {
  const _WebDavSheet({
    required this.pageContext,
    required this.sheetContext,
    required this.mode,
    this.existing,
    this.onPicked,
  });

  final BuildContext pageContext;
  final BuildContext sheetContext;
  final ConnectMode mode;
  final DestinationConfig? existing;
  final VoidCallback? onPicked;

  @override
  ConsumerState<_WebDavSheet> createState() => _WebDavSheetState();
}

class _WebDavSheetState extends ConsumerState<_WebDavSheet> {
  late final TextEditingController _urlCtrl;
  late final TextEditingController _userCtrl;
  final _passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlCtrl = TextEditingController(
      text: (widget.existing?.settings['url'] as String?) ?? '',
    );
    _userCtrl = TextEditingController(
      text: (widget.existing?.settings['user'] as String?) ?? '',
    );
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final ctrl = ref.read(serverConnectControllerProvider.notifier);
    var rawUrl = _urlCtrl.text.trim();
    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (rawUrl.isNotEmpty && !rawUrl.endsWith('/')) {
      rawUrl = '$rawUrl/';
    }
    final uri = Uri.tryParse(rawUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      ctrl.setErrorKey(DestError.other.name);
      return;
    }
    try {
      requireHttps(uri, allowHttp: kDebugMode);
    } on DestinationException catch (e) {
      ctrl.setErrorKey(e.error.name);
      return;
    }

    final l = AppLocalizations.of(context);
    final cfg = DestinationConfig(
      destId: widget.existing?.destId ?? Ids.newId(),
      kind: 'webdav',
      label: l.bkSrvAccount(user, uri.host),
      settings: {'url': rawUrl, 'user': user, 'tlsPin': null},
    );

    var ok = await ctrl.connect(config: cfg, secret: pass, mode: widget.mode);
    if (!ok && mounted) {
      final fp = ref.read(serverConnectControllerProvider).trustFingerprint;
      if (fp != null) {
        final trusted = await showTrustSheet(
          context,
          host: uri.host,
          fingerprint: fp,
        );
        if (trusted && mounted) {
          ok = await ctrl.trustAndRetry(
            config: cfg,
            secret: pass,
            mode: widget.mode,
          );
        }
      }
    }
    if (ok && widget.pageContext.mounted && widget.sheetContext.mounted) {
      await finishServerConnectSheet(
        widget.pageContext,
        widget.sheetContext,
        ref,
        onPicked: widget.onPicked,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    final state = ref.watch(serverConnectControllerProvider);
    final errKey = state.errorKey;
    final errMsg = errKey == null
        ? null
        : serverErrorText(
            l,
            DestError.values.byName(errKey),
            l.backupProvWebdav,
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NestSheetHeader(title: l.bkSrvWebdavTitle),
        TextField(
          controller: _urlCtrl,
          keyboardType: TextInputType.url,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            labelText: l.bkSrvServerAddress,
            hintText: 'https://nas.local:5006/backups',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _userCtrl,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(labelText: l.bkSrvUsername),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passCtrl,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(labelText: l.bkSrvAppPassword),
        ),
        const SizedBox(height: 12),
        Text(
          l.bkSrvWebdavHint,
          style: NestText.meta13.copyWith(color: c.ink3),
        ),
        if (errMsg != null) ...[
          const SizedBox(height: 10),
          Semantics(
            liveRegion: true,
            child: Text(
              errMsg,
              style: NestText.meta13.copyWith(color: c.danger),
            ),
          ),
        ],
        if (state.busy) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.backupChecking,
                  style: NestText.meta13.copyWith(color: c.ink2),
                ),
              ),
            ],
          ),
        ],
        NestSheetActions(
          children: [
            NestButton(
              label: l.commonCancel,
              kind: NestButtonKind.ghost,
              onPressed: () => Navigator.of(widget.sheetContext).pop(),
            ),
            NestButton(
              label: l.bkSrvConnect,
              kind: NestButtonKind.primary,
              onPressed: state.busy ? null : _connect,
            ),
          ],
        ),
      ],
    );
  }
}
