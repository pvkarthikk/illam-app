import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/util/hash_id.dart';

void main() {
  test('sha1Hex computes RFC test vector', () {
    expect(sha1Hex('abc'), 'a9993e364706816aba3e25717850c26c9cd0d89d');
  });
}
