import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/crypto/home_key_ring.dart';
import 'package:nm_flat/core/domain/remote_sync_config_parser.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/remote/firebase_rest_client.dart';
import 'package:nm_flat/core/sync/remote/remote_sync_crypto.dart';
import 'package:nm_flat/core/sync/remote/remote_sync_engine.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Maps a stored [RemoteSyncError] code to a localized message.
String remoteSyncErrorText(AppLocalizations l10n, String code) => switch (code) {
  'invalidApiKey' => l10n.remoteSyncErrInvalidApiKey,
  'anonAuthDisabled' => l10n.remoteSyncErrAnonDisabled,
  'permissionDenied' => l10n.remoteSyncErrPermissionDenied,
  'databaseNotFound' => l10n.remoteSyncErrDatabaseNotFound,
  'quotaExceeded' => l10n.remoteSyncErrQuota,
  'network' => l10n.remoteSyncErrNetwork,
  'noHomeKey' => l10n.remoteSyncNoHomeKey,
  _ => l10n.remoteSyncErrOther,
};

class RemoteSyncUiState {
  const RemoteSyncUiState({
    this.testing = false,
    this.saving = false,
    this.testOk = false,
    this.testErrorCode,
  });

  final bool testing;
  final bool saving;
  final bool testOk;
  final String? testErrorCode;

  RemoteSyncUiState copyWith({
    bool? testing,
    bool? saving,
    bool? testOk,
    String? testErrorCode,
    bool clearTestError = false,
  }) => RemoteSyncUiState(
    testing: testing ?? this.testing,
    saving: saving ?? this.saving,
    testOk: testOk ?? this.testOk,
    testErrorCode: clearTestError
        ? null
        : (testErrorCode ?? this.testErrorCode),
  );
}

class RemoteSyncController extends Notifier<RemoteSyncUiState> {
  @override
  RemoteSyncUiState build() {
    ref.watch(currentHomeIdProvider);
    return const RemoteSyncUiState();
  }

  String? get _homeId =>
      ref.read(currentHomeIdProvider).value ??
      ref.read(prefsProvider).currentHomeId;

  Future<void> setEnabled(bool enabled) async {
    final homeId = _homeId;
    if (homeId == null) return;
    final store = ref.read(remoteSyncConfigStoreProvider);
    final current = await store.load(homeId);
    state = const RemoteSyncUiState();
    await store.save(
      homeId,
      current.copyWith(enabled: enabled, clearLastError: !enabled),
    );
  }

  void clearTestStatus() {
    if (state.testOk || state.testErrorCode != null) {
      state = state.copyWith(testOk: false, clearTestError: true);
    }
  }

  Future<bool> testConnection(ParsedFirebaseConfig cfg) async {
    final homeId = _homeId;
    if (homeId == null) return false;

    state = state.copyWith(testing: true, testOk: false, clearTestError: true);
    try {
      final ringKey = await ref.read(homeKeyRingProvider).current(homeId);
      if (ringKey == null) {
        state = state.copyWith(testing: false, testErrorCode: 'noHomeKey');
        return false;
      }

      final channelId = await deriveRemoteChannelId(ringKey.bytes, homeId);
      final current = await ref.read(remoteSyncConfigStoreProvider).load(homeId);
      final candidate = current.withCredentials(cfg, enabled: true);
      final token = await ref.read(firebaseRestClientProvider).testConnection(
        candidate,
        channelId: channelId,
        nowMs: ref.read(clockProvider).nowMs,
      );

      if (current.parsedCredentials == cfg) {
        await ref
            .read(remoteSyncConfigStoreProvider)
            .save(homeId, current.copyWith(token: token, clearLastError: true));
      }

      state = state.copyWith(testing: false, testOk: true);
      return true;
    } on RemoteSyncException catch (e) {
      state = state.copyWith(testing: false, testErrorCode: e.error.name);
      return false;
    } on Object {
      state = state.copyWith(testing: false, testErrorCode: 'other');
      return false;
    }
  }

  Future<void> saveConfig(ParsedFirebaseConfig cfg) async {
    final homeId = _homeId;
    if (homeId == null) return;
    state = state.copyWith(saving: true, clearTestError: true);
    try {
      final store = ref.read(remoteSyncConfigStoreProvider);
      final current = await store.load(homeId);
      await store.save(homeId, current.withCredentials(cfg, enabled: true));
    } finally {
      state = state.copyWith(saving: false);
    }
  }

  Future<RemoteSyncOutcome> syncNow() =>
      ref.read(remoteSyncEngineProvider).syncNow();

  Future<void> clearConfig() async {
    final homeId = _homeId;
    if (homeId == null) return;
    state = const RemoteSyncUiState();
    await ref.read(remoteSyncConfigStoreProvider).delete(homeId);
  }
}

final remoteSyncControllerProvider =
    NotifierProvider<RemoteSyncController, RemoteSyncUiState>(
      RemoteSyncController.new,
    );
