import 'dart:convert';

/// Encodes [v] into deterministic canonical JSON (sorted map keys, no spaces).
///
/// Rejects `double` and non-JSON-primitive objects with [ArgumentError].
String canonicalJson(Object? v) {
  if (v == null || v is bool || v is int || v is String) {
    return jsonEncode(v);
  }
  if (v is List) {
    final parts = v.map(canonicalJson).join(',');
    return '[$parts]';
  }
  if (v is Map) {
    final keys = <String>[];
    for (final k in v.keys) {
      if (k is! String) {
        throw ArgumentError.value(k, 'key', 'Canonical JSON keys must be String');
      }
      keys.add(k);
    }
    keys.sort();
    final parts = keys.map((k) => '${jsonEncode(k)}:${canonicalJson(v[k])}');
    return '{${parts.join(',')}}';
  }
  throw ArgumentError.value(
    v,
    'v',
    'Unsupported type in canonicalJson: ${v.runtimeType}',
  );
}
