import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:nm_flat/core/backup/cloud/oauth_tokens.dart';
import 'package:nm_flat/core/backup/destination_secrets.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/http_tools.dart';

/// Manages OAuth 2.0 access tokens and refresh flow in foreground or background isolates.
class TokenKeeper {
  TokenKeeper(
    this.dio,
    this.secrets,
    this.destId,
    this.provider, {
    this.nowMs,
  });

  final Dio dio;
  final DestinationSecrets secrets;
  final String destId;
  final OAuthProvider provider;
  final int Function()? nowMs;

  int _now() => nowMs?.call() ?? DateTime.now().millisecondsSinceEpoch;

  Future<OAuthTokens> _load() async {
    final raw = await secrets.read(destId);
    if (raw == null || raw.isEmpty) {
      throw const DestinationException(DestError.auth);
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        throw const DestinationException(DestError.auth);
      }
      final tokens = OAuthTokens.fromJson(Map<String, Object?>.from(decoded));
      if (tokens.accessToken.isEmpty) {
        throw const DestinationException(DestError.auth);
      }
      return tokens;
    } on DestinationException {
      rethrow;
    } on Object {
      throw const DestinationException(DestError.auth);
    }
  }

  Future<String> accessToken() async {
    final tokens = await _load();
    if (tokens.expiresSoon(_now())) {
      final refreshed = await refresh(tokens);
      return refreshed.accessToken;
    }
    return tokens.accessToken;
  }

  Future<OAuthTokens> refresh([OAuthTokens? old]) async {
    final cur = old ?? await _load();
    final rt = cur.refreshToken;
    if (rt == null || rt.isEmpty) {
      throw const DestinationException(DestError.auth);
    }

    final body = <String, String>{
      'grant_type': 'refresh_token',
      'refresh_token': rt,
      'client_id': provider.clientId(),
      if (provider.scopeOnRefresh) 'scope': provider.scopes.join(' '),
    };

    final Response<dynamic> res;
    try {
      res = await dio.postUri<dynamic>(
        provider.tokenEndpoint,
        data: body,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }

    final status = res.statusCode ?? 0;
    if (status == 400 || status == 401) {
      throw const DestinationException(DestError.auth);
    }
    final err = statusError(status);
    if (err != null) throw err;

    final raw = res.data;
    final decoded = raw is String ? jsonDecode(raw) : raw;
    if (decoded is! Map) {
      throw const DestinationException(DestError.other);
    }
    final map = Map<String, Object?>.from(decoded);
    final newAccess = map['access_token'] as String?;
    if (newAccess == null || newAccess.isEmpty) {
      throw const DestinationException(DestError.auth);
    }
    final newRefresh = map['refresh_token'] as String?;
    final expiresIn = (map['expires_in'] as num?)?.toInt() ?? 3600;
    final updated = OAuthTokens(
      accessToken: newAccess,
      refreshToken: (newRefresh != null && newRefresh.isNotEmpty)
          ? newRefresh
          : cur.refreshToken,
      expiresAtMs: _now() + expiresIn * 1000,
    );
    await secrets.write(destId, jsonEncode(updated.toJson()));
    return updated;
  }

  Future<Response<T>> authed<T>(
    Future<Response<T>> Function(String token) call,
  ) async {
    final token = await accessToken();
    final Response<T> first;
    try {
      first = await call(token);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
    if (first.statusCode != 401) return first;

    final refreshed = await refresh();
    final Response<T> second;
    try {
      second = await call(refreshed.accessToken);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
    if (second.statusCode == 401) {
      throw const DestinationException(DestError.auth);
    }
    return second;
  }
}
