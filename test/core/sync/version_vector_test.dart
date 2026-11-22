import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/sync/version_vector.dart';

void main() {
  test('fromSeqs stops at gaps, handles missing 1, and skips duplicates', () {
    expect(VersionVector.fromSeqs({'a': [1, 2, 3, 5]})['a'], 3);
    expect(VersionVector.fromSeqs({'a': [2, 3]})['a'], 0);
    expect(VersionVector.fromSeqs({'a': [1, 1, 2]})['a'], 2);
  });

  test('missingIn, merge, and JSON round trip work as specified', () {
    expect(
      const VersionVector({'a': 5, 'b': 2}).missingIn(
        const VersionVector({'a': 3}),
      ),
      4,
    );
    expect(
      const VersionVector({'a': 5})
          .merge(const VersionVector({'a': 3, 'b': 2}))
          .toJson(),
      const {'a': 5, 'b': 2},
    );

    const v = VersionVector({'a': 4, 'b': 7});
    final rt = VersionVector.fromJson(v.toJson());
    expect(rt.toJson(), v.toJson());
  });
}
