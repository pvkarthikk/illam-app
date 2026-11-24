import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/crypto/sign.dart';
import 'package:nm_flat/core/crypto/sign_worker.dart';

void main() {
  test('SignWorker signs batches on background isolate and disposes', () async {
    final keys = await DeviceKeys.fromSeeds(
      List.filled(32, 3),
      List.filled(32, 4),
    );
    final worker = SignWorker(Future.value(keys));
    addTearDown(worker.dispose);

    final bodies = [
      utf8.encode('first op payload'),
      utf8.encode('second op payload'),
    ];
    final sigs = await worker.signAll(SignDomain.env, bodies);
    expect(sigs.length, 2);
    for (var i = 0; i < bodies.length; i++) {
      expect(
        await Signer.verify(keys.signPub, SignDomain.env, bodies[i], sigs[i]),
        isTrue,
      );
    }

    worker.dispose();
  });
}
