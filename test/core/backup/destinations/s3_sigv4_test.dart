import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/backup/destinations/s3/s3_sigv4.dart';

void main() {
  const accessKey = 'AKIAIOSFODNN7EXAMPLE';
  const secretKey = 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY';
  const region = 'us-east-1';
  const host = 'examplebucket.s3.amazonaws.com';
  const emptyHash =
      'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
  final now = DateTime.utc(2013, 5, 24);

  test('sha256Hex of empty payload matches AWS reference', () {
    expect(sha256Hex(const []), emptyHash);
  });

  test('GET object signature matches AWS reference vector', () {
    final r = signS3(
      method: 'GET',
      uri: Uri.parse('https://$host/test.txt'),
      headers: const {'Range': 'bytes=0-9'},
      payloadHash: emptyHash,
      accessKey: accessKey,
      secretKey: secretKey,
      region: region,
      now: now,
    );

    expect(
      sha256Hex(utf8.encode(r.canonicalRequest)),
      '7344ae5b7ee6c3e7e6b0fe0640412a37625d1fbfff95c48bbb2dc43964946972',
    );
    expect(
      r.signature,
      'f0e8bdb87c964420e857bd35b5d6ed310bd44f0170aba48dd91039c6036bdb41',
    );
  });

  test('PUT object signature matches AWS reference vector', () {
    const body = 'Welcome to Amazon S3.';
    final bodyHash = sha256Hex(utf8.encode(body));
    expect(
      bodyHash,
      '44ce7dd67c959e0d3524ffac1771dfbba87d2b6b4b4e99e42034a8b803f8b072',
    );

    final r = signS3(
      method: 'PUT',
      uri: Uri.parse('https://$host/test\$file.text'),
      headers: const {
        'Date': 'Fri, 24 May 2013 00:00:00 GMT',
        'x-amz-storage-class': 'REDUCED_REDUNDANCY',
      },
      payloadHash: bodyHash,
      accessKey: accessKey,
      secretKey: secretKey,
      region: region,
      now: now,
    );

    expect(
      r.signature,
      '98ad721746da40c64f1a55b78f14c238d841ea1380cd77a1b5971af0ece108bd',
    );
  });

  test('List objects signature matches AWS reference vector', () {
    final r = signS3(
      method: 'GET',
      uri: Uri.parse('https://$host/?max-keys=2&prefix=J'),
      headers: const {},
      payloadHash: emptyHash,
      accessKey: accessKey,
      secretKey: secretKey,
      region: region,
      now: now,
    );

    expect(
      r.signature,
      '34b48302e7b5fa45bde8084f4b7868a86f0a534bc59db6670ed5711ef69dc6f7',
    );
  });

  test('awsEncode leaves unreserved chars and encodes spaces and stars', () {
    expect(awsEncode('a b*~'), 'a%20b%2A~');
  });
}
