import 'dart:async';

import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/crypto/home_key_ring.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/sync/incoming.dart';
import 'package:nm_flat/core/sync/membership_log.dart';
import 'package:nm_flat/core/sync/remote/firebase_rest_client.dart';
import 'package:nm_flat/core/sync/remote/remote_sync_config.dart';
import 'package:nm_flat/core/sync/remote/remote_sync_transfer.dart';
import 'package:nm_flat/core/time/clock.dart';

class RemoteSyncState {
  const RemoteSyncState({
    this.enabled = false,
    this.configured = false,
    this.syncing = false,
    this.lastSyncAt,
    this.lastError,
    this.lastPushed = 0,
    this.lastPulled = 0,
  });

  final bool enabled;
  final bool configured;
  final bool syncing;
  final int? lastSyncAt;
  final String? lastError;
  final int lastPushed;
  final int lastPulled;

  bool get isActive => enabled && configured;

  RemoteSyncState copyWith({
    bool? enabled,
    bool? configured,
    bool? syncing,
    int? lastSyncAt,
    String? lastError,
    bool clearError = false,
    int? lastPushed,
    int? lastPulled,
  }) => RemoteSyncState(
    enabled: enabled ?? this.enabled,
    configured: configured ?? this.configured,
    syncing: syncing ?? this.syncing,
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    lastError: clearError ? null : (lastError ?? this.lastError),
    lastPushed: lastPushed ?? this.lastPushed,
    lastPulled: lastPulled ?? this.lastPulled,
  );
}

class RemoteSyncOutcome {
  const RemoteSyncOutcome({
    this.ran = false,
    this.pushed = 0,
    this.pulled = 0,
    this.error,
  });

  final bool ran;
  final int pushed;
  final int pulled;
  final RemoteSyncError? error;
}

/// Relays encrypted household op batches through a user-configured Firebase project.
///
/// Strictly inert unless [RemoteSyncConfig.isActive] is `true`.
class RemoteSyncEngine {
  RemoteSyncEngine({
    required this.db,
    required this.prefs,
    required this.secure,
    required this.keys,
    required this.membership,
    required this.incoming,
    required this.clock,
    required this.homeId,
    required this.configStore,
    required this.client,
    this.pollInterval = const Duration(seconds: 45),
    this.pushDebounce = const Duration(seconds: 3),
  }) {
    _configSub = configStore.changes.listen(_onConfigChanged);
    unawaited(_refreshConfigState());
  }

  final NestDatabase db;
  final DevicePrefs prefs;
  final SecureStore secure;
  final Future<DeviceKeys> keys;
  final MembershipLog membership;
  final IncomingPipeline incoming;
  final Clock clock;
  final String? homeId;
  final RemoteSyncConfigStore configStore;
  final FirebaseRestClient client;
  final Duration pollInterval;
  final Duration pushDebounce;

  final _states = StreamController<RemoteSyncState>.broadcast();
  final _synced = StreamController<void>.broadcast();
  StreamSubscription<String>? _configSub;
  Timer? _pollTimer;
  Timer? _pushTimer;
  Future<void> _chain = Future<void>.value();
  RemoteSyncState _state = const RemoteSyncState();
  bool _foreground = false;
  bool _disposed = false;

  Stream<RemoteSyncState> get states => _states.stream;
  Stream<void> get synced => _synced.stream;
  RemoteSyncState get state => _state;

  HomeKeyRing get _ring => HomeKeyRing(secure);

  void _emit(RemoteSyncState next) {
    if (_disposed || _states.isClosed) return;
    _state = next;
    _states.add(next);
  }

  void _onConfigChanged(String changedHomeId) {
    if (_disposed || changedHomeId != homeId) return;
    unawaited(_refreshConfigState(syncIfNewlyActive: true));
  }

  Future<void> _refreshConfigState({bool syncIfNewlyActive = false}) async {
    final hId = homeId;
    if (_disposed || hId == null) {
      _emit(const RemoteSyncState());
      _pollTimer?.cancel();
      _pollTimer = null;
      return;
    }
    final wasActive = _state.isActive;
    final cfg = await configStore.load(hId);
    if (_disposed) return;
    _emit(
      _state.copyWith(
        enabled: cfg.enabled,
        configured: cfg.isConfigured,
        lastSyncAt: cfg.lastSyncAt,
        lastError: cfg.lastError,
        clearError: cfg.lastError == null,
      ),
    );
    if (cfg.isActive && _foreground) {
      _ensurePollTimer();
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
      _pushTimer?.cancel();
      _pushTimer = null;
    }
    if (syncIfNewlyActive && cfg.isActive && !wasActive) {
      unawaited(syncNow());
    }
  }

  void _ensurePollTimer() {
    if (!_foreground || _pollTimer != null || _disposed) return;
    _pollTimer = Timer.periodic(pollInterval, (_) => unawaited(syncNow()));
  }

  Future<void> startForeground() async {
    if (_disposed || homeId == null) return;
    _foreground = true;
    await _refreshConfigState();
    if (_state.isActive && !_disposed) {
      _ensurePollTimer();
      unawaited(syncNow());
    }
  }

  Future<void> stopForeground() async {
    _foreground = false;
    _pollTimer?.cancel();
    _pollTimer = null;
    _pushTimer?.cancel();
    _pushTimer = null;
  }

  void onLocalChange() {
    if (_disposed || homeId == null || !_state.isActive) return;
    _pushTimer?.cancel();
    _pushTimer = Timer(pushDebounce, () {
      if (!_disposed && _state.isActive) unawaited(syncNow());
    });
  }

  Future<T> _serialize<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _chain = _chain
        .catchError((_) {})
        .then((_) async {
          try {
            completer.complete(await action());
          } catch (e, st) {
            completer.completeError(e, st);
          }
        });
    return completer.future;
  }

  /// Runs one pull-then-push remote sync cycle if Remote Sync is enabled and configured.
  Future<RemoteSyncOutcome> syncNow() {
    if (_disposed || homeId == null) {
      return Future.value(const RemoteSyncOutcome(ran: false));
    }
    return _serialize(_syncNowInner);
  }

  Future<RemoteSyncOutcome> _syncNowInner() async {
    final hId = homeId;
    if (_disposed || hId == null) return const RemoteSyncOutcome(ran: false);

    var cfg = await configStore.load(hId);
    if (!cfg.isActive) {
      _emit(
        _state.copyWith(
          enabled: cfg.enabled,
          configured: cfg.isConfigured,
          syncing: false,
          lastSyncAt: cfg.lastSyncAt,
          lastError: cfg.lastError,
          clearError: cfg.lastError == null,
        ),
      );
      return const RemoteSyncOutcome(ran: false);
    }

    if ((await _ring.all(hId)).isEmpty) {
      return const RemoteSyncOutcome(ran: false);
    }

    _emit(_state.copyWith(enabled: true, configured: true, syncing: true));

    var pulled = 0;
    var pushed = 0;
    try {
      final token = await client.ensureAuthToken(cfg, nowMs: clock.nowMs);
      cfg = cfg.copyWith(token: token);
      await configStore.save(hId, cfg);

      final myDeviceId = (await keys).deviceId;

      final pullRes = await pullRemoteChannels(
        db: db,
        ring: _ring,
        incoming: incoming,
        client: client,
        configStore: configStore,
        clock: clock,
        homeId: hId,
        myDeviceId: myDeviceId,
        initialConfig: cfg,
      );
      cfg = pullRes.config;
      pulled = pullRes.pulled;

      final pushRes = await pushRemotePending(
        db: db,
        ring: _ring,
        membership: membership,
        client: client,
        configStore: configStore,
        clock: clock,
        homeId: hId,
        myDeviceId: myDeviceId,
        initialConfig: cfg,
      );
      cfg = pushRes.config;
      pushed = pushRes.pushed;

      final nowMs = clock.nowMs;
      cfg = cfg.copyWith(lastSyncAt: nowMs, clearLastError: true);
      await configStore.save(hId, cfg);

      _emit(
        RemoteSyncState(
          enabled: cfg.enabled,
          configured: cfg.isConfigured,
          syncing: false,
          lastSyncAt: nowMs,
          lastPushed: pushed,
          lastPulled: pulled,
        ),
      );
      if ((pulled > 0 || pushed > 0) && !_disposed && !_synced.isClosed) {
        _synced.add(null);
      }
      return RemoteSyncOutcome(ran: true, pushed: pushed, pulled: pulled);
    } on RemoteSyncException catch (e) {
      cfg = cfg.copyWith(lastError: e.error.name);
      await configStore.save(hId, cfg);
      _emit(
        _state.copyWith(
          enabled: cfg.enabled,
          configured: cfg.isConfigured,
          syncing: false,
          lastError: e.error.name,
        ),
      );
      return RemoteSyncOutcome(
        ran: true,
        pushed: pushed,
        pulled: pulled,
        error: e.error,
      );
    } on Object {
      cfg = cfg.copyWith(lastError: RemoteSyncError.other.name);
      await configStore.save(hId, cfg);
      _emit(
        _state.copyWith(
          enabled: cfg.enabled,
          configured: cfg.isConfigured,
          syncing: false,
          lastError: RemoteSyncError.other.name,
        ),
      );
      return RemoteSyncOutcome(
        ran: true,
        pushed: pushed,
        pulled: pulled,
        error: RemoteSyncError.other,
      );
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await stopForeground();
    await _configSub?.cancel();
    await _states.close();
    await _synced.close();
  }
}
