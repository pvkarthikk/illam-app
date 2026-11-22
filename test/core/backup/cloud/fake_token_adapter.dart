import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class RecordedRequest {
  const RecordedRequest(this.options, this.body);

  final RequestOptions options;
  final String body;
}

/// Fake [HttpClientAdapter] queueing JSON responses and recording requests.
class FakeAdapter implements HttpClientAdapter {
  final Queue<(int, String)> replies = Queue();
  final List<RecordedRequest> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bb = BytesBuilder(copy: false);
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        bb.add(chunk);
      }
    }
    final bytes = bb.takeBytes();
    final decoded = bytes.isNotEmpty
        ? utf8.decode(bytes, allowMalformed: true)
        : (options.data is String ? options.data as String : '');
    requests.add(RecordedRequest(options, decoded));

    final (status, jsonBody) = replies.removeFirst();
    return ResponseBody.fromString(
      jsonBody,
      status,
      headers: const {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
