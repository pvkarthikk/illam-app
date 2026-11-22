import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';

void main() {
  test('fresh prefs generate 16-char lowercase deviceId and default state', () async {
    final prefs = await DevicePrefs.inMemory();
    expect(prefs.deviceId.length, 16);
    expect(RegExp(r'^[a-z2-7]{16}$').hasMatch(prefs.deviceId), isTrue);
    expect(prefs.deviceIdKind, 'random');
    expect(prefs.nextSeq, 1);
    expect(prefs.currentHomeId, isNull);
  });

  test('currentHomeIdStream emits null then NM-1 after setCurrentHomeId', () async {
    final prefs = await DevicePrefs.inMemory();
    final expectation = expectLater(
      prefs.currentHomeIdStream(),
      emitsInOrder([null, 'NM-1']),
    );
    await prefs.setCurrentHomeId('NM-1');
    expect(prefs.currentHomeId, 'NM-1');
    await expectation;
  });

  test('clearAll rotates deviceId, clears currentHomeId, and emits null', () async {
    final prefs = await DevicePrefs.inMemory();
    await prefs.setCurrentHomeId('NM-1');
    final initialId = prefs.deviceId;

    final expectation = expectLater(
      prefs.currentHomeIdStream(),
      emitsInOrder(['NM-1', null]),
    );
    await prefs.clearAll();
    expect(prefs.deviceId, isNot(initialId));
    expect(prefs.currentHomeId, isNull);
    await expectation;
  });

  test('setFlag and getFlag persist boolean flags', () async {
    final prefs = await DevicePrefs.inMemory();
    expect(prefs.getFlag('missing'), isFalse);
    await prefs.setFlag('x', true);
    expect(prefs.getFlag('x'), isTrue);
  });
}
