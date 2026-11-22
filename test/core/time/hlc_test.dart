import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';

void main() {
  test('Hlc formatting, parsing, and compareTo ordering', () {
    const sample = Hlc(5, 26, 'abc');
    expect(sample.toString(), '0000000000005.001a.abc');
    final parsed = Hlc.parse('0000000000005.001a.abc');
    expect(parsed.wall, 5);
    expect(parsed.counter, 26);
    expect(parsed.deviceId, 'abc');

    const a = Hlc(5, 26, 'abc');
    const b = Hlc(5, 27, 'abc');
    const c = Hlc(6, 0, 'aaa');
    final items = [a, b, c];
    for (final x in items) {
      for (final y in items) {
        expect(x.toString().compareTo(y.toString()).sign, x.compareTo(y).sign);
      }
    }
  });

  test('HlcClock monotonicity, backwards clock, observe, and persistence', () async {
    final prefs = await DevicePrefs.inMemory();
    final clock = FixedClock(DateTime(2026, 11, 20, 9));
    final hlc = HlcClock(clock, prefs);

    // Same wall twice -> counter 0000 then 0001
    final h1 = await hlc.next();
    final h2 = await hlc.next();
    expect(h1.endsWith('.${prefs.deviceId}'), isTrue);
    expect(h2.endsWith('.${prefs.deviceId}'), isTrue);
    expect(h1.split('.')[1], '0000');
    expect(h2.split('.')[1], '0001');
    expect(Hlc.parse(h1).counter, 0);
    expect(Hlc.parse(h2).counter, 1);

    // Clock moved back 5 s -> same wall, counter +1
    final wallBefore = Hlc.parse(h2).wall;
    clock.advance(const Duration(seconds: -5));
    final h3 = await hlc.next();
    expect(Hlc.parse(h3).wall, wallBefore);
    expect(Hlc.parse(h3).counter, 2);
    expect(h3.endsWith('.${prefs.deviceId}'), isTrue);

    // Clock moved forward past stored wall -> wall = new now, counter 0
    clock.advance(const Duration(seconds: 10));
    final h4 = await hlc.next();
    expect(Hlc.parse(h4).wall, clock.nowMs);
    expect(Hlc.parse(h4).counter, 0);
    expect(h4.endsWith('.${prefs.deviceId}'), isTrue);

    // observe remote HLC 10 s ahead -> subsequent next() > remote
    final remoteAhead = Hlc(clock.nowMs + 10000, 3, 'zzzzzzzzzzzzzzzz').toString();
    await hlc.observe(remoteAhead);
    final h5 = await hlc.next();
    expect(h5.compareTo(remoteAhead) > 0, isTrue);
    expect(h5.endsWith('.${prefs.deviceId}'), isTrue);

    // observe older HLC changes nothing
    final savedBefore = prefs.lastHlc;
    await hlc.observe('0000000000001.0000.zzzzzzzzzzzzzzzz');
    expect(prefs.lastHlc, savedBefore);

    // Persistence across new HlcClock instance on same prefs
    final hlc2 = HlcClock(clock, prefs);
    final h6 = await hlc2.next();
    expect(h6.compareTo(h5) > 0, isTrue);
    expect(h6.endsWith('.${prefs.deviceId}'), isTrue);
  });
}
