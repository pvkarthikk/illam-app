import 'dart:async';
import 'dart:convert';

import 'package:nm_flat/core/data/secure/secure_store.dart';

const _controlStoreKey = 'control_store_v1';
const _retentionMs = 90 * 24 * 60 * 60 * 1000;

/// Contact details retained after erasing a home so control ops can still reach family phones.
class DialInfo {
  const DialInfo(this.deviceIds, this.signPubs, this.homeKeysB64);

  const DialInfo.empty()
    : deviceIds = const [],
      signPubs = const {},
      homeKeysB64 = const [];

  factory DialInfo.fromJson(Map<String, Object?> m) => DialInfo(
    [for (final d in m['deviceIds'] as List? ?? const []) d as String],
    {
      for (final e in (m['signPubs'] as Map? ?? const {}).entries)
        e.key as String: e.value as String,
    },
    [for (final k in m['homeKeysB64'] as List? ?? const []) k as String],
  );

  final List<String> deviceIds;
  final Map<String, String> signPubs;
  final List<String> homeKeysB64;

  Map<String, Object?> toJson() => {
    'deviceIds': deviceIds,
    'signPubs': signPubs,
    'homeKeysB64': homeKeysB64,
  };
}

/// Queued outbound `leave` or `deleteHome` membership op awaiting peer ack.
class OutboxEntry {
  const OutboxEntry(
    this.homeId,
    this.opId,
    this.opJson,
    this.addedAt,
    this.acked,
    this.dial,
  );

  factory OutboxEntry.fromJson(Map<String, Object?> m) => OutboxEntry(
    m['homeId'] as String,
    m['opId'] as String,
    m['opJson'] as String,
    (m['addedAt'] as num).toInt(),
    (m['acked'] as bool?) ?? false,
    DialInfo.fromJson(Map<String, Object?>.from(m['dial'] as Map? ?? const {})),
  );

  final String homeId;
  final String opId;
  final String opJson;
  final int addedAt;
  final bool acked;
  final DialInfo dial;

  OutboxEntry copyWith({bool? acked}) => OutboxEntry(
    homeId,
    opId,
    opJson,
    addedAt,
    acked ?? this.acked,
    dial,
  );

  Map<String, Object?> toJson() => {
    'homeId': homeId,
    'opId': opId,
    'opJson': opJson,
    'addedAt': addedAt,
    'acked': acked,
    'dial': dial.toJson(),
  };
}

/// Record of an erased home (`removed`, `deleted`, or `left`) surviving home wipe.
class Tombstone {
  const Tombstone(
    this.homeId,
    this.homeName,
    this.reason,
    this.byName,
    this.opJson,
    this.at,
    this.shown,
    this.dial,
  );

  factory Tombstone.fromJson(Map<String, Object?> m) => Tombstone(
    m['homeId'] as String,
    m['homeName'] as String,
    m['reason'] as String,
    m['byName'] as String?,
    m['opJson'] as String?,
    (m['at'] as num).toInt(),
    (m['shown'] as bool?) ?? false,
    DialInfo.fromJson(Map<String, Object?>.from(m['dial'] as Map? ?? const {})),
  );

  final String homeId;
  final String homeName;
  final String reason;
  final String? byName;
  final String? opJson;
  final int at;
  final bool shown;
  final DialInfo dial;

  Tombstone copyWith({bool? shown}) => Tombstone(
    homeId,
    homeName,
    reason,
    byName,
    opJson,
    at,
    shown ?? this.shown,
    dial,
  );

  Map<String, Object?> toJson() => {
    'homeId': homeId,
    'homeName': homeName,
    'reason': reason,
    'byName': byName,
    'opJson': opJson,
    'at': at,
    'shown': shown,
    'dial': dial.toJson(),
  };
}

/// Persistent store in [SecureStore] surviving local home erasure for 90 days.
class ControlStore {
  ControlStore(this._store, {int Function()? now})
    : _now = now ?? (() => DateTime.now().millisecondsSinceEpoch);

  final SecureStore _store;
  final int Function() _now;
  final StreamController<void> _changes = StreamController<void>.broadcast();
  Future<void> _serial = Future<void>.value();

  Stream<void> get changes => _changes.stream;

  bool _alive(int ts) => _now() - ts <= _retentionMs;

  Future<({List<OutboxEntry> outbox, List<Tombstone> tombstones})> _load() async {
    final raw = await _store.read(_controlStoreKey);
    if (raw == null || raw.isEmpty) {
      return (outbox: <OutboxEntry>[], tombstones: <Tombstone>[]);
    }
    final decoded = jsonDecode(raw) as Map<String, Object?>;
    final outbox = <OutboxEntry>[
      for (final item in decoded['outbox'] as List? ?? const [])
        OutboxEntry.fromJson(Map<String, Object?>.from(item as Map)),
    ].where((e) => _alive(e.addedAt)).toList();
    final tombstones = <Tombstone>[
      for (final item in decoded['tombstones'] as List? ?? const [])
        Tombstone.fromJson(Map<String, Object?>.from(item as Map)),
    ].where((t) => _alive(t.at)).toList();
    return (outbox: outbox, tombstones: tombstones);
  }

  Future<void> _save(
    List<OutboxEntry> outbox,
    List<Tombstone> tombstones,
  ) async {
    await _store.write(
      _controlStoreKey,
      jsonEncode({
        'outbox': [for (final e in outbox) e.toJson()],
        'tombstones': [for (final t in tombstones) t.toJson()],
      }),
    );
    if (!_changes.isClosed) _changes.add(null);
  }

  Future<T> _run<T>(Future<T> Function() fn) {
    final next = _serial.then((_) => fn());
    _serial = next.then((_) {}, onError: (_) {});
    return next;
  }

  Future<void> addOutbox(OutboxEntry entry) => _run(() async {
    final data = await _load();
    final next = [
      for (final e in data.outbox)
        if (e.opId != entry.opId) e,
      entry,
    ];
    await _save(next, data.tombstones);
  });

  Future<void> markAcked(String opId) => _run(() async {
    final data = await _load();
    final next = [
      for (final e in data.outbox)
        e.opId == opId ? e.copyWith(acked: true) : e,
    ];
    await _save(next, data.tombstones);
  });

  Future<List<OutboxEntry>> pendingOutbox(String homeId) => _run(() async {
    final data = await _load();
    return [
      for (final e in data.outbox)
        if (e.homeId == homeId && !e.acked) e,
    ];
  });

  Future<List<OutboxEntry>> allPendingOutbox() => _run(() async {
    final data = await _load();
    return [
      for (final e in data.outbox)
        if (!e.acked) e,
    ];
  });

  Future<void> addTombstone(Tombstone t) => _run(() async {
    final data = await _load();
    final next = [
      for (final item in data.tombstones)
        if (item.homeId != t.homeId) item,
      t,
    ];
    await _save(data.outbox, next);
  });

  Future<List<Tombstone>> unshownTombstones() => _run(() async {
    final data = await _load();
    return [
      for (final t in data.tombstones)
        if (!t.shown) t,
    ];
  });

  Future<void> markShown(String homeId) => _run(() async {
    final data = await _load();
    final next = [
      for (final t in data.tombstones)
        t.homeId == homeId ? t.copyWith(shown: true) : t,
    ];
    await _save(data.outbox, next);
  });

  Future<List<Tombstone>> tombstonesToPass() => _run(() async {
    final data = await _load();
    return [
      for (final t in data.tombstones)
        if (t.reason == 'deleted' && _alive(t.at)) t,
    ];
  });

  Future<void> dispose() => _changes.close();
}
