import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/destination_secrets.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/http_tools.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/backup/backup_controller.dart';
import 'package:nm_flat/features/backup/backup_password_sheet.dart';
import 'package:nm_flat/features/backup/backup_setup_parts.dart';

class ServerConnectState {
  const ServerConnectState({
    this.busy = false,
    this.errorKey,
    this.trustFingerprint,
    this.next,
  });

  final bool busy;
  final String? errorKey;
  final String? trustFingerprint;
  final ConnectNext? next;

  ServerConnectState copyWith({
    bool? busy,
    String? errorKey,
    bool clearError = false,
    String? trustFingerprint,
    bool clearTrust = false,
    ConnectNext? next,
    bool clearNext = false,
  }) => ServerConnectState(
    busy: busy ?? this.busy,
    errorKey: clearError ? null : (errorKey ?? this.errorKey),
    trustFingerprint: clearTrust
        ? null
        : (trustFingerprint ?? this.trustFingerprint),
    next: clearNext ? null : (next ?? this.next),
  );
}

class ServerConnectController extends Notifier<ServerConnectState> {
  int _gen = 0;

  @override
  ServerConnectState build() => const ServerConnectState();

  void cancel() => _gen++;

  void reset() {
    _gen++;
    state = const ServerConnectState();
  }

  void setErrorKey(String? key) => state = state.copyWith(
    errorKey: key,
    clearError: key == null,
    clearTrust: true,
  );

  BackupDestination _build(DestinationConfig c, String secret) =>
      destinationWithSecret(c, secret);

  Future<bool> connect({
    required DestinationConfig config,
    required String secret,
    required ConnectMode mode,
  }) async {
    final gen = _gen;
    state = state.copyWith(
      busy: true,
      clearError: true,
      clearTrust: true,
      clearNext: true,
    );
    try {
      final dest = _build(config, secret);
      if (mode == ConnectMode.restore) {
        await dest.list();
      } else {
        await dest.testWrite();
      }
      if (_gen != gen) return false;
      await DestinationSecrets(
        ref.read(secureStoreProvider),
      ).write(config.destId, secret);
      final next = await ref
          .read(backupControllerProvider.notifier)
          .onConnected(config, mode);
      state = state.copyWith(next: next);
      return true;
    } on DestinationException catch (e) {
      if (e.error == DestError.untrustedCert) {
        final rawUrl =
            (config.settings['url'] as String?) ??
            (config.settings['server'] as String?) ??
            '';
        final u = Uri.tryParse(rawUrl);
        final fp = (u != null && u.host.isNotEmpty)
            ? await fetchTlsFingerprint(u.host, u.hasPort ? u.port : 443)
            : null;
        if (fp != null) {
          state = state.copyWith(trustFingerprint: fp);
        } else {
          state = state.copyWith(errorKey: DestError.unreachable.name);
        }
        return false;
      }
      if (e.error == DestError.untrustedHostKey) {
        final fp = e.detail;
        if (fp != null && fp.isNotEmpty) {
          state = state.copyWith(trustFingerprint: fp);
        } else {
          state = state.copyWith(errorKey: DestError.unreachable.name);
        }
        return false;
      }
      state = state.copyWith(errorKey: e.error.name);
      return false;
    } on Object catch (e) {
      debugPrint('Server connect failed: $e');
      state = state.copyWith(errorKey: DestError.other.name);
      return false;
    } finally {
      state = state.copyWith(busy: false);
    }
  }

  Future<bool> trustAndRetry({
    required DestinationConfig config,
    required String secret,
    required ConnectMode mode,
  }) async {
    final fp = state.trustFingerprint;
    if (fp == null) return false;
    final settings = Map<String, Object?>.from(config.settings);
    settings[config.kind == 'sftp' ? 'hostKey' : 'tlsPin'] = fp;
    return connect(
      config: config.copyWith(settings: settings),
      secret: secret,
      mode: mode,
    );
  }
}

final serverConnectControllerProvider =
    NotifierProvider<ServerConnectController, ServerConnectState>(
      ServerConnectController.new,
    );

/// Closes the active server sheet, closes any parent chooser sheet via
/// [onPicked], and completes password setup or restore navigation.
Future<void> finishServerConnectSheet(
  BuildContext pageContext,
  BuildContext sheetContext,
  WidgetRef ref, {
  VoidCallback? onPicked,
}) async {
  final next = ref.read(serverConnectControllerProvider).next;
  final nav = Navigator.of(pageContext);
  final router = GoRouter.of(pageContext);
  if (sheetContext.mounted) {
    Navigator.of(sheetContext).pop();
  }
  onPicked?.call();
  if (next == ConnectNext.restore) {
    router.go(Routes.onboardingStep('restore-pick'));
  } else if (next == ConnectNext.askPassword && nav.mounted) {
    await showBackupPasswordSheet(nav.context, ref);
  }
}
