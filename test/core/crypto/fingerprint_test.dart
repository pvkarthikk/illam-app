import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/crypto/fingerprint.dart';

void main() {
  test('fingerprintOf empty input returns known SHA-256 prefix', () {
    expect(fingerprintOf([]), 'e3b0 c442 98fc');
  });

  test('fingerprintOf formats 12 hex chars as 3 space-separated groups of 4', () {
    final fp = fingerprintOf([1, 2, 3]);
    expect(fp.length, 14);
    expect(RegExp(r'^[0-9a-f]{4} [0-9a-f]{4} [0-9a-f]{4}$').hasMatch(fp), isTrue);
  });
}
