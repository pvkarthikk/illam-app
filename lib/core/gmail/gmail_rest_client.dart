import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:nm_flat/core/backup/cloud/oauth_tokens.dart';
import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/domain/invoice/gmail_oauth_parser.dart';

/// Error categories raised by [GmailRestClient].
enum GmailApiErrorKind {
  unauthorized,
  forbiddenOrApiDisabled,
  notFound,
  rateLimited,
  network,
  badResponse,
}

class GmailApiException implements Exception {
  const GmailApiException(this.kind, [this.detail, this.statusCode]);

  final GmailApiErrorKind kind;
  final String? detail;
  final int? statusCode;

  @override
  String toString() =>
      'GmailApiException($kind, status=$statusCode, detail=$detail)';
}

/// Reference to a PDF attachment inside a Gmail MIME payload.
class GmailPdfAttachmentRef {
  const GmailPdfAttachmentRef({
    required this.filename,
    this.attachmentId,
    this.inlineDataB64Url,
    this.sizeBytes = 0,
  });

  final String filename;
  final String? attachmentId;
  final String? inlineDataB64Url;
  final int sizeBytes;
}

/// Decoded contents of one Gmail message fetched via `format=full`.
class GmailFetchedMessage {
  const GmailFetchedMessage({
    required this.id,
    required this.internalDateMs,
    this.fromEmail,
    this.subject,
    this.htmlBody,
    this.plainBody,
    this.pdfAttachments = const [],
  });

  final String id;
  final int internalDateMs;
  final String? fromEmail;
  final String? subject;
  final String? htmlBody;
  final String? plainBody;
  final List<GmailPdfAttachmentRef> pdfAttachments;

  /// Converts [internalDateMs] into local `YYYY-MM-DD`.
  String get localDateIso {
    final dt = DateTime.fromMillisecondsSinceEpoch(internalDateMs);
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$mm-$dd';
  }
}

typedef ClockMs = int Function();

/// Thin Gmail API v1 + Google OAuth2 client over `dio`.
class GmailRestClient {
  GmailRestClient({Dio? dio, ClockMs? nowMs})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(seconds: 20),
              ),
            ),
        _nowMs = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  static const _tokenUrl = 'https://oauth2.googleapis.com/token';
  static const _revokeUrl = 'https://oauth2.googleapis.com/revoke';
  static const _gmailBase = 'https://gmail.googleapis.com/gmail/v1/users/me';

  final Dio _dio;
  final ClockMs _nowMs;

  /// Exchanges an authorization code + PKCE verifier for access/refresh tokens.
  Future<OAuthTokens> exchangeAuthCode({
    required GmailOAuthCredentials credentials,
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) async {
    final res = await _postForm(_tokenUrl, {
      'client_id': credentials.clientId,
      'client_secret': credentials.clientSecret,
      'code': code,
      'code_verifier': codeVerifier,
      'redirect_uri': redirectUri,
      'grant_type': 'authorization_code',
    });
    return _parseTokenResponse(res);
  }

  /// Refreshes an expired or near-expiry [OAuthTokens] instance.
  Future<OAuthTokens> refreshTokens({
    required GmailOAuthCredentials credentials,
    required OAuthTokens current,
  }) async {
    final refresh = current.refreshToken;
    if (refresh == null || refresh.isEmpty) {
      throw const GmailApiException(
        GmailApiErrorKind.unauthorized,
        'Missing refresh token',
      );
    }
    final res = await _postForm(_tokenUrl, {
      'client_id': credentials.clientId,
      'client_secret': credentials.clientSecret,
      'refresh_token': refresh,
      'grant_type': 'refresh_token',
    });
    return _parseTokenResponse(res, fallbackRefreshToken: refresh);
  }

  /// Best-effort token revocation when disconnecting Gmail.
  Future<void> revokeToken(String token) async {
    if (token.isEmpty) return;
    try {
      await _dio.post<Object?>(
        _revokeUrl,
        data: {'token': token},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioException {
      // Ignore network/revocation failures when clearing local credentials.
    }
  }

  /// Reads the connected user's primary Gmail address.
  Future<String> fetchProfileEmail(String accessToken) async {
    final data = await _getJson('$_gmailBase/profile', accessToken);
    final email = data['emailAddress'] as String?;
    if (email == null || email.trim().isEmpty) {
      throw const GmailApiException(
        GmailApiErrorKind.badResponse,
        'Missing emailAddress in profile response',
      );
    }
    return email.trim();
  }

  /// Lists matching Gmail message IDs for [query].
  Future<({List<String> ids, String? nextPageToken})> listMessageIds(
    String accessToken, {
    required String query,
    int maxResults = 25,
    String? pageToken,
  }) async {
    final data = await _getJson(
      '$_gmailBase/messages',
      accessToken,
      queryParameters: {
        'q': query,
        'maxResults': maxResults,
        if (pageToken != null && pageToken.isNotEmpty) 'pageToken': pageToken,
      },
    );
    final rawList = data['messages'] as List? ?? const [];
    final ids = <String>[];
    for (final item in rawList) {
      if (item is Map) {
        final id = item['id'] as String?;
        if (id != null && id.isNotEmpty) ids.add(id);
      }
    }
    final nextToken = data['nextPageToken'] as String?;
    return (ids: ids, nextPageToken: nextToken);
  }

  /// Fetches a full MIME message and extracts headers, bodies, and PDF refs.
  Future<GmailFetchedMessage> fetchMessage(
    String accessToken,
    String messageId,
  ) async {
    final data = await _getJson(
      '$_gmailBase/messages/$messageId',
      accessToken,
      queryParameters: const {'format': 'full'},
    );
    final internalMs =
        int.tryParse(data['internalDate']?.toString() ?? '') ?? _nowMs();
    final payload = data['payload'];
    final headers = <String, String>{};
    final htmlParts = <String>[];
    final plainParts = <String>[];
    final pdfs = <GmailPdfAttachmentRef>[];

    if (payload is Map) {
      final rawHeaders = payload['headers'] as List? ?? const [];
      for (final h in rawHeaders) {
        if (h is Map) {
          final name = (h['name'] as String?)?.toLowerCase();
          final val = h['value'] as String?;
          if (name != null && val != null) {
            headers[name] = val;
          }
        }
      }
      _walkMimePart(
        Map<String, Object?>.from(payload),
        htmlParts: htmlParts,
        plainParts: plainParts,
        pdfs: pdfs,
      );
    }

    return GmailFetchedMessage(
      id: (data['id'] as String?) ?? messageId,
      internalDateMs: internalMs,
      fromEmail: headers['from'],
      subject: headers['subject'],
      htmlBody: htmlParts.isEmpty ? null : htmlParts.join('\n'),
      plainBody: plainParts.isEmpty ? null : plainParts.join('\n'),
      pdfAttachments: pdfs,
    );
  }

  /// Downloads attachment bytes (or decodes inline base64url data).
  Future<Uint8List> fetchAttachmentBytes(
    String accessToken,
    String messageId,
    GmailPdfAttachmentRef ref,
  ) async {
    final inline = ref.inlineDataB64Url;
    if (inline != null && inline.isNotEmpty) {
      return _decodeB64UrlSafely(inline);
    }
    final attId = ref.attachmentId;
    if (attId == null || attId.isEmpty) return Uint8List(0);

    final data = await _getJson(
      '$_gmailBase/messages/$messageId/attachments/$attId',
      accessToken,
    );
    final encoded = data['data'] as String?;
    if (encoded == null || encoded.isEmpty) return Uint8List(0);
    return _decodeB64UrlSafely(encoded);
  }

  void _walkMimePart(
    Map<String, Object?> part, {
    required List<String> htmlParts,
    required List<String> plainParts,
    required List<GmailPdfAttachmentRef> pdfs,
  }) {
    final mimeType = ((part['mimeType'] as String?) ?? '').toLowerCase();
    final filename = ((part['filename'] as String?) ?? '').trim();
    final body = part['body'] is Map
        ? Map<String, Object?>.from(part['body'] as Map)
        : null;
    final bodyData = body?['data'] as String?;
    final attachmentId = body?['attachmentId'] as String?;
    final sizeBytes = (body?['size'] as num?)?.toInt() ?? 0;

    final isPdf =
        mimeType == 'application/pdf' ||
        filename.toLowerCase().endsWith('.pdf');
    if (isPdf && (attachmentId != null || bodyData != null)) {
      pdfs.add(
        GmailPdfAttachmentRef(
          filename: filename.isEmpty ? 'invoice.pdf' : filename,
          attachmentId: attachmentId,
          inlineDataB64Url: bodyData,
          sizeBytes: sizeBytes,
        ),
      );
    } else if (bodyData != null && bodyData.isNotEmpty) {
      final decoded = utf8.decode(
        _decodeB64UrlSafely(bodyData),
        allowMalformed: true,
      );
      if (mimeType == 'text/html') {
        htmlParts.add(decoded);
      } else if (mimeType == 'text/plain' || mimeType.isEmpty) {
        plainParts.add(decoded);
      }
    }

    final nested = part['parts'] as List? ?? const [];
    for (final child in nested) {
      if (child is Map) {
        _walkMimePart(
          Map<String, Object?>.from(child),
          htmlParts: htmlParts,
          plainParts: plainParts,
          pdfs: pdfs,
        );
      }
    }
  }

  Uint8List _decodeB64UrlSafely(String encoded) {
    final compact = encoded.replaceAll(RegExp(r'\s+'), '');
    return unb64url(compact);
  }

  OAuthTokens _parseTokenResponse(
    Map<String, Object?> json, {
    String? fallbackRefreshToken,
  }) {
    final accessToken = (json['access_token'] as String?)?.trim() ?? '';
    if (accessToken.isEmpty) {
      throw const GmailApiException(
        GmailApiErrorKind.badResponse,
        'Missing access_token in OAuth response',
      );
    }
    final expiresInSec = (json['expires_in'] as num?)?.toInt() ?? 3600;
    final refreshToken =
        (json['refresh_token'] as String?)?.trim() ?? fallbackRefreshToken;
    return OAuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAtMs: _nowMs() + expiresInSec * 1000,
    );
  }

  Future<Map<String, Object?>> _postForm(
    String url,
    Map<String, String> fields,
  ) async {
    try {
      final res = await _dio.post<Object?>(
        url,
        data: fields,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (_) => true,
        ),
      );
      return _unwrapJsonResponse(res);
    } on DioException catch (e) {
      throw GmailApiException(GmailApiErrorKind.network, e.message);
    }
  }

  Future<Map<String, Object?>> _getJson(
    String url,
    String accessToken, {
    Map<String, Object?>? queryParameters,
  }) async {
    try {
      final res = await _dio.get<Object?>(
        url,
        queryParameters: queryParameters,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          validateStatus: (_) => true,
        ),
      );
      return _unwrapJsonResponse(res);
    } on DioException catch (e) {
      throw GmailApiException(GmailApiErrorKind.network, e.message);
    }
  }

  Map<String, Object?> _unwrapJsonResponse(Response<Object?> res) {
    final status = res.statusCode ?? 0;
    final raw = res.data;
    final map = raw is Map
        ? Map<String, Object?>.from(raw)
        : raw is String && raw.trim().startsWith('{')
        ? Map<String, Object?>.from(jsonDecode(raw) as Map)
        : <String, Object?>{};

    if (status >= 200 && status < 300) return map;

    final errDetail = _extractErrorDetail(map) ?? res.statusMessage;
    if (status == 401 || _isInvalidGrant(map)) {
      throw GmailApiException(
        GmailApiErrorKind.unauthorized,
        errDetail,
        status,
      );
    }
    if (status == 403) {
      throw GmailApiException(
        GmailApiErrorKind.forbiddenOrApiDisabled,
        errDetail,
        status,
      );
    }
    if (status == 404) {
      throw GmailApiException(GmailApiErrorKind.notFound, errDetail, status);
    }
    if (status == 429) {
      throw GmailApiException(GmailApiErrorKind.rateLimited, errDetail, status);
    }
    throw GmailApiException(GmailApiErrorKind.badResponse, errDetail, status);
  }

  String? _extractErrorDetail(Map<String, Object?> map) {
    final err = map['error'];
    if (err is String) {
      final desc = map['error_description'] as String?;
      return desc != null && desc.isNotEmpty ? '$err: $desc' : err;
    }
    if (err is Map) {
      final msg = err['message'] as String?;
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return null;
  }

  bool _isInvalidGrant(Map<String, Object?> map) =>
      map['error'] == 'invalid_grant' || map['error'] == 'invalid_client';
}
