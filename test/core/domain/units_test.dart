import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/units.dart';

void main() {
  test('formatQty strips trailing decimals and formats count prefix', () {
    expect(formatQty(1500, 'kg'), '1.5 kg');
    expect(formatQty(400000, 'g'), '400 g');
    expect(formatQty(2000, ''), '×2');
  });

  test('convertMilli converts within mass and volume only', () {
    expect(convertMilli(500000, 'ml', 'L'), 500);
    expect(convertMilli(1000, 'kg', 'g'), 1000000);
    expect(convertMilli(1000, 'pkt', 'L'), isNull);
  });

  test('stepMilli returns expected step per unit', () {
    expect(stepMilli('g'), 100000);
    expect(stepMilli('kg'), 500);
    expect(stepMilli('pcs'), 1000);
  });

  test('compatKey isolates count units from mass and volume', () {
    expect(compatKey('g'), 'mass');
    expect(compatKey('kg'), 'mass');
    expect(compatKey('ml'), 'volume');
    expect(compatKey('L'), 'volume');
    expect(compatKey('pkt'), 'u:pkt');
  });
}
