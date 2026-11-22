import 'dart:convert';
import 'dart:io' show HttpDate;
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// In-memory fake WebDAV server [HttpClientAdapter] for unit tests.
class FakeWebDavAdapter implements HttpClientAdapter {
  final Map<String, Uint8List> files = {};
  int? forceStatus;

  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<Uint8List>? body,
    Future<void>? cancelFuture,
  ) async {
    if (forceStatus != null) {
      return ResponseBody.fromBytes(
        const <int>[],
        forceStatus!,
        headers: const {
          Headers.contentTypeHeader: ['application/xml'],
        },
      );
    }

    final segs = o.uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final name = segs.isEmpty ? '' : Uri.decodeComponent(segs.last);

    final bb = BytesBuilder(copy: false);
    if (body != null) {
      await for (final chunk in body) {
        bb.add(chunk);
      }
    }
    final reqBytes = bb.takeBytes();

    switch (o.method.toUpperCase()) {
      case 'MKCOL':
        return _xmlReply(const <int>[], 201);
      case 'PUT':
        files[name] = reqBytes;
        return _xmlReply(const <int>[], 201);
      case 'MOVE':
        final destHeader = o.headers['Destination']?.toString() ?? '';
        final destUri = Uri.parse(destHeader);
        final destSegs = destUri.pathSegments
            .where((s) => s.isNotEmpty)
            .toList();
        final destName = destSegs.isEmpty
            ? ''
            : Uri.decodeComponent(destSegs.last);
        final moved = files.remove(name);
        if (moved == null) return _xmlReply(const <int>[], 404);
        files[destName] = moved;
        return _xmlReply(const <int>[], 201);
      case 'PROPFIND':
        final now = HttpDate.format(DateTime.now().toUtc());
        final xml = StringBuffer()
          ..write('<?xml version="1.0" encoding="utf-8"?>')
          ..write('<d:multistatus xmlns:d="DAV:">')
          ..write('<d:response>')
          ..write('<d:href>${o.uri.path}</d:href>')
          ..write(
            '<d:propstat><d:prop><d:resourcetype><d:collection/></d:resourcetype></d:prop>'
            '<d:status>HTTP/1.1 200 OK</d:status></d:propstat>',
          )
          ..write('</d:response>');
        for (final entry in files.entries) {
          final encoded = Uri.encodeComponent(entry.key);
          xml
            ..write('<d:response>')
            ..write('<d:href>${o.uri.path}$encoded</d:href>')
            ..write('<d:propstat><d:prop>')
            ..write('<d:getcontentlength>${entry.value.length}</d:getcontentlength>')
            ..write('<d:getlastmodified>$now</d:getlastmodified>')
            ..write('<d:resourcetype/>')
            ..write('</d:prop><d:status>HTTP/1.1 200 OK</d:status></d:propstat>')
            ..write('</d:response>');
        }
        xml.write('</d:multistatus>');
        return _xmlReply(utf8.encode(xml.toString()), 207);
      case 'GET':
        final data = files[name];
        if (data == null) return _xmlReply(const <int>[], 404);
        return _xmlReply(data, 200);
      case 'DELETE':
        files.remove(name);
        return _xmlReply(const <int>[], 204);
      default:
        return _xmlReply(const <int>[], 405);
    }
  }

  ResponseBody _xmlReply(List<int> bytes, int status) => ResponseBody.fromBytes(
    bytes,
    status,
    headers: const {
      Headers.contentTypeHeader: ['application/xml'],
    },
  );

  @override
  void close({bool force = false}) {}
}
