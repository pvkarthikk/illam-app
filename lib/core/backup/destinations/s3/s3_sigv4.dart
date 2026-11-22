import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Percent-encodes [s] following AWS SigV4 URI/query encoding rules.
String awsEncode(String s, {bool keepSlash = false}) {
  final bytes = utf8.encode(s);
  final out = StringBuffer();
  for (final b in bytes) {
    final isUnreserved =
        (b >= 0x41 && b <= 0x5A) ||
        (b >= 0x61 && b <= 0x7A) ||
        (b >= 0x30 && b <= 0x39) ||
        b == 0x2D ||
        b == 0x5F ||
        b == 0x2E ||
        b == 0x7E;
    if (isUnreserved || (keepSlash && b == 0x2F)) {
      out.writeCharCode(b);
    } else {
      out.write('%');
      out.write(b.toRadixString(16).toUpperCase().padLeft(2, '0'));
    }
  }
  return out.toString();
}

String _hex(List<int> b) {
  final out = StringBuffer();
  for (final byte in b) {
    out.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return out.toString();
}

/// Lowercase hex SHA-256 digest of [data].
String sha256Hex(List<int> data) => _hex(sha256.convert(data).bytes);

/// Formats [t] in UTC as `YYYYMMDDTHHMMSSZ`.
String amzDate(DateTime t) {
  final u = t.toUtc();
  final y = u.year.toString().padLeft(4, '0');
  final mo = u.month.toString().padLeft(2, '0');
  final d = u.day.toString().padLeft(2, '0');
  final h = u.hour.toString().padLeft(2, '0');
  final mi = u.minute.toString().padLeft(2, '0');
  final s = u.second.toString().padLeft(2, '0');
  return '$y$mo${d}T$h$mi${s}Z';
}

/// Output of signing an S3 request with AWS Signature Version 4.
class SigV4Result {
  const SigV4Result(this.canonicalRequest, this.signature, this.headers);

  final String canonicalRequest;
  final String signature;
  final Map<String, String> headers;
}

List<int> _hmac(List<int> key, String msg) =>
    Hmac(sha256, key).convert(utf8.encode(msg)).bytes;

/// Signs an S3 request using header-based AWS Signature Version 4.
SigV4Result signS3({
  required String method,
  required Uri uri,
  required Map<String, String> headers,
  required String payloadHash,
  required String accessKey,
  required String secretKey,
  required String region,
  required DateTime now,
  String service = 's3',
}) {
  final date = amzDate(now);
  final day = date.substring(0, 8);

  final h = <String, String>{};
  for (final entry in headers.entries) {
    h[entry.key.toLowerCase()] = entry.value.trim();
  }
  final hostHeader = uri.hasPort && uri.port != 80 && uri.port != 443
      ? '${uri.host}:${uri.port}'
      : uri.host;
  h['host'] = hostHeader;
  h['x-amz-date'] = date;
  h['x-amz-content-sha256'] = payloadHash;

  final names = h.keys.toList()..sort();

  final canonicalUri = uri.pathSegments.isEmpty
      ? '/'
      : '/${uri.pathSegments.map((s) => awsEncode(s)).join('/')}';

  final queryPairs = <String>[];
  for (final entry in uri.queryParametersAll.entries) {
    final encodedKey = awsEncode(entry.key);
    for (final v in entry.value) {
      queryPairs.add('$encodedKey=${awsEncode(v)}');
    }
  }
  queryPairs.sort();
  final canonicalQuery = queryPairs.join('&');

  final canonicalHeaders = StringBuffer();
  for (final name in names) {
    canonicalHeaders
      ..write(name)
      ..write(':')
      ..write(h[name])
      ..write('\n');
  }
  final signedHeaders = names.join(';');

  final canonicalRequest = [
    method,
    canonicalUri,
    canonicalQuery,
    canonicalHeaders.toString(),
    signedHeaders,
    payloadHash,
  ].join('\n');

  final scope = '$day/$region/$service/aws4_request';
  final stringToSign = [
    'AWS4-HMAC-SHA256',
    date,
    scope,
    sha256Hex(utf8.encode(canonicalRequest)),
  ].join('\n');

  var k = _hmac(utf8.encode('AWS4$secretKey'), day);
  k = _hmac(k, region);
  k = _hmac(k, service);
  k = _hmac(k, 'aws4_request');
  final signature = _hex(_hmac(k, stringToSign));

  h['authorization'] =
      'AWS4-HMAC-SHA256 Credential=$accessKey/$scope,SignedHeaders=$signedHeaders,Signature=$signature';

  return SigV4Result(canonicalRequest, signature, h);
}
