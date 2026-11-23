import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/http_tools.dart';
import 'package:nm_flat/core/backup/destinations/webdav/nextcloud_login.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/util/ids.dart';
import 'package:nm_flat/features/backup/backup_setup_parts.dart';
import 'package:nm_flat/features/backup/servers/server_connect_controller.dart';
import 'package:nm_flat/features/backup/servers/server_error_text.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

enum _NextcloudStage { enter, opening, waiting }

Future<void> showNextcloudSheet(
  BuildContext context,
  WidgetRef ref,
  ConnectMode mode, {
  DestinationConfig? existing,
  VoidCallback? onPicked,
}) {
  ref.read(serverConnectControllerProvider.notifier).reset();
  return showNestSheet<void>(
    context,
    (ctx) => _NextcloudSheet(
      pageContext: context,
      sheetContext: ctx,
      mode: mode,
      existing: existing,
      onPicked: onPicked,
    ),
  );
}

class _NextcloudSheet extends ConsumerStatefulWidget {
  const _NextcloudSheet({
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
  ConsumerState<_NextcloudSheet> createState() => _NextcloudSheetState();
}

class _NextcloudSheetState extends ConsumerState<_NextcloudSheet> {
  late final TextEditingController _serverCtrl;
  _NextcloudStage _stage = _NextcloudStage.enter;
  String? _errorKey;
  String _host = '';
  Timer? _pollTimer;
  Timer? _timeoutTimer;
  bool _polling = false;

  @override
  void initState() {
    super.initState();
    _serverCtrl = TextEditingController(
      text: (widget.existing?.settings['server'] as String?) ?? '',
    );
  }

  @override
  void dispose() {
    _cancelTimers();
    _serverCtrl.dispose();
    super.dispose();
  }

  void _cancelTimers() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  void _backToEnter(String errorKey) {
    _cancelTimers();
    if (!mounted) return;
    setState(() {
      _stage = _NextcloudStage.enter;
      _errorKey = errorKey;
    });
  }

  Future<void> _startLogin() async {
    var raw = _serverCtrl.text.trim();
    if (raw.isNotEmpty && !raw.endsWith('/')) {
      raw = '$raw/';
    }
    final server = Uri.tryParse(raw);
    if (server == null || !server.hasScheme || server.host.isEmpty) {
      setState(() => _errorKey = DestError.other.name);
      return;
    }
    try {
      requireHttps(server, allowHttp: kDebugMode);
    } on DestinationException catch (e) {
      setState(() => _errorKey = e.error.name);
      return;
    }

    setState(() {
      _stage = _NextcloudStage.opening;
      _errorKey = null;
      _host = server.host;
    });

    try {
      final started = await NextcloudLogin(buildServerDio()).start(server);
      final launched = await launchUrl(
        started.login,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw const DestinationException(DestError.unreachable);
      }
      if (!mounted) return;
      setState(() => _stage = _NextcloudStage.waiting);
      _timeoutTimer = Timer(
        const Duration(minutes: 20),
        () => _backToEnter(DestError.other.name),
      );
      _schedulePoll(started.endpoint, started.token, _pollStart);
    } on DestinationException catch (e) {
      _backToEnter(e.error.name);
    } on Object catch (e) {
      debugPrint('Nextcloud login start failed: $e');
      _backToEnter(DestError.other.name);
    }
  }

  static const _pollStart = Duration(seconds: 3);
  static const _pollMax = Duration(seconds: 15);

  /// Polls with a growing delay (3 s, 4.5 s, ... capped at 15 s).
  void _schedulePoll(Uri endpoint, String token, Duration delay) {
    _pollTimer?.cancel();
    _pollTimer = Timer(delay, () async {
      await _pollOnce(endpoint, token);
      if (!mounted || _stage != _NextcloudStage.waiting) return;
      final next = delay * 1.5;
      _schedulePoll(endpoint, token, next > _pollMax ? _pollMax : next);
    });
  }

  Future<void> _pollOnce(Uri endpoint, String token) async {
    if (_polling || !mounted || _stage != _NextcloudStage.waiting) return;
    _polling = true;
    try {
      final login = NextcloudLogin(buildServerDio());
      final ({String server, String loginName, String appPassword})? polled;
      try {
        polled = await login.pollOnce(endpoint, token);
      } on Object catch (e) {
        debugPrint('Nextcloud poll error: $e');
        return;
      }
      if (polled == null || !mounted) return;

      _cancelTimers();
      try {
        var rawSrv = polled.server.trim();
        if (rawSrv.isNotEmpty && !rawSrv.endsWith('/')) {
          rawSrv = '$rawSrv/';
        }
        final srvUri = Uri.parse(rawSrv);
        final id = await login.userId(
          srvUri,
          polled.loginName,
          polled.appPassword,
        );
        if (!mounted) return;

        final l = AppLocalizations.of(context);
        final cfg = DestinationConfig(
          destId: widget.existing?.destId ?? Ids.newId(),
          kind: 'nextcloud',
          label: l.bkSrvAccount(polled.loginName, srvUri.host),
          settings: {
            'server': srvUri.toString(),
            'loginName': polled.loginName,
            'userId': id,
            'url': NextcloudLogin.davFolder(srvUri, id).toString(),
            'tlsPin': null,
          },
        );

        final ctrl = ref.read(serverConnectControllerProvider.notifier);
        final ok = await ctrl.connect(
          config: cfg,
          secret: polled.appPassword,
          mode: widget.mode,
        );
        if (!mounted) return;
        if (ok) {
          if (widget.pageContext.mounted && widget.sheetContext.mounted) {
            await finishServerConnectSheet(
              widget.pageContext,
              widget.sheetContext,
              ref,
              onPicked: widget.onPicked,
            );
          }
        } else {
          final err = ref.read(serverConnectControllerProvider).errorKey;
          _backToEnter(err ?? DestError.other.name);
        }
      } on DestinationException catch (e) {
        _backToEnter(e.error.name);
      } on Object catch (e) {
        debugPrint('Nextcloud setup failed: $e');
        _backToEnter(DestError.other.name);
      }
    } finally {
      _polling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nest;

    switch (_stage) {
      case _NextcloudStage.enter:
        final errMsg = _errorKey == null
            ? null
            : serverErrorText(
                l,
                DestError.values.byName(_errorKey!),
                l.backupProvNextcloud,
              );
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NestSheetHeader(title: l.bkSrvNextcloudTitle),
            TextField(
              controller: _serverCtrl,
              keyboardType: TextInputType.url,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: l.bkSrvServerAddress,
                hintText: 'https://cloud.example.com',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.bkSrvNextcloudHint,
              style: NestText.meta13.copyWith(color: c.ink3),
            ),
            const SizedBox(height: 8),
            Text(
              l.bkSrvNextcloudAccessNote,
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
            NestSheetActions(
              children: [
                NestButton(
                  label: l.commonCancel,
                  kind: NestButtonKind.ghost,
                  onPressed: () => Navigator.of(widget.sheetContext).pop(),
                ),
                NestButton(
                  label: l.bkSrvContinueInBrowser,
                  kind: NestButtonKind.primary,
                  onPressed: _startLogin,
                ),
              ],
            ),
          ],
        );

      case _NextcloudStage.opening:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NestSheetHeader(title: l.bkSrvNextcloudTitle),
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.bkSrvOpeningLogin,
                    style: NestText.body15.copyWith(color: c.ink2),
                  ),
                ),
              ],
            ),
            NestSheetActions(
              children: [
                NestButton(
                  label: l.commonCancel,
                  kind: NestButtonKind.ghost,
                  onPressed: () => Navigator.of(widget.sheetContext).pop(),
                ),
              ],
            ),
          ],
        );

      case _NextcloudStage.waiting:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NestSheetHeader(
              title: l.bkSrvApproveTitle,
              lead: l.bkSrvApproveLead(_host),
            ),
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.bkSrvWaitingApproval,
                    style: NestText.body15.copyWith(color: c.ink2),
                  ),
                ),
              ],
            ),
            NestSheetActions(
              children: [
                NestButton(
                  label: l.commonCancel,
                  kind: NestButtonKind.ghost,
                  onPressed: () {
                    _cancelTimers();
                    Navigator.of(widget.sheetContext).pop();
                  },
                ),
              ],
            ),
          ],
        );
    }
  }
}
