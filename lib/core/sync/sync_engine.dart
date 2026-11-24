import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';

import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/crypto/home_key_ring.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/repo/home_eraser.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/sync/control_store.dart';
import 'package:nm_flat/core/sync/incoming.dart';
import 'package:nm_flat/core/sync/membership_log.dart';
import 'package:nm_flat/core/sync/net/byte_link.dart';
import 'package:nm_flat/core/sync/net/framed_connection.dart';
import 'package:nm_flat/core/sync/net/lan_sync.dart';
import 'package:nm_flat/core/sync/net/local_ip.dart';
import 'package:nm_flat/core/sync/net/secure_channel.dart';
import 'package:nm_flat/core/sync/net/tcp_byte_link.dart';
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
    this.controlStore,
    this.homeEraser,
  });

  final NestDatabase db;
  final DevicePrefs prefs;
  final SecureStore secure;
  final Future<DeviceKeys> keys;
  final MembershipLog membership;
  final IncomingPipeline incoming;
  final Clock clock;
  final String? homeId;
  final ControlStore? controlStore;
  final HomeEraser? homeEraser;

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
  Timer? _redialTimer;
  Timer? _pushTimer;
  DeviceKeys? _resolvedKeys;
  Future<void> _lifecycle = Future<void>.value();

  Stream<SyncEngineState> get states => _states.stream;
  Stream<void> get synced => _synced.stream;
  SyncEngineState get state => _state;

  HomeKeyRing get _ring => HomeKeyRing(secure);

  Future<Set<String>> _allLanTags(
    String hId,
    DateTime nowUtc, {
    List<HomeKey>? homeKeys,
  }) async {
    final list = homeKeys ?? await _ring.all(hId);
    final tags = <String>{};
    for (final k in list) {
      tags.addAll(await lanTagsFor(k.bytes, nowUtc));
    }
    return tags;
  }

  void _emit(SyncEngineState next) {
    if (_disposed || _states.isClosed) return;
    _state = next;
    _states.add(next);
  }

  Future<void> startForeground() {
    final next = _lifecycle.then((_) => _startForeground());
    _lifecycle = next.then((_) {}, onError: (_) {});
    return next;
  }

  Future<void> _startForeground() async {
    if (_started || _disposed || homeId == null) return;
    final hId = homeId!;
    final home = await (db.select(
      db.homes,
    )..where((h) => h.id.equals(hId))).getSingleOrNull();
    if (home == null) return;

    final homeKeys = await _ring.all(hId);
    if (homeKeys.isEmpty) return;
    final currentKey = homeKeys.first;

    _resolvedKeys = await keys;
    _started = true;

    final p = await _lan.startServer(
      (s) => unawaited(runSession(TcpByteLink(s), initiator: false)),
    );
    _emit(_state.copyWith(port: p));

    final nowUtc = clock.now().toUtc();
    try {
      await _lan.advertise(await lanTag(currentKey.bytes, nowUtc), p);
    } on Object {
      // mDNS advertisement unavailable in headless environments.
    }
    try {
      await _lan.discover(
        await _allLanTags(hId, nowUtc, homeKeys: homeKeys),
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

    _redialTimer?.cancel();
    _redialTimer = Timer.periodic(const Duration(minutes: 2), (_) async {
      if (_disposed || !_started) return;
      for (final peer in await SyncStore(db).peers(hId)) {
        if (_disposed || !_started) return;
        if (peer.lastHost != null &&
            peer.lastPort != null &&
            !_state.connected.contains(peer.deviceId)) {
          unawaited(_dial(peer.lastHost!, peer.lastPort!));
        }
      }
    });
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
      await runSession(
        TcpByteLink(sock),
        initiator: true,
        host: host,
        port: port,
      );
    } on Object {
      // Peer unreachable on this candidate address.
    } finally {
      _dialling.remove(key);
    }
  }

  /// Runs a full encrypted sync session over any bidirectional [ByteLink].
  Future<void> runSession(
    ByteLink link, {
    required bool initiator,
    String? host,
    int? port,
  }) async {
    FramedConnection? conn;
    SyncSession? session;
    try {
      final hId = homeId;
      if (hId == null || _disposed) return;
      conn = FramedConnection.link(link);
      final ch = await SecureChannel.handshake(conn, initiator: initiator);
      if (_disposed) return;
      final k = _resolvedKeys ?? await keys;
      final ctx = DbSyncContext(
        db: db,
        homeId: hId,
        keys: k,
        membership: membership,
        incoming: incoming,
        clock: clock,
        prefs: prefs,
        controlStore: controlStore,
        homeEraser: homeEraser,
        onIngested: onLocalChange,
      );
      final created = SyncSession(
        ch,
        ctx,
        dialled: initiator,
        onAuthed: (s) => _onAuthed(s, host: host, port: port),
      );
      session = created;
      _sessions.add(created);

      unawaited(
        created.ready.future
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

      await created.run();
    } on Object {
      // Handshake or session transport error.
    } finally {
      if (session != null) {
        _sessions.remove(session);
        _authed.remove(session);
        _refreshConnected();
      }
      if (conn != null) {
        await conn.close();
      } else {
        await link.close();
      }
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
    final hId = homeId!;
    _emit(_state.copyWith(syncing: true));
    try {
      await startForeground();
      final tags = await _allLanTags(hId, clock.now().toUtc());
      if (tags.isNotEmpty) {
        try {
          await _lan.discover(tags, (h, p) => unawaited(_dial(h, p)));
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

    final tags = await _allLanTags(hId, clock.now().toUtc());
    if (tags.isEmpty) return;
    _resolvedKeys = await keys;

    for (final peer in await SyncStore(db).peers(hId)) {
      if (peer.lastHost != null && peer.lastPort != null) {
        unawaited(_dial(peer.lastHost!, peer.lastPort!));
      }
    }
    try {
      await _lan.discover(tags, (h, p) => unawaited(_dial(h, p)));
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

  /// Sends `bye` to and closes every open session whose peer device id is in [deviceIds].
  void closeSessionsWith(Set<String> deviceIds) {
    if (deviceIds.isEmpty) return;
    for (final s in [..._sessions]) {
      final peer = s.peerDeviceId;
      if (peer != null && deviceIds.contains(peer)) {
        unawaited(s.close());
      }
    }
  }

  Future<void> stopForeground() {
    final next = _lifecycle.then((_) => _stopForeground());
    _lifecycle = next.then((_) {}, onError: (_) {});
    return next;
  }

  Future<void> _stopForeground() async {
    _started = false;
    _wifiTipTimer?.cancel();
    _redialTimer?.cancel();
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
