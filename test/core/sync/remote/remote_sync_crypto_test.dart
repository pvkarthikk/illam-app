import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/crypto/aead.dart';
import 'package:nm_flat/core/sync/remote/remote_sync_crypto.dart';
import 'package:nm_flat/core/sync/version_vector.dart';

void main() {
  group('remote_sync_crypto', () {
    final key1 = Uint8List.fromList(List<int>.generate(32, (i) => i + 1));
    final key2 = Uint8List.fromList(List<int>.generate(32, (i) => i + 40));

    test('derives deterministic channelId and isolates keys/homes', () async {
      final c1a = await deriveRemoteChannelId(key1, 'NM-HOME1');
      final c1b = await deriveRemoteChannelId(key1, 'NM-HOME1');
      final c2 = await deriveRemoteChannelId(key2, 'NM-HOME1');
      final cOtherHome = await deriveRemoteChannelId(key1, 'NM-HOME2');

      expect(c1a, c1b);
      expect(c1a.length, 32);
      expect(c1a, isNot(c2));
      expect(c1a, isNot(cOtherHome));
    });

    test('seals and opens remote batch payload round-trip', () async {
      const payload = RemoteBatchPayload(
        homeId: 'NM-HOME1',
        sender: 'dev1234567890123',
        sentAt: 1764000000000,
        vector: VersionVector({'dev1234567890123': 4}),
        memberOpCount: 2,
        memberOps: [
          {'opId': 'g1', 'type': 'genesis'},
        ],
        ops: [
          {'opId': 'dev1234567890123:1', 'tbl': 'todos', 'field': 'title'},
        ],
      );

      final sealed = await sealRemoteBatch(
        homeKeyBytes: key1,
        keyId: 'genesis',
        payload: payload,
      );

      final opened = await openRemoteBatch(
        homeKeyBytes: key1,
        homeId: 'NM-HOME1',
        channelId: sealed.channelId,
        keyId: 'genesis',
        sender: 'dev1234567890123',
        payloadB64: sealed.payloadB64,
      );

      expect(opened.homeId, 'NM-HOME1');
      expect(opened.sender, 'dev1234567890123');
      expect(opened.vector['dev1234567890123'], 4);
      expect(opened.memberOpCount, 2);
      expect(opened.memberOps.single['opId'], 'g1');
      expect(opened.ops.single['opId'], 'dev1234567890123:1');
    });

    test('rejects wrong homeKey, wrong sender AAD, and tampered ciphertext', () async {
      const payload = RemoteBatchPayload(
        homeId: 'NM-HOME1',
        sender: 'devA',
        sentAt: 1000,
        vector: VersionVector({'devA': 1}),
        memberOpCount: 1,
      );
      final sealed = await sealRemoteBatch(
        homeKeyBytes: key1,
        keyId: 'genesis',
        payload: payload,
      );

      await expectLater(
        () => openRemoteBatch(
          homeKeyBytes: key2,
          homeId: 'NM-HOME1',
          channelId: sealed.channelId,
          keyId: 'genesis',
          sender: 'devA',
          payloadB64: sealed.payloadB64,
        ),
        throwsA(isA<AeadError>()),
      );

      await expectLater(
        () => openRemoteBatch(
          homeKeyBytes: key1,
          homeId: 'NM-HOME1',
          channelId: sealed.channelId,
          keyId: 'genesis',
          sender: 'devB',
          payloadB64: sealed.payloadB64,
        ),
        throwsA(isA<AeadError>()),
      );
    });
  });
}
