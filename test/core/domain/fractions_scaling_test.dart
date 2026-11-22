import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/fractions.dart';
import 'package:nm_flat/core/domain/recipe_scaling.dart';
import 'package:nm_flat/core/domain/units.dart';

void main() {
  test('formatFraction formats whole numbers, quarters, <¼, and a pinch', () {
    expect(formatFraction(2, ''), '2');
    expect(formatFraction(0.5, ''), '½');
    expect(formatFraction(1.5, ''), '1½');
    expect(formatFraction(0.75, ''), '¾');
    expect(formatFraction(1.3, ''), '1¼');
    expect(formatFraction(1.05, ''), '1');
    expect(formatFraction(0.2, ''), '¼');
    expect(formatFraction(0.1, ''), '<¼');
    expect(formatFraction(2.9, ''), '3');
    expect(formatFraction(25, 'g'), '25');
    expect(formatFraction(0.05, 'pinch'), 'a pinch');
  });

  test('scaleQty scales and rounds with minimum 0.01', () {
    expect(scaleQty(200, 4, 6), 300);
    expect(formatFraction(300, 'g'), '300');

    final scaled = scaleQty(0.75, 4, 5);
    expect(scaled, 0.94);
    expect(formatFraction(scaled, ''), '1');

    final tinyTsp = scaleQty(0.25, 12, 1);
    expect(tinyTsp, 0.02);
    expect(formatFraction(0.02, 'tsp'), '<¼');

    expect(scaleQty(0.001, 4, 1), 0.01);
  });

  test('unit helpers classify and convert units', () {
    expect(familyOf('tbsp'), UnitFamily.kitchen);
    expect(familyOf('kg'), UnitFamily.mass);

    expect(toBaseQty(1.5, 'kg'), 1500);
    expect(toBaseQty(2, 'L'), 2000);
    expect(baseUnit('kg'), 'g');
    expect(baseUnit('L'), 'ml');
    expect(baseUnit('cup'), 'cup');

    expect(allUnits, containsAll(['', 'kg', 'lemon size']));
  });
}
