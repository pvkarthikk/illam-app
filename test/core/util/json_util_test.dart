import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/util/json_util.dart';

void main() {
  test('encodeValue and decodeValue handle scalar JSON values', () {
    expect(encodeValue('Milk'), '"Milk"');
    expect(encodeValue(2), '2');
    expect(encodeValue(true), 'true');
    expect(encodeValue(null), 'null');
    expect(() => encodeValue(DateTime(2026)), throwsArgumentError);
    expect(() => encodeValue([1]), throwsArgumentError);
    expect(decodeValue(null), isNull);
    expect(decodeValue(encodeValue(1.5)), 1.5);
  });
}
