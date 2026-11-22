import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/backup/cloud/oauth_tokens.dart';
import 'package:nm_flat/core/backup/cloud/token_keeper.dart';
import 'package:nm_flat/core/backup/destination_secrets.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';

import 'fake_token_adapter.dart';

void main() {
  test('OAuthTokens round-trips JSON and expiresSoon detects < 5m left', () {
    const tokens = OAuthTokens(
      accessToken: 'at-1',
      refreshToken: 'rt-1',
      expiresAtMs: 1000000,
    );
    final roundTripped = OAuthTokens.fromJson(tokens.toJson());
    expect(roundTripped.accessToken, 'at-1');
    expect(roundTripped.refreshToken, 'rt-1');
    expect(roundTripped.expiresAtMs, 1000000);

    const twoMinMs = 2 * 60 * 1000;
    const oneHourMs = 60 * 60 * 1000;
    expect(tokens.expiresSoon(1000000 - twoMinMs), isTrue);
    expect(tokens.expiresSoon(1000000 - oneHourMs), isFalse);
  });

  group('TokenKeeper', () {
    const fixedNow = 1700000000000;
    const destId = 'dest-1';
    final provider = OAuthProvider(
      name: 'TestProvider',
      clientId: () => 'client-123',
      authEndpoint: Uri.parse('https://example.com/auth'),
      tokenEndpoint: Uri.parse('https://example.com/token'),
      scopes: const ['read', 'write'],
    );

    late FakeAdapter fake;
    late Dio dio;
    late DestinationSecrets secrets;
    late TokenKeeper keeper;

    setUp(() {
      fake = FakeAdapter();
      dio = Dio(BaseOptions(validateStatus: (_) => true))
        ..httpClientAdapter = fake;
      secrets = DestinationSecrets(MemorySecureStore());
      keeper = TokenKeeper(dio, secrets, destId, provider, nowMs: () => fixedNow);
    });

    Future<void> seedTokens({
      required int expiresAtMs,
      String access = 'a1',
      String? refresh = 'r1',
    }) async {
      await secrets.write(
        destId,
        jsonEncode(
          OAuthTokens(
            accessToken: access,
            refreshToken: refresh,
            expiresAtMs: expiresAtMs,
          ).toJson(),
        ),
      );
    }

    test('(a) valid token returns stored accessToken without HTTP call', () async {
      await seedTokens(expiresAtMs: fixedNow + 60 * 60 * 1000);
      expect(await keeper.accessToken(), 'a1');
      expect(fake.requests, isEmpty);
    });

    test('(b) expiring token refreshes and retains old refreshToken when omitted', () async {
      await seedTokens(expiresAtMs: fixedNow + 2 * 60 * 1000);
      fake.replies.add((200, '{"access_token":"a2","expires_in":3600}'));

      final tok = await keeper.accessToken();
      expect(tok, 'a2');
      expect(fake.requests.length, 1);
      final req = fake.requests.single;
      expect(req.options.method, 'POST');
      expect(req.body, contains('grant_type=refresh_token'));
      expect(req.body, contains('client_id=client-123'));

      final saved = OAuthTokens.fromJson(
        Map<String, Object?>.from(
          jsonDecode((await secrets.read(destId))!) as Map,
        ),
      );
      expect(saved.accessToken, 'a2');
      expect(saved.refreshToken, 'r1');
      expect(saved.expiresAtMs, fixedNow + 3600000);
    });

    test('(c) refresh replaces refreshToken when returned by provider', () async {
      await seedTokens(expiresAtMs: fixedNow + 2 * 60 * 1000);
      fake.replies.add(
        (200, '{"access_token":"a2","refresh_token":"r2","expires_in":3600}'),
      );

      await keeper.accessToken();
      final saved = OAuthTokens.fromJson(
        Map<String, Object?>.from(
          jsonDecode((await secrets.read(destId))!) as Map,
        ),
      );
      expect(saved.refreshToken, 'r2');
    });

    test('(d) invalid_grant 400 throws DestError.auth', () async {
      await seedTokens(expiresAtMs: fixedNow + 2 * 60 * 1000);
      fake.replies.add((400, '{"error":"invalid_grant"}'));

      expect(
        () => keeper.accessToken(),
        throwsA(
          isA<DestinationException>().having(
            (e) => e.error,
            'error',
            DestError.auth,
          ),
        ),
      );
    });

    test('(e) authed refreshes once on 401 and retries with new token', () async {
      await seedTokens(expiresAtMs: fixedNow + 60 * 60 * 1000);
      fake.replies.add((401, '{"error":"expired"}'));
      fake.replies.add((200, '{"access_token":"a2","expires_in":3600}'));
      fake.replies.add((200, '{"ok":true}'));

      final seenTokens = <String>[];
      final res = await keeper.authed<dynamic>((tok) {
        seenTokens.add(tok);
        return dio.getUri<dynamic>(
          Uri.parse('https://example.com/resource'),
          options: Options(headers: {'Authorization': 'Bearer $tok'}),
        );
      });

      expect(res.statusCode, 200);
      expect(seenTokens, ['a1', 'a2']);
    });
  });
}
