import 'dart:collection';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/backup/destinations/http_tools.dart';
import 'package:nm_flat/core/backup/destinations/webdav/nextcloud_login.dart';

class _QueuedJsonAdapter implements HttpClientAdapter {
  final Queue<(int, String)> replies = Queue();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
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

void main() {
  test('davFolder encodes userId and ends with Illam/', () {
    expect(
      NextcloudLogin.davFolder(
        Uri.parse('https://c.example.com/'),
        'anand@home',
      ).toString(),
      'https://c.example.com/remote.php/dav/files/anand%40home/Illam/',
    );
  });

  test('start parses login, token, and poll endpoint', () async {
    final adapter = _QueuedJsonAdapter()
      ..replies.add((
        200,
        '{"poll":{"token":"t1","endpoint":"https://c.example.com/login/v2/poll"},"login":"https://c.example.com/login/v2/flow/abc"}',
      ));
    final dio = buildServerDio()..httpClientAdapter = adapter;
    final client = NextcloudLogin(dio);

    final started = await client.start(Uri.parse('https://c.example.com/'));
    expect(started.token, 't1');
    expect(
      started.endpoint,
      Uri.parse('https://c.example.com/login/v2/poll'),
    );
    expect(
      started.login,
      Uri.parse('https://c.example.com/login/v2/flow/abc'),
    );
  });

  test('pollOnce returns null on 404', () async {
    final adapter = _QueuedJsonAdapter()..replies.add((404, '{}'));
    final dio = buildServerDio()..httpClientAdapter = adapter;
    final client = NextcloudLogin(dio);

    final polled = await client.pollOnce(
      Uri.parse('https://c.example.com/login/v2/poll'),
      't1',
    );
    expect(polled, isNull);
  });

  test('pollOnce returns credentials on 200', () async {
    final adapter = _QueuedJsonAdapter()
      ..replies.add((
        200,
        '{"server":"https://c.example.com","loginName":"anand","appPassword":"xyz"}',
      ));
    final dio = buildServerDio()..httpClientAdapter = adapter;
    final client = NextcloudLogin(dio);

    final polled = await client.pollOnce(
      Uri.parse('https://c.example.com/login/v2/poll'),
      't1',
    );
    expect(
      polled,
      (server: 'https://c.example.com', loginName: 'anand', appPassword: 'xyz'),
    );
  });
}
