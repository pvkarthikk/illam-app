import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/http_tools.dart';
import 'package:nm_flat/core/backup/destinations/s3/s3_sigv4.dart';
import 'package:nm_flat/core/backup/file_format.dart';

final _xmlCodeRe = RegExp(r'<Code>([^<]+)</Code>');
final _contentsRe = RegExp(r'<Contents>(.*?)</Contents>', dotAll: true);
final _keyRe = RegExp(r'<Key>(.*?)</Key>', dotAll: true);
final _sizeRe = RegExp(r'<Size>(.*?)</Size>', dotAll: true);
final _lastModRe = RegExp(r'<LastModified>(.*?)</LastModified>', dotAll: true);
final _truncatedRe = RegExp(r'<IsTruncated>\s*true\s*</IsTruncated>');
final _nextTokenRe = RegExp(
  r'<NextContinuationToken>(.*?)</NextContinuationToken>',
  dotAll: true,
);

/// Maps an S3 XML error `<Code>` and HTTP status to a [DestError].
DestError? s3ErrorKind(String? code, int status) {
  switch (code) {
    case 'NoSuchBucket':
      return DestError.bucketNotFound;
    case 'InvalidAccessKeyId':
    case 'SignatureDoesNotMatch':
      return DestError.auth;
    case 'AccessDenied':
      return DestError.noPermission;
    case 'QuotaExceeded':
      return DestError.full;
    case 'AuthorizationHeaderMalformed':
    case 'PermanentRedirect':
      return DestError.bucketNotFound;
    default:
      return statusError(status)?.error;
  }
}

/// Parses an S3 `ListObjectsV2` XML response under prefix `illam/`.
({List<RemoteBackupFile> files, bool truncated, String? nextToken}) parseS3List(
  String xml,
) {
  final files = <RemoteBackupFile>[];
  for (final m in _contentsRe.allMatches(xml)) {
    final block = m.group(1) ?? '';
    final rawKey = _keyRe.firstMatch(block)?.group(1)?.trim() ?? '';
    final name = rawKey.startsWith('illam/')
        ? rawKey.substring('illam/'.length)
        : rawKey;
    if (!backupNameRe.hasMatch(name)) continue;
    final size =
        int.tryParse(_sizeRe.firstMatch(block)?.group(1)?.trim() ?? '') ?? 0;
    final modRaw = _lastModRe.firstMatch(block)?.group(1)?.trim();
    var ms = 0;
    if (modRaw != null && modRaw.isNotEmpty) {
      try {
        ms = DateTime.parse(modRaw).millisecondsSinceEpoch;
      } on FormatException {
        ms = 0;
      }
    }
    files.add(RemoteBackupFile(name, size, ms));
  }
  final truncated = _truncatedRe.hasMatch(xml);
  final nextToken = _nextTokenRe.firstMatch(xml)?.group(1)?.trim();
  return (files: files, truncated: truncated, nextToken: nextToken);
}

/// Backup destination speaking S3 HTTP with AWS SigV4 signatures.
class S3Destination extends BackupDestination {
  S3Destination({
    required this.endpoint,
    required this.region,
    required this.bucket,
    required this.accessKeyId,
    required this.secretKey,
    required this.virtualHost,
    required this.https,
    Dio? dio,
  }) : _dio = dio ?? buildServerDio();

  factory S3Destination.fromSettings(
    Map<String, Object?> s,
    String secret, {
    Dio? dio,
  }) {
    return S3Destination(
      endpoint: s['endpoint'] as String? ?? '',
      region: s['region'] as String? ?? 'us-east-1',
      bucket: s['bucket'] as String? ?? '',
      accessKeyId: s['accessKeyId'] as String? ?? '',
      secretKey: secret,
      virtualHost: s['virtualHost'] as bool? ?? false,
      https: s['https'] as bool? ?? true,
      dio: dio,
    );
  }

  final String endpoint;
  final String region;
  final String bucket;
  final String accessKeyId;
  final String secretKey;
  final bool virtualHost;
  final bool https;
  final Dio _dio;

  @override
  String get kind => 's3';

  static String _key(String name) => 'illam/$name';

  Uri _url(String key) {
    if (virtualHost) {
      return Uri.parse('https://$bucket.$endpoint/$key');
    }
    final scheme = https ? 'https' : 'http';
    return Uri.parse('$scheme://$endpoint/$bucket/$key');
  }

  Uri _bucketRootUrl() {
    if (virtualHost) {
      return Uri.parse('https://$bucket.$endpoint/');
    }
    final scheme = https ? 'https' : 'http';
    return Uri.parse('$scheme://$endpoint/$bucket');
  }

  @visibleForTesting
  Uri debugUrl(String key) => _url(key);

  Future<Response<dynamic>> _send(
    String method,
    Uri url, {
    Uint8List? body,
    ResponseType type = ResponseType.plain,
  }) async {
    final payloadHash = sha256Hex(body ?? const <int>[]);
    final signed = signS3(
      method: method,
      uri: url,
      headers: const {},
      payloadHash: payloadHash,
      accessKey: accessKeyId,
      secretKey: secretKey,
      region: region,
      now: DateTime.now(),
    );
    final headers = <String, Object?>{
      for (final e in signed.headers.entries)
        if (e.key != 'host') e.key: e.value,
      if (body != null) Headers.contentLengthHeader: body.length,
    };

    final Response<dynamic> res;
    try {
      res = await _dio.requestUri<dynamic>(
        url,
        data: body == null ? null : Stream<Uint8List>.value(body),
        options: Options(method: method, headers: headers, responseType: type),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }

    final status = res.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      final rawBody = res.data;
      final bodyText = switch (rawBody) {
        String s => s,
        List<int> b => utf8.decode(b, allowMalformed: true),
        _ => '',
      };
      final code = _xmlCodeRe.firstMatch(bodyText)?.group(1)?.trim();
      throw DestinationException(s3ErrorKind(code, status) ?? DestError.other);
    }
    return res;
  }

  @override
  Future<void> upload(String name, Uint8List bytes) async {
    final url = _url(_key(name));
    await _send('PUT', url, body: bytes);
    final head = await _send('HEAD', url);
    final len = int.tryParse(
      head.headers.value(Headers.contentLengthHeader) ?? '',
    );
    if (len != bytes.length) {
      await delete(name);
      throw const DestinationException(DestError.other);
    }
  }

  @override
  Future<Uint8List> download(String name) async {
    final res = await _send(
      'GET',
      _url(_key(name)),
      type: ResponseType.bytes,
    );
    final raw = res.data;
    if (raw is Uint8List) return raw;
    if (raw is List<int>) return Uint8List.fromList(raw);
    return Uint8List(0);
  }

  @override
  Future<void> delete(String name) async {
    await _send('DELETE', _url(_key(name)));
  }

  @override
  Future<void> testWrite() async {
    final tmp = 'Illam_test_${randomHex(4)}.tmp';
    await _send(
      'PUT',
      _url(_key(tmp)),
      body: Uint8List.fromList(utf8.encode('NMBK test')),
    );
    await delete(tmp);
  }

  @override
  Future<List<RemoteBackupFile>> list() async {
    final all = <RemoteBackupFile>[];
    String? token;
    final root = _bucketRootUrl();
    while (true) {
      final url = root.replace(
        queryParameters: <String, String>{
          'list-type': '2',
          'prefix': 'illam/',
          if (token != null && token.isNotEmpty) 'continuation-token': token,
        },
      );
      final res = await _send('GET', url);
      final page = parseS3List(res.data as String? ?? '');
      all.addAll(page.files);
      if (!page.truncated || page.nextToken == null || page.nextToken!.isEmpty) {
        break;
      }
      token = page.nextToken;
    }
    return all;
  }
}
