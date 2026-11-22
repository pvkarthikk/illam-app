import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/http_tools.dart';

void main() {
  test('sha256Fingerprint encodes unpadded SHA256 digest', () {
    expect(
      sha256Fingerprint([1, 2, 3]),
      'SHA256:A5BYxvLAy0ksUzsKTRTvd8wPeKvMztUofYShogEc+4E',
    );
  });

  test('statusError maps HTTP statuses', () {
    expect(statusError(401)?.error, DestError.auth);
    expect(statusError(403)?.error, DestError.noPermission);
    expect(statusError(507)?.error, DestError.full);
    expect(statusError(503)?.error, DestError.unreachable);
    expect(statusError(204), isNull);
  });

  test('requireHttps throws when http is disallowed', () {
    expect(
      () => requireHttps(Uri.parse('http://x'), allowHttp: false),
      throwsA(
        isA<DestinationException>().having(
          (e) => e.error,
          'error',
          DestError.httpsRequired,
        ),
      ),
    );
    expect(
      () => requireHttps(Uri.parse('http://x'), allowHttp: true),
      returnsNormally,
    );
  });

  test('randomHex returns 2 hex chars per byte', () {
    final out = randomHex(4);
    expect(out.length, 8);
    expect(RegExp(r'^[0-9a-f]{8}$').hasMatch(out), isTrue);
  });
}
