import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/backup/destinations/webdav/propfind_parser.dart';

void main() {
  const name = 'Illam_ab12cd34_20261120-101500Z_0f1e2d3c.nmbak';

  test('parses Nextcloud style PROPFIND XML', () {
    const xml = '''
<?xml version="1.0" encoding="utf-8"?>
<d:multistatus xmlns:d="DAV:">
  <d:response>
    <d:href>/remote.php/dav/files/anand/Illam/</d:href>
    <d:propstat>
      <d:prop>
        <d:resourcetype><d:collection/></d:resourcetype>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
  <d:response>
    <d:href>/remote.php/dav/files/anand/Illam/$name</d:href>
    <d:propstat>
      <d:prop>
        <d:getcontentlength>2457600</d:getcontentlength>
        <d:getlastmodified>Fri, 20 Nov 2026 10:15:02 GMT</d:getlastmodified>
        <d:resourcetype/>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
</d:multistatus>
''';

    final entries = parsePropfind(xml);
    expect(entries.length, 2);

    expect(entries[0].isFolder, isTrue);
    expect(entries[0].name, 'Illam');

    expect(entries[1].name, name);
    expect(entries[1].size, 2457600);
    expect(entries[1].modified, DateTime.utc(2026, 11, 20, 10, 15, 2));
    expect(entries[1].isFolder, isFalse);
  });

  test('parses Apache style PROPFIND XML with mixed namespace prefixes', () {
    const xml = '''
<?xml version="1.0" encoding="utf-8"?>
<D:multistatus xmlns:D="DAV:">
  <D:response>
    <D:href>/remote.php/dav/files/anand/Illam/</D:href>
    <D:propstat>
      <D:prop>
        <D:resourcetype><D:collection /></D:resourcetype>
      </D:prop>
      <D:status>HTTP/1.1 200 OK</D:status>
    </D:propstat>
  </D:response>
  <D:response>
    <D:href>/remote.php/dav/files/anand/Illam/$name</D:href>
    <D:propstat>
      <D:prop>
        <lp1:getcontentlength xmlns:lp1="DAV:">2457600</lp1:getcontentlength>
        <lp1:getlastmodified xmlns:lp1="DAV:">Fri, 20 Nov 2026 10:15:02 GMT</lp1:getlastmodified>
        <D:resourcetype/>
      </D:prop>
      <D:status>HTTP/1.1 200 OK</D:status>
    </D:propstat>
  </D:response>
</D:multistatus>
''';

    final entries = parsePropfind(xml);
    expect(entries.length, 2);

    expect(entries[0].isFolder, isTrue);
    expect(entries[0].name, 'Illam');

    expect(entries[1].name, name);
    expect(entries[1].size, 2457600);
    expect(entries[1].modified, DateTime.utc(2026, 11, 20, 10, 15, 2));
    expect(entries[1].isFolder, isFalse);
  });

  test('returns empty list for empty multistatus', () {
    const xml = '<d:multistatus xmlns:d="DAV:"></d:multistatus>';
    expect(parsePropfind(xml), isEmpty);
  });
}
