import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:nm_flat/core/sync/remote/remote_sync_config.dart';

enum RemoteSyncError {
  invalidApiKey,
  anonAuthDisabled,
  permissionDenied,
  databaseNotFound,
  quotaExceeded,
  network,
  other,
}

class RemoteSyncException implements Exception {
  const RemoteSyncException(this.error, [this.detail]);

  final RemoteSyncError error;
  final String? detail;

  @override
  String toString() => 'RemoteSyncException($error, $detail)';
}

/// Parsed batch document returned by Firestore `runQuery`.
class RemoteBatchDoc {
  const RemoteBatchDoc({
    required this.docId,
    required this.sender,
    required this.keyId,
    required this.payloadB64,
    required this.createdAt,
  });

  final String docId;
  final String sender;
  final String keyId;
  final String payloadB64;
  final String? createdAt;
}

/// Pure-Dart REST client for Firebase Anonymous Auth and Cloud Firestore v1.
///
/// Uses `package:dio/dio.dart` directly (no `dart:io` or native Firebase SDKs)
/// so both Android (F-Droid compatible) and web builds work identically.
class FirebaseRestClient {
  FirebaseRestClient({Dio? dio}) : _dio = dio ?? _defaultDio();

  final Dio _dio;

  static Dio _defaultDio() => Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (_) => true,
    ),
  );

  String _dbRoot(RemoteSyncConfig c) =>
      'projects/${c.projectId}/databases/${c.databaseId}';

  String _firestoreBase(RemoteSyncConfig c) =>
      'https://firestore.googleapis.com/v1/${_dbRoot(c)}/documents';

  String _batchDocPath(
    RemoteSyncConfig c,
    String channelId,
    String batchId,
  ) => '${_dbRoot(c)}/documents/illam_channels/$channelId/batches/$batchId';

  Map<String, Object?> _asJsonMap(Object? data) {
    if (data is Map) return Map<String, Object?>.from(data);
    if (data is String && data.isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map) return Map<String, Object?>.from(decoded);
    }
    return const {};
  }

  List<Object?> _asJsonList(Object? data) {
    if (data is List) return data;
    if (data is String && data.isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is List) return decoded;
    }
    return const [];
  }

  String _extractErrorMessage(Object? data) {
    final map = _asJsonMap(data);
    final err = map['error'];
    if (err is Map) {
      final msg = err['message'] as String?;
      if (msg != null && msg.isNotEmpty) return msg;
      final status = err['status'] as String?;
      if (status != null && status.isNotEmpty) return status;
    }
    if (map['error'] is String) return map['error'] as String;
    final list = _asJsonList(data);
    if (list.isNotEmpty && list.first is Map) {
      final errObj = (list.first as Map)['error'];
      if (errObj is Map) {
        return (errObj['message'] as String?) ??
            (errObj['status'] as String?) ??
            '';
      }
    }
    return '';
  }

  RemoteSyncException _mapAuthFailure(int status, Object? data) {
    final msg = _extractErrorMessage(data);
    if (msg.contains('API_KEY_INVALID') ||
        msg.contains('API key not valid') ||
        msg.contains('INVALID_API_KEY')) {
      return RemoteSyncException(RemoteSyncError.invalidApiKey, msg);
    }
    if (msg.contains('OPERATION_NOT_ALLOWED') ||
        msg.contains('ADMIN_RESTRICTED_OPERATION')) {
      return RemoteSyncException(RemoteSyncError.anonAuthDisabled, msg);
    }
    if (status == 429 || msg.contains('QUOTA_EXCEEDED')) {
      return RemoteSyncException(RemoteSyncError.quotaExceeded, msg);
    }
    if (status == 400 && msg.contains('INVALID_ARGUMENT')) {
      return RemoteSyncException(RemoteSyncError.invalidApiKey, msg);
    }
    return RemoteSyncException(RemoteSyncError.other, '$status: $msg');
  }

  RemoteSyncException _mapFirestoreFailure(int status, Object? data) {
    final msg = _extractErrorMessage(data);
    if (status == 403 || msg.contains('PERMISSION_DENIED')) {
      return RemoteSyncException(RemoteSyncError.permissionDenied, msg);
    }
    if (status == 404 || msg.contains('NOT_FOUND')) {
      return RemoteSyncException(RemoteSyncError.databaseNotFound, msg);
    }
    if (status == 429 || msg.contains('RESOURCE_EXHAUSTED')) {
      return RemoteSyncException(RemoteSyncError.quotaExceeded, msg);
    }
    if (status == 400 && msg.contains('API_KEY_INVALID')) {
      return RemoteSyncException(RemoteSyncError.invalidApiKey, msg);
    }
    return RemoteSyncException(RemoteSyncError.other, '$status: $msg');
  }

  Future<Response<dynamic>> _postJson(
    String url,
    Object data, {
    Map<String, String>? headers,
  }) async {
    try {
      return await _dio.post<dynamic>(
        url,
        data: data,
        options: Options(
          headers: {'Content-Type': 'application/json', ...?headers},
        ),
      );
    } on DioException catch (e) {
      throw RemoteSyncException(RemoteSyncError.network, e.message);
    }
  }

  /// Ensures a valid Firebase Anonymous Auth token for [config].
  Future<FirebaseAuthToken> ensureAuthToken(
    RemoteSyncConfig config, {
    required int nowMs,
    bool forceRefresh = false,
  }) async {
    final cached = config.token;
    if (!forceRefresh && cached != null && !cached.isExpiredAt(nowMs)) {
      return cached;
    }

    if (cached != null && cached.refreshToken.isNotEmpty) {
      final refreshUrl =
          'https://securetoken.googleapis.com/v1/token?key=${Uri.encodeQueryComponent(config.apiKey)}';
      final resp = await _postJson(refreshUrl, {
        'grant_type': 'refresh_token',
        'refresh_token': cached.refreshToken,
      });
      final code = resp.statusCode ?? 0;
      if (code >= 200 && code < 300) {
        final m = _asJsonMap(resp.data);
        final idToken = m['id_token'] as String? ?? '';
        final refresh = m['refresh_token'] as String? ?? cached.refreshToken;
        final uid = m['user_id'] as String? ?? cached.uid;
        final expiresSec =
            int.tryParse(m['expires_in']?.toString() ?? '') ?? 3600;
        if (idToken.isNotEmpty && uid.isNotEmpty) {
          return FirebaseAuthToken(
            idToken: idToken,
            refreshToken: refresh,
            uid: uid,
            expiresAtMs: nowMs + expiresSec * 1000,
          );
        }
      } else {
        final err = _mapAuthFailure(code, resp.data);
        if (err.error != RemoteSyncError.other) {
          throw err;
        }
        // Expired/revoked refresh token: fall through to fresh anonymous sign-in.
      }
    }

    final signUpUrl =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${Uri.encodeQueryComponent(config.apiKey)}';
    final resp = await _postJson(signUpUrl, {'returnSecureToken': true});
    final code = resp.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      throw _mapAuthFailure(code, resp.data);
    }
    final m = _asJsonMap(resp.data);
    final idToken = m['idToken'] as String? ?? '';
    final refreshToken = m['refreshToken'] as String? ?? '';
    final uid = m['localId'] as String? ?? '';
    final expiresSec =
        int.tryParse(m['expiresIn']?.toString() ?? '') ?? 3600;
    if (idToken.isEmpty || uid.isEmpty) {
      throw const RemoteSyncException(
        RemoteSyncError.other,
        'Incomplete auth response',
      );
    }
    return FirebaseAuthToken(
      idToken: idToken,
      refreshToken: refreshToken,
      uid: uid,
      expiresAtMs: nowMs + expiresSec * 1000,
    );
  }

  /// Verifies Anonymous Auth, Firestore database access, and security rules end-to-end.
  Future<FirebaseAuthToken> testConnection(
    RemoteSyncConfig config, {
    required String channelId,
    required int nowMs,
  }) async {
    final token = await ensureAuthToken(config, nowMs: nowMs);
    final headers = {'Authorization': 'Bearer ${token.idToken}'};
    final probeUrl =
        '${_firestoreBase(config)}/illam_channels/$channelId/probes/${token.uid}';

    try {
      final writeResp = await _dio.patch<dynamic>(
        probeUrl,
        data: {
          'fields': {
            'ok': {'booleanValue': true},
          },
        },
        options: Options(headers: {'Content-Type': 'application/json', ...headers}),
      );
      final wc = writeResp.statusCode ?? 0;
      if (wc < 200 || wc >= 300) {
        throw _mapFirestoreFailure(wc, writeResp.data);
      }

      final getResp = await _dio.get<dynamic>(
        probeUrl,
        options: Options(headers: headers),
      );
      final gc = getResp.statusCode ?? 0;
      if (gc < 200 || gc >= 300) {
        throw _mapFirestoreFailure(gc, getResp.data);
      }

      try {
        await _dio.delete<dynamic>(probeUrl, options: Options(headers: headers));
      } on Object {
        // Best-effort cleanup of probe document.
      }
    } on DioException catch (e) {
      throw RemoteSyncException(RemoteSyncError.network, e.message);
    }

    await queryBatches(
      config: config,
      token: token,
      channelId: channelId,
      limit: 1,
      nowMs: nowMs,
    );
    return token;
  }

  Future<({Response<dynamic> resp, FirebaseAuthToken token})> _authedPostJson({
    required RemoteSyncConfig config,
    required FirebaseAuthToken token,
    required String url,
    required Object data,
    required int nowMs,
  }) async {
    var active = token;
    var resp = await _postJson(
      url,
      data,
      headers: {'Authorization': 'Bearer ${active.idToken}'},
    );
    if (resp.statusCode == 401) {
      active = await ensureAuthToken(
        config.copyWith(token: active),
        nowMs: nowMs,
        forceRefresh: true,
      );
      resp = await _postJson(
        url,
        data,
        headers: {'Authorization': 'Bearer ${active.idToken}'},
      );
    }
    final code = resp.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      throw _mapFirestoreFailure(code, resp.data);
    }
    return (resp: resp, token: active);
  }

  /// Commits a single immutable encrypted batch document using Firestore `REQUEST_TIME`.
  Future<({String? createdAt, FirebaseAuthToken token})> commitBatch({
    required RemoteSyncConfig config,
    required FirebaseAuthToken token,
    required String channelId,
    required String batchId,
    required String sender,
    required String keyId,
    required String payloadB64,
    required DateTime expiresAtUtc,
    required int nowMs,
  }) async {
    final url = '${_firestoreBase(config)}:commit';
    final docName = _batchDocPath(config, channelId, batchId);
    final res = await _authedPostJson(
      config: config,
      token: token,
      url: url,
      nowMs: nowMs,
      data: {
        'writes': [
          {
            'update': {
              'name': docName,
              'fields': {
                'v': {'integerValue': '1'},
                'sender': {'stringValue': sender},
                'keyId': {'stringValue': keyId},
                'payload': {'stringValue': payloadB64},
                'expiresAt': {'timestampValue': expiresAtUtc.toIso8601String()},
              },
            },
            'currentDocument': {'exists': false},
            'updateTransforms': [
              {'fieldPath': 'createdAt', 'setToServerValue': 'REQUEST_TIME'},
            ],
          },
        ],
      },
    );
    final map = _asJsonMap(res.resp.data);
    final results = map['writeResults'] as List?;
    String? createdAt;
    if (results != null && results.isNotEmpty && results.first is Map) {
      final first = results.first as Map;
      createdAt = first['updateTime'] as String?;
      final tr = first['transformResults'] as List?;
      if (tr != null && tr.isNotEmpty && tr.first is Map) {
        createdAt = ((tr.first as Map)['timestampValue'] as String?) ?? createdAt;
      }
    }
    return (createdAt: createdAt, token: res.token);
  }

  /// Queries batches in [channelId] ordered by server `createdAt` ascending.
  Future<({List<RemoteBatchDoc> docs, FirebaseAuthToken token})> queryBatches({
    required RemoteSyncConfig config,
    required FirebaseAuthToken token,
    required String channelId,
    String? sinceTimestamp,
    int limit = 50,
    required int nowMs,
  }) async {
    final url = '${_firestoreBase(config)}/illam_channels/$channelId:runQuery';
    final query = <String, Object?>{
      'from': [
        {'collectionId': 'batches'},
      ],
      if (sinceTimestamp != null && sinceTimestamp.isNotEmpty)
        'where': {
          'fieldFilter': {
            'field': {'fieldPath': 'createdAt'},
            'op': 'GREATER_THAN_OR_EQUAL',
            'value': {'timestampValue': sinceTimestamp},
          },
        },
      'orderBy': [
        {
          'field': {'fieldPath': 'createdAt'},
          'direction': 'ASCENDING',
        },
      ],
      'limit': limit,
    };

    final res = await _authedPostJson(
      config: config,
      token: token,
      url: url,
      data: {'structuredQuery': query},
      nowMs: nowMs,
    );

    final list = _asJsonList(res.resp.data);
    final docs = <RemoteBatchDoc>[];
    for (final entry in list) {
      if (entry is! Map) continue;
      final doc = entry['document'];
      if (doc is! Map) continue; // Skips empty {readTime: ...} sentinel rows.
      final name = doc['name'] as String? ?? '';
      final docId = name.isEmpty ? '' : name.split('/').last;
      final fields = doc['fields'];
      if (docId.isEmpty || fields is! Map) continue;
      final sender = _stringField(fields['sender']);
      final keyId = _stringField(fields['keyId']);
      final payload = _stringField(fields['payload']);
      final createdAt = _timestampField(fields['createdAt']);
      if (sender == null || keyId == null || payload == null) continue;
      docs.add(
        RemoteBatchDoc(
          docId: docId,
          sender: sender,
          keyId: keyId,
          payloadB64: payload,
          createdAt: createdAt,
        ),
      );
    }
    return (docs: docs, token: res.token);
  }

  static String? _stringField(Object? raw) =>
      raw is Map ? raw['stringValue'] as String? : null;

  static String? _timestampField(Object? raw) =>
      raw is Map ? raw['timestampValue'] as String? : null;
}
