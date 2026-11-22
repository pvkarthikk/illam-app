import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

final _rng = Random.secure();
final _hex64 = RegExp(r'^[0-9a-f]{64}$');

/// Returns [n] cryptographically secure random bytes.
Uint8List randomBytes(int n) {
  final out = Uint8List(n);
  for (var i = 0; i < n; i++) {
    out[i] = _rng.nextInt(256);
  }
  return out;
}

/// Encodes [b] as lowercase hexadecimal.
String toHex(List<int> b) {
  final sb = StringBuffer();
  for (final byte in b) {
    sb.write((byte & 0xff).toRadixString(16).padLeft(2, '0'));
  }
  return sb.toString();
}

/// Decodes hexadecimal [s] into bytes.
Uint8List fromHex(String s) {
  if (s.length.isOdd) {
    throw ArgumentError.value(s, 's', 'Hex string must have even length');
  }
  final out = Uint8List(s.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    out[i] = int.parse(s.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return out;
}

/// Standard base64 encoding with `=` padding.
String b64(List<int> b) => base64.encode(b);

/// Standard base64 decoding.
Uint8List unb64(String s) => Uint8List.fromList(base64.decode(s));

/// URL-safe base64 encoding without `=` padding.
String b64url(List<int> b) => base64Url.encode(b).replaceAll('=', '');

/// URL-safe base64 decoding (re-adding missing `=` padding).
Uint8List unb64url(String s) {
  final rem = s.length % 4;
  final padded = rem == 0 ? s : s + '=' * (4 - rem);
  return Uint8List.fromList(base64Url.decode(padded));
}

/// Constant-time byte slice equality check.
bool constantTimeEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}

/// Concatenates [parts] into a single [Uint8List].
Uint8List concatBytes(List<List<int>> parts) {
  final bb = BytesBuilder(copy: false);
  for (final p in parts) {
    bb.add(p);
  }
  return bb.toBytes();
}

/// Encodes [v] as an unsigned 64-bit big-endian integer (8 bytes).
Uint8List u64be(int v) {
  final d = ByteData(8)..setUint64(0, v);
  return d.buffer.asUint8List();
}

/// Decodes a 64-char lowercase hex key or a standard base64 key.
Uint8List decodeKey(String s) => _hex64.hasMatch(s) ? fromHex(s) : unb64(s);
