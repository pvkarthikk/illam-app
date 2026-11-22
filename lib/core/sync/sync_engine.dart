import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/sync/incoming.dart';
import 'package:nm_flat/core/sync/membership_log.dart';
import 'package:nm_flat/core/sync/net/framed_connection.dart';
import 'package:nm_flat/core/sync/net/lan_sync.dart';
import 'package:nm_flat/core/sync/net/local_ip.dart';
import 'package:nm_flat/core/sync/net/secure_channel.dart';
import 'package:nm_flat/core/sync/session/sync_context.dart';
import 'package:nm_flat/core/sync/session/sync_session.dart';
import 'package:nm_flat/core/sync/sync_store.dart';
import 'package:nm_flat/core/time/clock.dart';

class SyncEngineState {
  const SyncEngineState({
    this.connected = const {},
    this.syncing = false,
    this.wifiTip = false,
    this.port,
  });

  final Set<String> connected;
  final bool syncing;
  final bool wifiTip;
  final int? port;

  SyncEngineState copyWith({
    Set<String>? connected,
    bool? syncing,
    bool? wifiTip,
    int? port,
    bool clearPort = false,
  }) => SyncEngineState(
    connected: connected ?? this.connected,
    syncing: syncing ?? this.syncing,
    wifiTip: wifiTip ?? this.wifiTip,
    port: clearPort ? null : (port ?? this.port),
  );
}

/// Coordinates foreground/background LAN discovery, encrypted sessions, and live op pushes.
class SyncEngine {
  SyncEngine({
    required this.db,
    required this.prefs,
    required this.secure,
    required this.keys,
    required this.membership,
    required this.incoming,
    required this.clock,
    required this.homeId,
  });

  final NestDatabase db;
  final DevicePrefs prefs;
  final SecureStore secure;
  final Future<DeviceKeys> keys;
  final MembershipLog membership;
  final IncomingPipeline incoming;
  final Clock clock;
  final String? homeId;

  final List<SyncSession> _sessions = [];
  final Set<SyncSession> _authed = {};
  final Set<String> _dialling = {};
  final LanSyncService _lan = LanSyncService();
  final StreamController<SyncEngineState> _states =
      StreamController<SyncEngineState>.broadcast();
  final StreamController<void> _synced = StreamController<void>.broadcast();

  SyncEngineState _state = const SyncEngineState();
  bool _started = false;
  bool _disposed = false;
  Timer? _wifiTipTimer;
  Timer? _pushTimer;
  Uint8List? _homeKey;
  DeviceKeys? _resolvedKeys;

  Stream<SyncEngineState> get states => _states.stream;
  Stream<void> get synced => _synced.stream;
  SyncEngineState get state => _state;

  void _emit(SyncEngineState next) {
    if (_disposed || _states.isClosed) return;
    _state = next;
    _states.add(next);
  }

  Future<void> startForeground() async {
    if (_started || _disposed || homeId == null) return;
    final hId = homeId!;
    final home = await (db.select(
      db.homes,
    )..where((h) => h.id.equals(hId))).getSingleOrNull();
    if (home == null) return;

    final rawKey = await secure.read(
      SecureKeys.homeKey(hId, home.homeKeyId ?? 'genesis'),
    );
    if (rawKey == null) return;

    _homeKey = base64Decode(rawKey);
    _resolvedKeys = await keys;
    _started = true;

    final p = await _lan.startServer((s) => unawaited(_acceptSocket(s)));
    _emit(_state.copyWith(port: p));

    final nowUtc = clock.now().toUtc();
    try {
      await _lan.advertise(await lanTag(_homeKey!, nowUtc), p);
    } on Object {
      // mDNS advertisement unavailable in headless environments.
    }
    try {
      await _lan.discover(
        await lanTagsFor(_homeKey!, nowUtc),
        (host, port) => unawaited(_dial(host, port)),
      );
    } on Object {
      // mDNS discovery unavailable in headless environments.
    }

    for (final peer in await SyncStore(db).peers(hId)) {
      if (peer.lastHost != null && peer.lastPort != null) {
        unawaited(_dial(peer.lastHost!, peer.lastPort!));
      }
    }

    _wifiTipTimer?.cancel();
    _wifiTipTimer = Timer(const Duration(seconds: 10), () async {
      if (_disposed || !_started || _state.connected.isNotEmpty) return;
      if (!await onWifi()) return;
      final myDev = _resolvedKeys?.deviceId;
      final activeDevs =
          await (db.select(db.memberDevices)
                ..where((d) => d.homeId.equals(hId) & d.active.equals(true)))
              .get();
      if (activeDevs.any((d) => d.deviceId != myDev) &&
          _state.connected.isEmpty) {
        _emit(_state.copyWith(wifiTip: true));
      }
    });
  }

  Future<void> _acceptSocket(Socket s) async {
    try {
      final ch = await SecureChannel.handshake(
        FramedConnection.socket(s),
        initiator: false,
      );
      await _runSession(ch, dialled: false);
    } on Object {
      s.destroy();
    }
  }

  Future<void> dialForDebug(String host, int port) => _dial(host, port);

  Future<void> _dial(String host, int port) async {
    final myPort = _lan.port;
    if (myPort != null && port == myPort) {
      final myIp = await localWifiIp();
      if (host == '127.0.0.1' ||
          host == 'localhost' ||
          (myIp != null && host == myIp)) {
        return;
      }
    }
    final key = '$host:$port';
    if (_dialling.contains(key)) return;
    _dialling.add(key);
    try {
      final sock = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 5),
      );
      final ch = await SecureChannel.handshake(
        FramedConnection.socket(sock),
        initiator: true,
      );
      await _runSession(ch, dialled: true, host: host, port: port);
    } on Object {
      // Peer unreachable on this candidate address.
    } finally {
      _dialling.remove(key);
    }
  }

  Future<void> _runSession(
    SecureChannel ch, {
    required bool dialled,
    String? host,
    int? port,
  }) async {
    final hId = homeId;
    if (hId == null || _disposed) {
      await ch.close();
      return;
    }
    final k = _resolvedKeys ?? await keys;
    final ctx = DbSyncContext(
      db: db,
      homeId: hId,
      keys: k,
      membership: membership,
      incoming: incoming,
      clock: clock,
      onIngested: onLocalChange,
    );
    late final SyncSession session;
    session = SyncSession(
      ch,
      ctx,
      dialled: dialled,
      onAuthed: (s) => _onAuthed(s, host: host, port: port),
    );
    _sessions.add(session);

    unawaited(
      session.ready.future
          .then((_) async {
            if (_disposed) return;
            if (!_synced.isClosed) _synced.add(null);
            if (prefs.setupIncompleteHomeId == hId) {
              await prefs.setSetupIncompleteHomeId(null);
            }
            await incoming.retryPending(hId, IngestReport());
          })
          .catchError((_) {}),
    );

    try {
      await session.run();
    } finally {
      _sessions.remove(session);
      _authed.remove(session);
      _refreshConnected();
    }
  }

  bool _onAuthed(SyncSession s, {String? host, int? port}) {
    final peerId = s.peerDeviceId;
    final myId = _resolvedKeys?.deviceId;
    if (peerId == null || myId == null || peerId == myId) return false;

    final existing = [
      for (final o in _authed)
        if (o != s && o.peerDeviceId == peerId) o,
    ];
    for (final other in existing) {
      final sDialler = s.dialled ? myId : peerId;
      final oDialler = other.dialled ? myId : peerId;
      if (sDialler.compareTo(oDialler) <= 0) {
        _authed.remove(other);
        unawaited(other.close());
      } else {
        return false;
      }
    }

    _authed.add(s);
    _emit(
      _state.copyWith(
        connected: {
          for (final a in _authed)
            if (a.peerDeviceId != null) a.peerDeviceId!,
        },
        wifiTip: false,
      ),
    );
    unawaited(
      SyncStore(db).upsertSeen(
        peerId,
        homeId!,
        s.dialled ? host : null,
        s.dialled ? port : null,
        clock.nowMs,
      ),
    );
    return true;
  }

  void _refreshConnected() {
    _emit(
      _state.copyWith(
        connected: {
          for (final a in _authed)
            if (a.peerDeviceId != null) a.peerDeviceId!,
        },
      ),
    );
  }

  void onLocalChange() {
    _pushTimer?.cancel();
    _pushTimer = Timer(const Duration(milliseconds: 500), () {
      for (final s in [..._sessions]) {
        unawaited(s.push());
      }
    });
  }

  Future<int> syncNow() async {
    if (homeId == null || _disposed) return 0;
    _emit(_state.copyWith(syncing: true));
    try {
      await startForeground();
      if (_homeKey != null) {
        try {
          await _lan.discover(
            await lanTagsFor(_homeKey!, clock.now().toUtc()),
            (h, p) => unawaited(_dial(h, p)),
          );
        } on Object {
          // Ignore mDNS errors.
        }
      }
      await Future<void>.delayed(const Duration(seconds: 5));
      var completed = 0;
      await Future.wait([
        for (final s in [..._sessions])
          s.ready.future
              .timeout(const Duration(seconds: 10))
              .then((_) => completed++)
              .catchError((_) => 0),
      ]);
      return completed;
    } finally {
      _emit(_state.copyWith(syncing: false));
    }
  }

  Future<void> runOnce({
    Duration budget = const Duration(seconds: 30),
  }) async {
    if (homeId == null) return;
    final hId = homeId!;
    final home = await (db.select(
      db.homes,
    )..where((h) => h.id.equals(hId))).getSingleOrNull();
    if (home == null) return;

    final rawKey = await secure.read(
      SecureKeys.homeKey(hId, home.homeKeyId ?? 'genesis'),
    );
    if (rawKey == null) return;
    _homeKey = base64Decode(rawKey);
    _resolvedKeys = await keys;

    for (final peer in await SyncStore(db).peers(hId)) {
      if (peer.lastHost != null && peer.lastPort != null) {
        unawaited(_dial(peer.lastHost!, peer.lastPort!));
      }
    }
    try {
      await _lan.discover(
        await lanTagsFor(_homeKey!, clock.now().toUtc()),
        (h, p) => unawaited(_dial(h, p)),
      );
    } on Object {
      // Background isolate may not support mDNS platform channels.
    }

    await Future<void>.delayed(const Duration(seconds: 5));
    try {
      await Future.wait([
        for (final s in [..._sessions]) s.ready.future,
      ]).timeout(budget);
    } on Object {
      // Budget expired or session closed.
    }

    for (final s in [..._sessions]) {
      await s.close();
    }
    await _lan.stop();
  }

  Future<void> stopForeground() async {
    _started = false;
    _wifiTipTimer?.cancel();
    _pushTimer?.cancel();
    for (final s in [..._sessions]) {
      await s.close();
    }
    _authed.clear();
    await _lan.stop();
    _emit(
      _state.copyWith(
        connected: const {},
        wifiTip: false,
        clearPort: true,
      ),
    );
  }

  Future<void> dispose() async {
    _disposed = true;
    await stopForeground();
    await _states.close();
    await _synced.close();
  }
}
