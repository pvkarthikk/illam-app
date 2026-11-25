import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/remote_sync_config_parser.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/remote/remote_sync_config.dart';
import 'package:nm_flat/features/remote_sync/remote_sync_controller.dart';
import 'package:nm_flat/features/remote_sync/remote_sync_parts.dart';
import 'package:nm_flat/features/remote_sync/remote_sync_qr_sheet.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class RemoteSyncConfigForm extends ConsumerStatefulWidget {
  const RemoteSyncConfigForm({
    super.key,
    required this.config,
    required this.uiState,
    required this.controller,
  });

  final RemoteSyncConfig config;
  final RemoteSyncUiState uiState;
  final RemoteSyncController controller;

  @override
  ConsumerState<RemoteSyncConfigForm> createState() =>
      _RemoteSyncConfigFormState();
}

class _RemoteSyncConfigFormState extends ConsumerState<RemoteSyncConfigForm> {
  late final TextEditingController _projectCtrl;
  late final TextEditingController _keyCtrl;
  late final TextEditingController _dbCtrl;
  bool _obscureKey = true;
  Map<String, FirebaseConfigFieldError> _errors = const {};

  @override
  void initState() {
    super.initState();
    _projectCtrl = TextEditingController(text: widget.config.projectId);
    _keyCtrl = TextEditingController(text: widget.config.apiKey);
    _dbCtrl = TextEditingController(
      text: widget.config.databaseId == kDefaultFirestoreDatabaseId
          ? ''
          : widget.config.databaseId,
    );
  }

  @override
  void didUpdateWidget(covariant RemoteSyncConfigForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.projectId != widget.config.projectId &&
        widget.config.projectId != _projectCtrl.text) {
      _projectCtrl.text = widget.config.projectId;
    }
    if (oldWidget.config.apiKey != widget.config.apiKey &&
        widget.config.apiKey != _keyCtrl.text) {
      _keyCtrl.text = widget.config.apiKey;
    }
    if (oldWidget.config.databaseId != widget.config.databaseId) {
      final db = widget.config.databaseId == kDefaultFirestoreDatabaseId
          ? ''
          : widget.config.databaseId;
      if (db != _dbCtrl.text) _dbCtrl.text = db;
    }
  }

  @override
  void dispose() {
    _projectCtrl.dispose();
    _keyCtrl.dispose();
    _dbCtrl.dispose();
    super.dispose();
  }

  void _applyParsed(ParsedFirebaseConfig cfg) {
    setState(() {
      _projectCtrl.text = cfg.projectId;
      _keyCtrl.text = cfg.apiKey;
      _dbCtrl.text = cfg.databaseId == kDefaultFirestoreDatabaseId
          ? ''
          : cfg.databaseId;
      _errors = const {};
    });
    widget.controller.clearTestStatus();
    ref
        .read(snackbarProvider)
        .show(AppLocalizations.of(context).remoteSyncConfigApplied);
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final raw = data?.text ?? '';
    final parsed = parseFirebaseConfigSnippet(raw);
    if (!mounted) return;
    if (parsed != null) {
      _applyParsed(parsed);
      return;
    }
    final manual = await showPasteFirebaseConfigSheet(context);
    if (!mounted || manual == null) return;
    _applyParsed(manual);
  }

  Future<void> _scanQr() async {
    final parsed = await showRemoteSyncScanSheet(context);
    if (!mounted || parsed == null) return;
    _applyParsed(parsed);
  }

  ParsedFirebaseConfig? _validatedConfig() {
    final errs = validateFirebaseConfig(
      projectId: _projectCtrl.text,
      apiKey: _keyCtrl.text,
      databaseId: _dbCtrl.text,
    );
    setState(() => _errors = errs);
    if (errs.isNotEmpty) return null;
    return ParsedFirebaseConfig(
      projectId: _projectCtrl.text.trim(),
      apiKey: _keyCtrl.text.trim(),
      databaseId: normalizeDatabaseId(_dbCtrl.text),
    );
  }

  String? _fieldErrorText(AppLocalizations l10n, String field) {
    final err = _errors[field];
    if (err == null) return null;
    return switch (err) {
      FirebaseConfigFieldError.projectIdEmpty => l10n.remoteSyncErrProjectEmpty,
      FirebaseConfigFieldError.projectIdInvalid =>
        l10n.remoteSyncErrProjectInvalid,
      FirebaseConfigFieldError.apiKeyEmpty => l10n.remoteSyncErrKeyEmpty,
      FirebaseConfigFieldError.apiKeyInvalid => l10n.remoteSyncErrKeyInvalid,
      FirebaseConfigFieldError.databaseIdInvalid => l10n.remoteSyncErrDbInvalid,
    };
  }

  Future<void> _confirmRemove() async {
    final l10n = AppLocalizations.of(context);
    await showNestSheet<void>(
      context,
      (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NestSheetHeader(
            title: l10n.remoteSyncRemoveTitle,
            lead: l10n.remoteSyncRemoveBody,
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
                label: l10n.remoteSyncRemoveConfirm,
                kind: NestButtonKind.danger,
                size: NestButtonSize.block,
                onPressed: () async {
                  await widget.controller.clearConfig();
                  if (!ctx.mounted) return;
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final ui = widget.uiState;
    final busy = ui.testing || ui.saving;

    return NestCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.remoteSyncConfigTitle,
            style: NestText.itemTitle16.copyWith(color: c.ink),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.remoteSyncConfigLead,
            style: NestText.meta13.copyWith(color: c.ink3),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              NestButton(
                label: l10n.remoteSyncPasteConfig,
                icon: Icons.content_paste_rounded,
                kind: NestButtonKind.tonal,
                size: NestButtonSize.sm,
                onPressed: busy ? null : _pasteFromClipboard,
              ),
              if (!kIsWeb)
                NestButton(
                  label: l10n.remoteSyncScanQr,
                  icon: Icons.qr_code_scanner_rounded,
                  kind: NestButtonKind.ghost,
                  size: NestButtonSize.sm,
                  onPressed: busy ? null : _scanQr,
                ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _projectCtrl,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.remoteSyncProjectIdLabel,
              hintText: l10n.remoteSyncProjectIdHint,
              errorText: _fieldErrorText(l10n, 'projectId'),
            ),
            onChanged: (_) {
              if (_errors.containsKey('projectId')) {
                setState(() => _errors = {..._errors}..remove('projectId'));
              }
              widget.controller.clearTestStatus();
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _keyCtrl,
            obscureText: _obscureKey,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.remoteSyncApiKeyLabel,
              hintText: l10n.remoteSyncApiKeyHint,
              errorText: _fieldErrorText(l10n, 'apiKey'),
              suffixIcon: IconButton(
                tooltip: _obscureKey
                    ? l10n.remoteSyncShowApiKey
                    : l10n.remoteSyncHideApiKey,
                icon: Icon(
                  _obscureKey
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscureKey = !_obscureKey),
              ),
            ),
            onChanged: (_) {
              if (_errors.containsKey('apiKey')) {
                setState(() => _errors = {..._errors}..remove('apiKey'));
              }
              widget.controller.clearTestStatus();
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dbCtrl,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: l10n.remoteSyncDatabaseIdLabel,
              hintText: l10n.remoteSyncDatabaseIdHint,
              errorText: _fieldErrorText(l10n, 'databaseId'),
            ),
            onChanged: (_) {
              if (_errors.containsKey('databaseId')) {
                setState(() => _errors = {..._errors}..remove('databaseId'));
              }
              widget.controller.clearTestStatus();
            },
          ),
          if (ui.testOk) ...[
            const SizedBox(height: 14),
            AlertLine(
              icon: Icons.check_circle_outline_rounded,
              text: l10n.remoteSyncTestOk,
            ),
          ] else if (ui.testErrorCode != null) ...[
            const SizedBox(height: 14),
            AlertLine(
              icon: Icons.error_outline_rounded,
              danger: true,
              text: remoteSyncErrorText(l10n, ui.testErrorCode!),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: NestButton(
                  label: ui.testing
                      ? l10n.remoteSyncTestingBtn
                      : l10n.remoteSyncTestBtn,
                  kind: NestButtonKind.ghost,
                  size: NestButtonSize.block,
                  onPressed: busy
                      ? null
                      : () {
                          final cfg = _validatedConfig();
                          if (cfg != null) widget.controller.testConnection(cfg);
                        },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NestButton(
                  label: ui.saving
                      ? l10n.remoteSyncSavingBtn
                      : l10n.remoteSyncSaveBtn,
                  kind: NestButtonKind.primary,
                  size: NestButtonSize.block,
                  onPressed: busy
                      ? null
                      : () async {
                          final cfg = _validatedConfig();
                          if (cfg == null) return;
                          await widget.controller.saveConfig(cfg);
                          if (!context.mounted) return;
                          ref
                              .read(snackbarProvider)
                              .show(l10n.remoteSyncSavedSnack);
                        },
                ),
              ),
            ],
          ),
          if (widget.config.isConfigured) ...[
            const SizedBox(height: 12),
            NestButton(
              label: l10n.remoteSyncRemoveBtn,
              kind: NestButtonKind.dangerGhost,
              size: NestButtonSize.block,
              onPressed: busy ? null : _confirmRemove,
            ),
          ],
        ],
      ),
    );
  }
}
