import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/destination_secrets.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/sftp/ssh_keys.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/util/ids.dart';
import 'package:nm_flat/features/backup/backup_setup_parts.dart';
import 'package:nm_flat/features/backup/servers/server_connect_controller.dart';
import 'package:nm_flat/features/backup/servers/server_error_text.dart';
import 'package:nm_flat/features/backup/servers/trust_sheet.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showSftpSheet(
  BuildContext context,
  WidgetRef ref,
  ConnectMode mode, {
  DestinationConfig? existing,
  VoidCallback? onPicked,
}) {
  ref.read(serverConnectControllerProvider.notifier).reset();
  return showNestSheet<void>(
    context,
    (ctx) => _SftpSheet(
      pageContext: context,
      sheetContext: ctx,
      mode: mode,
      existing: existing,
      onPicked: onPicked,
    ),
  );
}

class _SftpSheet extends ConsumerStatefulWidget {
  const _SftpSheet({
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
  ConsumerState<_SftpSheet> createState() => _SftpSheetState();
}

class _SftpSheetState extends ConsumerState<_SftpSheet> {
  late final TextEditingController _hostCtrl;
  late final TextEditingController _portCtrl;
  late final TextEditingController _userCtrl;
  final _passCtrl = TextEditingController();
  late final TextEditingController _folderCtrl;
  late String _auth;
  Uint8List? _seed;
  Uint8List? _pub;
  bool _loadingKey = false;

  @override
  void initState() {
    super.initState();
    final s = widget.existing?.settings;
    _hostCtrl = TextEditingController(text: (s?['host'] as String?) ?? '');
    _portCtrl = TextEditingController(
      text: ((s?['port'] as num?)?.toInt() ?? 22).toString(),
    );
    _userCtrl = TextEditingController(text: (s?['user'] as String?) ?? '');
    _folderCtrl = TextEditingController(
      text: (s?['folder'] as String?) ?? '/backups/illam',
    );
    _auth = (s?['auth'] as String?) == 'key' ? 'key' : 'password';
    if (_auth == 'key') {
      _ensureKey();
    }
  }

  @override
  void dispose() {
    _hostCtrl.dispose();
    _portCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _folderCtrl.dispose();
    super.dispose();
  }

  Future<void> _ensureKey() async {
    if (_seed != null && _pub != null || _loadingKey) return;
    setState(() => _loadingKey = true);
    try {
      Uint8List? seed;
      final existing = widget.existing;
      if (existing != null && existing.settings['auth'] == 'key') {
        final stored = await DestinationSecrets(
          ref.read(secureStoreProvider),
        ).read(existing.destId);
        if (stored != null && stored.isNotEmpty) {
          try {
            seed = base64Decode(stored);
          } on FormatException {
            seed = null;
          }
        }
      }
      seed ??= await SshKeys.newSeed();
      final pub = await SshKeys.publicFromSeed(seed);
      if (!mounted) return;
      setState(() {
        _seed = seed;
        _pub = pub;
      });
    } finally {
      if (mounted) setState(() => _loadingKey = false);
    }
  }

  Future<void> _connect() async {
    final l = AppLocalizations.of(context);
    final ctrl = ref.read(serverConnectControllerProvider.notifier);

    final host = _hostCtrl.text.trim();
    final port = int.tryParse(_portCtrl.text.trim()) ?? 22;
    final user = _userCtrl.text.trim();
    final folder = _folderCtrl.text.trim();

    if (_auth == 'key' && (_seed == null || _pub == null)) {
      await _ensureKey();
      if (!mounted) return;
    }

    if (host.isEmpty ||
        user.isEmpty ||
        folder.isEmpty ||
        port <= 0 ||
        port > 65535 ||
        (_auth == 'key' && (_seed == null || _pub == null))) {
      ctrl.setErrorKey(DestError.other.name);
      return;
    }

    final sameEndpoint =
        widget.existing?.settings['host'] == host &&
        (widget.existing?.settings['port'] as num?)?.toInt() == port;
    final existingHostKey = sameEndpoint
        ? widget.existing?.settings['hostKey'] as String?
        : null;

    final cfg = DestinationConfig(
      destId: widget.existing?.destId ?? Ids.newId(),
      kind: 'sftp',
      label: l.bkSrvSftpAccount(user, host, '$port'),
      settings: {
        'host': host,
        'port': port,
        'user': user,
        'folder': folder,
        'auth': _auth,
        'hostKey': existingHostKey,
        'publicKey': _auth == 'key' ? base64Encode(_pub!) : null,
      },
    );
    final secret = _auth == 'key' ? base64Encode(_seed!) : _passCtrl.text;

    var ok = await ctrl.connect(config: cfg, secret: secret, mode: widget.mode);
    if (!ok && mounted) {
      final fp = ref.read(serverConnectControllerProvider).trustFingerprint;
      if (fp != null) {
        final trusted = await showTrustSheet(
          context,
          host: host,
          fingerprint: fp,
        );
        if (trusted && mounted) {
          ok = await ctrl.trustAndRetry(
            config: cfg,
            secret: secret,
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

  Widget _buildKeyBody(
    AppLocalizations l,
    NestColors c,
    Color boxColor,
  ) {
    if (_pub == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.line),
          ),
          child: SelectableText(
            SshKeys.publicLine(_pub!),
            style: NestText.meta13.copyWith(
              fontFamily: 'monospace',
              color: c.ink,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: NestButton(
            label: l.bkSrvCopyKey,
            kind: NestButtonKind.tonal,
            size: NestButtonSize.sm,
            icon: Icons.copy_outlined,
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: SshKeys.publicLine(_pub!)),
              );
              ref.read(snackbarProvider).show(l.bkSrvKeyCopied);
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(l.bkSrvKeyHint, style: NestText.meta13.copyWith(color: c.ink3)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    final state = ref.watch(serverConnectControllerProvider);
    final errKey = state.errorKey;
    final errMsg = errKey == null
        ? null
        : serverErrorText(l, DestError.values.byName(errKey), l.backupProvSftp);
    final boxColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    final hostField = TextField(
      controller: _hostCtrl,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        labelText: l.bkSrvHost,
        hintText: 'nas.local',
      ),
    );
    final portField = TextField(
      controller: _portCtrl,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: l.bkSrvPort),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NestSheetHeader(title: l.bkSrvSftpTitle),
        LayoutBuilder(
          builder: (ctx, constraints) {
            final stack =
                constraints.maxWidth < 300 ||
                MediaQuery.textScalerOf(ctx).scale(1) >= 1.5;
            if (stack) {
              return Column(
                children: [hostField, const SizedBox(height: 12), portField],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: hostField),
                const SizedBox(width: 10),
                Expanded(child: portField),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _userCtrl,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(labelText: l.bkSrvUsername),
        ),
        const SizedBox(height: 14),
        Text(l.bkSrvSignInWith, style: NestText.meta13.copyWith(color: c.ink2)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            NestChip(
              label: l.bkSrvAuthPassword,
              selected: _auth == 'password',
              onTap: () => setState(() => _auth = 'password'),
            ),
            NestChip(
              label: l.bkSrvAuthKey,
              selected: _auth == 'key',
              onTap: () {
                setState(() => _auth = 'key');
                _ensureKey();
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_auth == 'password')
          TextField(
            controller: _passCtrl,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(labelText: l.bkSrvPassword),
          )
        else
          _buildKeyBody(l, c, boxColor),
        const SizedBox(height: 12),
        TextField(
          controller: _folderCtrl,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(labelText: l.bkSrvFolder),
        ),
        const SizedBox(height: 12),
        Text(
          l.bkSrvSftpAccessNote,
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
