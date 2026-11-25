import 'dart:async';
import 'dart:convert';

import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/domain/remote_sync_config_parser.dart';

/// Per-channel pull cursor storing the last seen server timestamp and tie-breaker IDs.
class ChannelCursor {
  ChannelCursor({this.lastPulledAt, List<String>? seenIds})
    : seenIds = seenIds ?? [];

  factory ChannelCursor.fromJson(Map<String, Object?> j) => ChannelCursor(
    lastPulledAt: j['lastPulledAt'] as String?,
    seenIds: [for (final s in j['seenIds'] as List? ?? const []) s as String],
  );

  final String? lastPulledAt;
  final List<String> seenIds;

  Map<String, Object?> toJson() => {
    'lastPulledAt': lastPulledAt,
    'seenIds': seenIds.length > 200
        ? seenIds.sublist(seenIds.length - 200)
        : seenIds,
  };
}

/// Cached Firebase Anonymous Auth token and refresh metadata.
class FirebaseAuthToken {
  const FirebaseAuthToken({
    required this.idToken,
    required this.refreshToken,
    required this.uid,
    required this.expiresAtMs,
  });

  factory FirebaseAuthToken.fromJson(Map<String, Object?> j) =>
      FirebaseAuthToken(
        idToken: (j['idToken'] as String?) ?? '',
        refreshToken: (j['refreshToken'] as String?) ?? '',
        uid: (j['uid'] as String?) ?? '',
        expiresAtMs: (j['expiresAtMs'] as num?)?.toInt() ?? 0,
      );

  final String idToken;
  final String refreshToken;
  final String uid;
  final int expiresAtMs;

  bool get isEmpty => idToken.isEmpty || uid.isEmpty;

  /// Considers a token expired 2 minutes early to avoid mid-request 401s.
  bool isExpiredAt(int nowMs) => isEmpty || nowMs >= expiresAtMs - 120000;

  Map<String, Object?> toJson() => {
    'idToken': idToken,
    'refreshToken': refreshToken,
    'uid': uid,
    'expiresAtMs': expiresAtMs,
  };
}

/// Device-local Bring Your Own Firebase remote sync configuration and sync watermarks.
class RemoteSyncConfig {
  RemoteSyncConfig({
    this.enabled = false,
    this.projectId = '',
    this.apiKey = '',
    this.databaseId = kDefaultFirestoreDatabaseId,
    this.token,
    Map<String, int>? uploadedVector,
    Set<String>? uploadedMemberOpIds,
    Map<String, ChannelCursor>? channelCursors,
    this.lastSyncAt,
    this.lastError,
  }) : uploadedVector = uploadedVector ?? {},
       uploadedMemberOpIds = uploadedMemberOpIds ?? {},
       channelCursors = channelCursors ?? {};

  factory RemoteSyncConfig.empty() => RemoteSyncConfig();

  factory RemoteSyncConfig.fromJson(Map<String, Object?> j) {
    final tokenRaw = j['token'] as Map?;
    final vecRaw = j['uploadedVector'] as Map? ?? const {};
    final cursorsRaw = j['channelCursors'] as Map? ?? const {};
    return RemoteSyncConfig(
      enabled: (j['enabled'] as bool?) ?? false,
      projectId: (j['projectId'] as String?) ?? '',
      apiKey: (j['apiKey'] as String?) ?? '',
      databaseId: normalizeDatabaseId((j['databaseId'] as String?) ?? ''),
      token: tokenRaw == null
          ? null
          : FirebaseAuthToken.fromJson(Map<String, Object?>.from(tokenRaw)),
      uploadedVector: {
        for (final e in vecRaw.entries)
          e.key as String: (e.value as num).toInt(),
      },
      uploadedMemberOpIds: {
        for (final s in j['uploadedMemberOpIds'] as List? ?? const [])
          s as String,
      },
      channelCursors: {
        for (final e in cursorsRaw.entries)
          e.key as String: ChannelCursor.fromJson(
            Map<String, Object?>.from(e.value as Map),
          ),
      },
      lastSyncAt: (j['lastSyncAt'] as num?)?.toInt(),
      lastError: j['lastError'] as String?,
    );
  }

  final bool enabled;
  final String projectId;
  final String apiKey;
  final String databaseId;
  final FirebaseAuthToken? token;
  final Map<String, int> uploadedVector;
  final Set<String> uploadedMemberOpIds;
  final Map<String, ChannelCursor> channelCursors;
  final int? lastSyncAt;
  final String? lastError;

  bool get isConfigured => projectId.isNotEmpty && apiKey.isNotEmpty;
  bool get isActive => enabled && isConfigured;

  ParsedFirebaseConfig? get parsedCredentials => isConfigured
      ? ParsedFirebaseConfig(
          projectId: projectId,
          apiKey: apiKey,
          databaseId: databaseId,
        )
      : null;

  RemoteSyncConfig copyWith({
    bool? enabled,
    String? projectId,
    String? apiKey,
    String? databaseId,
    FirebaseAuthToken? token,
    bool clearToken = false,
    Map<String, int>? uploadedVector,
    Set<String>? uploadedMemberOpIds,
    Map<String, ChannelCursor>? channelCursors,
    int? lastSyncAt,
    bool clearLastSyncAt = false,
    String? lastError,
    bool clearLastError = false,
  }) => RemoteSyncConfig(
    enabled: enabled ?? this.enabled,
    projectId: projectId ?? this.projectId,
    apiKey: apiKey ?? this.apiKey,
    databaseId: databaseId ?? this.databaseId,
    token: clearToken ? null : (token ?? this.token),
    uploadedVector: uploadedVector ?? Map<String, int>.from(this.uploadedVector),
    uploadedMemberOpIds:
        uploadedMemberOpIds ?? Set<String>.from(this.uploadedMemberOpIds),
    channelCursors:
        channelCursors ?? Map<String, ChannelCursor>.from(this.channelCursors),
    lastSyncAt: clearLastSyncAt ? null : (lastSyncAt ?? this.lastSyncAt),
    lastError: clearLastError ? null : (lastError ?? this.lastError),
  );

  /// Updates credentials, resetting cursors and uploaded watermarks when target project changes.
  RemoteSyncConfig withCredentials(ParsedFirebaseConfig cfg, {bool? enabled}) {
    final nextProject = cfg.projectId.trim();
    final nextKey = cfg.apiKey.trim();
    final nextDb = normalizeDatabaseId(cfg.databaseId);
    final changed =
        nextProject != projectId || nextKey != apiKey || nextDb != databaseId;
    return RemoteSyncConfig(
      enabled: enabled ?? this.enabled,
      projectId: nextProject,
      apiKey: nextKey,
      databaseId: nextDb,
      token: changed ? null : token,
      uploadedVector: changed ? {} : Map<String, int>.from(uploadedVector),
      uploadedMemberOpIds: changed ? {} : Set<String>.from(uploadedMemberOpIds),
      channelCursors: changed
          ? {}
          : Map<String, ChannelCursor>.from(channelCursors),
      lastSyncAt: changed ? null : lastSyncAt,
      lastError: null,
    );
  }

  Map<String, Object?> toJson() => {
    'enabled': enabled,
    'projectId': projectId,
    'apiKey': apiKey,
    'databaseId': databaseId,
    'token': token?.toJson(),
    'uploadedVector': uploadedVector,
    'uploadedMemberOpIds': uploadedMemberOpIds.toList(),
    'channelCursors': {
      for (final e in channelCursors.entries) e.key: e.value.toJson(),
    },
    'lastSyncAt': lastSyncAt,
    'lastError': lastError,
  };
}

/// Reads and writes per-home [RemoteSyncConfig] in [SecureStore].
class RemoteSyncConfigStore {
  RemoteSyncConfigStore(this.store);

  final SecureStore store;
  final _changes = StreamController<String>.broadcast();

  Stream<String> get changes => _changes.stream;

  static String _key(String homeId) => 'remote_sync_$homeId';

  Future<RemoteSyncConfig> load(String homeId) async {
    final raw = await store.read(_key(homeId));
    if (raw == null || raw.isEmpty) return RemoteSyncConfig.empty();
    try {
      return RemoteSyncConfig.fromJson(
        Map<String, Object?>.from(jsonDecode(raw) as Map),
      );
    } on Object {
      return RemoteSyncConfig.empty();
    }
  }

  Future<void> save(String homeId, RemoteSyncConfig config) async {
    await store.write(_key(homeId), jsonEncode(config.toJson()));
    if (!_changes.isClosed) _changes.add(homeId);
  }

  Future<void> delete(String homeId) async {
    await store.delete(_key(homeId));
    if (!_changes.isClosed) _changes.add(homeId);
  }

  Future<void> dispose() => _changes.close();
}
