import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/backup/cloud/pcloud_auth.dart';
import 'package:nm_flat/core/backup/cloud/pcloud_destination.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';

void main() {
  test('PcloudAuth.parseRedirect validates state and host', () {
    final okUri = Uri.parse(
      'app.nestmojo.pcloud://callback/oauth-pcloud'
      '#access_token=abc&token_type=bearer&uid=7&state=s1&locationid=2&hostname=eapi.pcloud.com',
    );
    final parsed = PcloudAuth.parseRedirect(okUri, 's1');
    expect(parsed.token, 'abc');
    expect(parsed.host, 'eapi.pcloud.com');

    expect(
      () => PcloudAuth.parseRedirect(okUri, 's2'),
      throwsA(isA<DestinationException>()),
    );

    final evilUri = Uri.parse(
      'app.nestmojo.pcloud://callback/oauth-pcloud'
      '#access_token=abc&state=s1&hostname=evil.example',
    );
    expect(
      () => PcloudAuth.parseRedirect(evilUri, 's1'),
      throwsA(isA<DestinationException>()),
    );

    final loc1Uri = Uri.parse(
      'app.nestmojo.pcloud://callback/oauth-pcloud'
      '#access_token=abc&state=s1&locationid=1',
    );
    expect(PcloudAuth.parseRedirect(loc1Uri, 's1').host, 'api.pcloud.com');
  });

  test('pcloudErrorKind maps result codes', () {
    expect(PcloudDestination.pcloudErrorKind(2008), DestError.full);
    expect(PcloudDestination.pcloudErrorKind(2005), isNull);
  });

  test('parseListFolder extracts backup files and epoch modified time', () {
    final files = PcloudDestination.parseListFolder(const {
      'result': 0,
      'metadata': {
        'contents': [
          {
            'name': 'NestMojo_0a1b2c3d_20261120-101502Z_9f8e7d6c.nmbak',
            'isfolder': false,
            'size': 5,
            'modified': 'Fri, 20 Nov 2026 10:15:02 +0000',
          },
          {'name': 'x', 'isfolder': true},
        ],
      },
    });

    expect(files.length, 1);
    expect(
      files.single.modifiedMs,
      DateTime.utc(2026, 11, 20, 10, 15, 2).millisecondsSinceEpoch,
    );
  });
}
