import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/http_tools.dart';
import 'package:nm_flat/core/backup/destinations/webdav/propfind_parser.dart';

const _propfindBody =
    '<?xml version="1.0" encoding="utf-8"?>'
    '<d:propfind xmlns:d="DAV:">'
    '<d:prop><d:getcontentlength/><d:getlastmodified/><d:resourcetype/></d:prop>'
    '</d:propfind>';

/// Minimal WebDAV HTTP client operating inside a single remote folder.
class WebDavClient {
  WebDavClient(this.dio, this.folderUrl, this.user, this.password);

  final Dio dio;
  final Uri folderUrl;
  final String user;
  final String password;

  String get _authHeader =>
      'Basic ${base64Encode(utf8.encode('$user:$password'))}';

  Uri _fileUrl(String name) => folderUrl.resolve(Uri.encodeComponent(name));

  Future<Response<dynamic>> _send(
    String method,
    Uri uri, {
    Object? data,
    Map<String, Object?>? headers,
    ResponseType? responseType,
  }) async {
    try {
      return await dio.requestUri<dynamic>(
        uri,
        data: data,
        options: Options(
          method: method,
          headers: <String, Object?>{'Authorization': _authHeader, ...?headers},
          responseType: responseType,
        ),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Uri _parentFolder(Uri u) {
    final segs = u.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segs.isEmpty) return u;
    segs.removeLast();
    final path = segs.isEmpty ? '/' : '/${segs.join('/')}/';
    return u.replace(path: path);
  }

  Future<void> mkcol(Uri u, [int depth = 0]) async {
    final res = await _send('MKCOL', u);
    final status = res.statusCode ?? 0;
    if (status == 201 || status == 405) return;
    if (status == 409 && depth < 3) {
      final parent = _parentFolder(u);
      if (parent != u) {
        await mkcol(parent, depth + 1);
        final retry = await _send('MKCOL', u);
        final retryStatus = retry.statusCode ?? 0;
        if (retryStatus == 201 || retryStatus == 405) return;
        throw statusError(retryStatus) ??
            const DestinationException(DestError.other);
      }
    }
    throw statusError(status) ?? const DestinationException(DestError.other);
  }

  Future<void> put(String name, Uint8List bytes) async {
    final res = await _send(
      'PUT',
      _fileUrl(name),
      data: Stream<Uint8List>.value(bytes),
      headers: <String, Object?>{
        Headers.contentTypeHeader: 'application/octet-stream',
        Headers.contentLengthHeader: bytes.length,
      },
    );
    final status = res.statusCode ?? 0;
    if (status == 201 || status == 204) return;
    throw statusError(status) ?? const DestinationException(DestError.other);
  }

  Future<void> move(String from, String to) async {
    final res = await _send(
      'MOVE',
      _fileUrl(from),
      headers: <String, Object?>{
        'Destination': _fileUrl(to).toString(),
        'Overwrite': 'T',
      },
    );
    final status = res.statusCode ?? 0;
    if (status == 201 || status == 204) return;
    throw statusError(status) ?? const DestinationException(DestError.other);
  }

  Future<List<DavEntry>> propfind() async {
    final res = await _send(
      'PROPFIND',
      folderUrl,
      data: _propfindBody,
      headers: const <String, Object?>{
        'Depth': '1',
        Headers.contentTypeHeader: 'application/xml',
      },
      responseType: ResponseType.plain,
    );
    final status = res.statusCode ?? 0;
    if (status == 404) return const [];
    if (status == 207) {
      return parsePropfind(res.data as String? ?? '');
    }
    throw statusError(status) ?? const DestinationException(DestError.other);
  }

  Future<Uint8List> get(String name) async {
    final res = await _send(
      'GET',
      _fileUrl(name),
      responseType: ResponseType.bytes,
    );
    final status = res.statusCode ?? 0;
    if (status == 200) {
      final raw = res.data;
      if (raw is Uint8List) return raw;
      if (raw is List<int>) return Uint8List.fromList(raw);
      return Uint8List(0);
    }
    if (status == 404) throw const DestinationException(DestError.notFound);
    throw statusError(status) ?? const DestinationException(DestError.other);
  }

  Future<void> delete(String name) async {
    final res = await _send('DELETE', _fileUrl(name));
    final status = res.statusCode ?? 0;
    if (status == 204 || status == 200 || status == 404) return;
    throw statusError(status) ?? const DestinationException(DestError.other);
  }
}
