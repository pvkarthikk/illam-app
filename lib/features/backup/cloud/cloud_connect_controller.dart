import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/cloud/appauth_sign_in.dart';
import 'package:nm_flat/core/backup/cloud/cloud_ids.dart';
import 'package:nm_flat/core/backup/cloud/dropbox_destination.dart';
import 'package:nm_flat/core/backup/cloud/gdrive_destination.dart';
import 'package:nm_flat/core/backup/cloud/google_auth.dart';
import 'package:nm_flat/core/backup/cloud/onedrive_destination.dart';
import 'package:nm_flat/core/backup/cloud/pcloud_auth.dart';
import 'package:nm_flat/core/backup/cloud/pcloud_destination.dart';
import 'package:nm_flat/core/backup/cloud/token_keeper.dart';
import 'package:nm_flat/core/backup/destination_secrets.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/http_tools.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/util/ids.dart';
import 'package:nm_flat/features/backup/backup_controller.dart';
import 'package:nm_flat/features/backup/backup_setup_parts.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class CloudConnectState {
  const CloudConnectState({
    this.busy,
    this.errorKey,
    this.errorProvider,
    this.lastNext,
  });

  final String? busy;
  final String? errorKey;
  final String? errorProvider;
  final ConnectNext? lastNext;

  CloudConnectState copyWith({
    String? busy,
    bool clearBusy = false,
    String? errorKey,
    String? errorProvider,
    bool clearError = false,
    ConnectNext? lastNext,
    bool clearNext = false,
  }) => CloudConnectState(
    busy: clearBusy ? null : (busy ?? this.busy),
    errorKey: clearError ? null : (errorKey ?? this.errorKey),
    errorProvider: clearError ? null : (errorProvider ?? this.errorProvider),
    lastNext: clearNext ? null : (lastNext ?? this.lastNext),
  );
}

class CloudConnectController extends Notifier<CloudConnectState> {
  @override
  CloudConnectState build() => const CloudConnectState();

  String _providerName(String kind, AppLocalizations l10n) => switch (kind) {
    'gdrive' => l10n.backupProvGdrive,
    'dropbox' => l10n.backupProvDropbox,
    'onedrive' => l10n.backupProvOnedrive,
    'pcloud' => l10n.backupProvPcloud,
    _ => kind,
  };

  Future<void> connect(
    String kind,
    ConnectMode mode, {
    String? reauthDestId,
    required AppLocalizations l10n,
  }) async {
    if (state.busy == 'pcloud') {
      PcloudAuth.cancel();
      await Future<void>.delayed(Duration.zero);
    }
    if (state.busy != null) return;
    state = state.copyWith(clearError: true, clearNext: true);

    final provider = _providerName(kind, l10n);
    final clientId = switch (kind) {
      'gdrive' => CloudIds.googleServerClientId,
      'dropbox' => CloudIds.dropboxAppKey,
      'onedrive' => CloudIds.microsoftClientId,
      'pcloud' => CloudIds.pcloudClientId,
      _ => '',
    };
    if (!CloudIds.has(clientId)) {
      state = state.copyWith(
        errorKey: 'bkCloudNotConfigured',
        errorProvider: provider,
      );
      return;
    }

    state = state.copyWith(busy: kind);
    final secure = ref.read(secureStoreProvider);
    final secrets = DestinationSecrets(secure);
    String? writtenDestId;

    try {
      final DestinationConfig config;
      final BackupDestination dest;

      switch (kind) {
        case 'gdrive':
        case 'dropbox':
        case 'onedrive':
          final isDropbox = kind == 'dropbox';
          final isGdrive = kind == 'gdrive';
          final oauth = isGdrive
              ? googleOAuth
              : (isDropbox ? dropboxOAuth : microsoftOAuth);
          final tokens = await appAuthSignIn(oauth);
          if (tokens == null) return;
          final destId = reauthDestId ?? Ids.newId();
          await secrets.write(destId, jsonEncode(tokens.toJson()));
          if (mode != ConnectMode.reauth) {
            writtenDestId = destId;
          }
          final keeper = TokenKeeper(
            buildServerDio(),
            secrets,
            destId,
            oauth,
          );
          final email = isGdrive
              ? await GdriveDestination.accountEmail(keeper)
              : isDropbox
              ? await DropboxDestination.accountEmail(keeper)
              : await OneDriveDestination.accountEmail(keeper);
          config = DestinationConfig(
            destId: destId,
            kind: kind,
            label: email,
            settings: {'email': email},
          );
          dest = isGdrive
              ? GdriveDestination(keeper)
              : isDropbox
              ? DropboxDestination(keeper)
              : OneDriveDestination(keeper);

        case 'pcloud':
          final res = await PcloudAuth.signIn();
          if (res == null) return;
          final email = await PcloudDestination.accountEmail(
            res.host,
            res.token,
          );
          final destId = reauthDestId ?? Ids.newId();
          final region = res.host == 'eapi.pcloud.com' ? 'EU' : 'US';
          config = DestinationConfig(
            destId: destId,
            kind: 'pcloud',
            label: l10n.bkCloudPcloudAccount(email, region),
            settings: {'email': email, 'host': res.host},
          );
          await secrets.write(destId, res.token);
          if (mode != ConnectMode.reauth) {
            writtenDestId = destId;
          }
          dest = PcloudDestination(res.host, res.token);

        default:
          return;
      }

      if (mode == ConnectMode.restore) {
        await dest.list();
      } else {
        await dest.testWrite();
      }

      final next = await ref
          .read(backupControllerProvider.notifier)
          .onConnected(config, mode);
      writtenDestId = null;
      state = state.copyWith(lastNext: next);
      ref.read(snackbarProvider).show(
        mode == ConnectMode.reauth
            ? l10n.bkCloudSignedInAgain(provider)
            : l10n.bkCloudConnected(provider),
      );
    } on FlutterAppAuthPlatformException catch (e) {
      debugPrint('AppAuth error (${e.code}): ${e.platformErrorDetails}');
      if (writtenDestId != null && mode != ConnectMode.reauth) {
        await secrets.delete(writtenDestId);
      }
      final detail =
          '${e.platformErrorDetails.errorDescription ?? ''} ${e.message ?? ''}';
      if (kind == 'onedrive' &&
          (detail.contains('AADSTS65001') ||
              detail.contains('AADSTS90094') ||
              detail.contains('consent_required') ||
              detail.contains('admin'))) {
        state = state.copyWith(
          errorKey: 'bkCloudOrgApproval',
          errorProvider: provider,
        );
      } else {
        state = state.copyWith(
          errorKey: 'bkCloudSignInFailed',
          errorProvider: provider,
        );
      }
    } on Object catch (e) {
      debugPrint('Cloud connect failed ($kind): $e');
      if (writtenDestId != null && mode != ConnectMode.reauth) {
        await secrets.delete(writtenDestId);
      }
      state = state.copyWith(
        errorKey: 'bkCloudSignInFailed',
        errorProvider: provider,
      );
    } finally {
      state = state.copyWith(clearBusy: true);
    }
  }

  Future<void> reauth(
    String kind,
    String destId,
    AppLocalizations l10n,
  ) async {
    await connect(
      kind,
      ConnectMode.reauth,
      reauthDestId: destId,
      l10n: l10n,
    );
    final key = state.errorKey;
    if (key == null) return;
    final name = state.errorProvider ?? _providerName(kind, l10n);
    final msg = switch (key) {
      'bkCloudNotConfigured' => l10n.bkCloudNotConfigured(name),
      'bkCloudOrgApproval' => l10n.bkCloudOrgApproval,
      _ => l10n.bkCloudSignInFailed(name),
    };
    ref.read(snackbarProvider).show(msg);
    state = state.copyWith(clearError: true);
  }
}

final cloudConnectControllerProvider =
    NotifierProvider<CloudConnectController, CloudConnectState>(
      CloudConnectController.new,
    );
