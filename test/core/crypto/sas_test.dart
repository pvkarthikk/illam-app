import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/sas.dart';
import 'package:nm_flat/core/sync/protocol/join_messages.dart';

void main() {
  test('sasEmojis has 64 distinct entries and sasFor responds to nonce changes', () async {
    expect(sasEmojis.length, 64);
    expect(sasEmojis.toSet().length, 64);

    final ke = randomBytes(16);
    final t = randomBytes(32);
    final nI = randomBytes(32);
    final nJ = randomBytes(32);
    final e1 = await sasFor(ke, t, nI, nJ);
    final e2 = await sasFor(ke, t, nI, nJ);
    expect(e1, e2);
    expect(e1.length, 3);

    var changedCount = 0;
    for (var i = 0; i < 5; i++) {
      final a = randomBytes(32);
      final b = Uint8List.fromList(a)..[0] ^= 0x01;
      final resA = await sasFor(ke, t, nI, a);
      final resB = await sasFor(ke, t, nI, b);
      if (resA.join() != resB.join()) changedCount++;
    }
    expect(changedCount, greaterThan(0));
  });

  test('JoinRequest JSON round trip preserves all 5 fields', () {
    const req = JoinRequest(
      name: 'Priya',
      model: 'Pixel',
      deviceId: 'dev123',
      signPub: 'spub',
      agreePub: 'apub',
    );
    final decoded = JoinRequest.fromJson(req.toJson());
    expect(decoded.name, req.name);
    expect(decoded.model, req.model);
    expect(decoded.deviceId, req.deviceId);
    expect(decoded.signPub, req.signPub);
    expect(decoded.agreePub, req.agreePub);
  });
}
