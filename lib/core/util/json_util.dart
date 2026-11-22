import 'dart:convert';

String encodeValue(Object? v) {
  if (v != null && v is! String && v is! int && v is! double && v is! bool) {
    throw ArgumentError.value(
      v,
      'v',
      'Expected String, int, double, bool, or null',
    );
  }
  return jsonEncode(v);
}

Object? decodeValue(String? json) => json == null ? null : jsonDecode(json);
