import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/sync/remote/firebase_rest_client.dart';
import 'package:nm_flat/core/sync/remote/remote_sync_config.dart';

import '../../backup/cloud/fake_token_adapter.dart';

void main() {
  group('FirebaseRestClient', () {
    late FakeAdapter adapter;
    late FirebaseRestClient client;
    late RemoteSyncConfig cfg;

    setUp(() {
      adapter = FakeAdapter();
      final dio = Dio(BaseOptions(validateStatus: (_) => true))
        ..httpClientAdapter = adapter;
      client = FirebaseRestClient(dio: dio);
      cfg = RemoteSyncConfig(
        enabled: true,
        projectId: 'my-illam',
        apiKey: 'AIzaSyTestApiKey123456',
      );
    });

    test('signs up anonymously when no cached token exists', () async {
      adapter.replies.add((
        200,
        jsonEncode({
          'idToken': 'id-1',
          'refreshToken': 'ref-1',
          'localId': 'uid-1',
          'expiresIn': '3600',
        }),
      ));

      final token = await client.ensureAuthToken(cfg, nowMs: 10000);
      expect(token.idToken, 'id-1');
      expect(token.refreshToken, 'ref-1');
      expect(token.uid, 'uid-1');
      expect(adapter.requests.single.options.uri.host, 'identitytoolkit.googleapis.com');
    });

    test('refreshes expired token and falls back to anonymous signup on 400 refresh error', () async {
      final expiredCfg = cfg.copyWith(
        token: const FirebaseAuthToken(
          idToken: 'old-id',
          refreshToken: 'bad-ref',
          uid: 'uid-old',
          expiresAtMs: 1000,
        ),
      );
      adapter.replies
        ..add((400, jsonEncode({'error': {'message': 'TOKEN_EXPIRED'}})))
        ..add((
          200,
          jsonEncode({
            'idToken': 'id-fresh',
            'refreshToken': 'ref-fresh',
            'localId': 'uid-fresh',
            'expiresIn': '3600',
          }),
        ));

      final token = await client.ensureAuthToken(expiredCfg, nowMs: 50000);
      expect(token.idToken, 'id-fresh');
      expect(adapter.requests.length, 2);
      expect(adapter.requests[0].options.uri.host, 'securetoken.googleapis.com');
      expect(adapter.requests[1].options.uri.host, 'identitytoolkit.googleapis.com');
    });

    test('maps OPERATION_NOT_ALLOWED and API_KEY_INVALID errors accurately', () async {
      adapter.replies.add((
        400,
        jsonEncode({'error': {'message': 'OPERATION_NOT_ALLOWED'}}),
      ));
      await expectLater(
        () => client.ensureAuthToken(cfg, nowMs: 1000),
        throwsA(
          isA<RemoteSyncException>().having(
            (e) => e.error,
            'error',
            RemoteSyncError.anonAuthDisabled,
          ),
        ),
      );

      adapter.replies.add((
        400,
        jsonEncode({'error': {'message': 'API_KEY_INVALID'}}),
      ));
      await expectLater(
        () => client.ensureAuthToken(cfg, nowMs: 1000),
        throwsA(
          isA<RemoteSyncException>().having(
            (e) => e.error,
            'error',
            RemoteSyncError.invalidApiKey,
          ),
        ),
      );
    });

    test('commitBatch uses REQUEST_TIME + exists=false and retries once on 401', () async {
      const tok = FirebaseAuthToken(
        idToken: 'id-stale',
        refreshToken: 'ref-1',
        uid: 'uid-1',
        expiresAtMs: 99999999,
      );
      adapter.replies
        ..add((401, jsonEncode({'error': {'status': 'UNAUTHENTICATED'}})))
        ..add((
          200,
          jsonEncode({
            'id_token': 'id-2',
            'refresh_token': 'ref-2',
            'user_id': 'uid-1',
            'expires_in': '3600',
          }),
        ))
        ..add((
          200,
          jsonEncode({
            'writeResults': [
              {
                'updateTime': '2026-11-25T10:00:00Z',
                'transformResults': [
                  {'timestampValue': '2026-11-25T10:00:00.123456Z'},
                ],
              },
            ],
          }),
        ));

      final res = await client.commitBatch(
        config: cfg,
        token: tok,
        channelId: 'ch1',
        batchId: 'b1',
        sender: 'devA',
        keyId: 'genesis',
        payloadB64: 'YWJj',
        expiresAtUtc: DateTime.utc(2026, 12, 25),
        nowMs: 10000,
      );
      expect(res.token.idToken, 'id-2');
      expect(res.createdAt, '2026-11-25T10:00:00.123456Z');
      final sentBody = jsonDecode(adapter.requests.last.body) as Map;
      final write = (sentBody['writes'] as List).first as Map;
      expect(write['currentDocument'], {'exists': false});
      expect(write['updateTransforms'], [
        {'fieldPath': 'createdAt', 'setToServerValue': 'REQUEST_TIME'},
      ]);
    });

    test('queryBatches parses docs and skips empty readTime rows', () async {
      const tok = FirebaseAuthToken(
        idToken: 'id-1',
        refreshToken: 'ref-1',
        uid: 'uid-1',
        expiresAtMs: 99999999,
      );
      adapter.replies.add((
        200,
        jsonEncode([
          {'readTime': '2026-11-25T10:00:01Z'},
          {
            'document': {
              'name':
                  'projects/my-illam/databases/(default)/documents/illam_channels/ch1/batches/b1',
              'fields': {
                'v': {'integerValue': '1'},
                'sender': {'stringValue': 'devB'},
                'keyId': {'stringValue': 'genesis'},
                'payload': {'stringValue': 'cGF5bG9hZA=='},
                'createdAt': {'timestampValue': '2026-11-25T10:00:00Z'},
              },
            },
          },
        ]),
      ));

      final q = await client.queryBatches(
        config: cfg,
        token: tok,
        channelId: 'ch1',
        sinceTimestamp: '2026-11-25T09:59:00Z',
        nowMs: 10000,
      );
      expect(q.docs.length, 1);
      expect(q.docs.single.docId, 'b1');
      expect(q.docs.single.sender, 'devB');
      expect(q.docs.single.payloadB64, 'cGF5bG9hZA==');
    });

    test('testConnection probes write/get/delete/query and surfaces permissionDenied', () async {
      final authedCfg = cfg.copyWith(
        token: const FirebaseAuthToken(
          idToken: 'id-1',
          refreshToken: 'ref-1',
          uid: 'uid-1',
          expiresAtMs: 99999999,
        ),
      );
      adapter.replies
        ..add((200, '{}')) // PATCH probe
        ..add((200, '{}')) // GET probe
        ..add((200, '{}')) // DELETE probe
        ..add((200, jsonEncode([{'readTime': '2026-11-25T10:00:00Z'}]))); // query

      final token = await client.testConnection(
        authedCfg,
        channelId: 'ch1',
        nowMs: 1000,
      );
      expect(token.uid, 'uid-1');

      adapter.replies.add((
        403,
        jsonEncode({'error': {'status': 'PERMISSION_DENIED'}}),
      ));
      await expectLater(
        () => client.testConnection(authedCfg, channelId: 'ch1', nowMs: 1000),
        throwsA(
          isA<RemoteSyncException>().having(
            (e) => e.error,
            'error',
            RemoteSyncError.permissionDenied,
          ),
        ),
      );
    });
  });
}
