import 'dart:math';

/// Per-device highest contiguous sequence numbers (`1, 2, 3, ...`) for a home.
class VersionVector {
  const VersionVector(this.map);

  factory VersionVector.fromSeqs(Map<String, List<int>> seqs) => VersionVector({
    for (final e in seqs.entries) e.key: _contiguous(e.value),
  });

  factory VersionVector.fromJson(Map<String, Object?> m) => VersionVector({
    for (final e in m.entries) e.key: (e.value as num).toInt(),
  });

  final Map<String, int> map;

  static int _contiguous(List<int> s) {
    final sorted = [...s]..sort();
    var n = 0;
    for (final v in sorted) {
      if (v <= n) continue;
      if (v == n + 1) {
        n = v;
      } else {
        break;
      }
    }
    return n;
  }

  int operator [](String d) => map[d] ?? 0;

  /// Sum of ops this phone has beyond [other].
  int missingIn(VersionVector other) {
    var total = 0;
    for (final e in map.entries) {
      total += max(0, e.value - other[e.key]);
    }
    return total;
  }

  /// Pointwise maximum across this vector and [o].
  VersionVector merge(VersionVector o) {
    final keys = {...map.keys, ...o.map.keys};
    return VersionVector({
      for (final k in keys) k: max(this[k], o[k]),
    });
  }

  Map<String, int> toJson() => map;
}
