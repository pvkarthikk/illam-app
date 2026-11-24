import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/destinations/http_tools.dart';
import 'package:nm_flat/core/backup/destinations/webdav/webdav_client.dart';
import 'package:nm_flat/core/backup/destinations/webdav/webdav_destination.dart';

import 'fake_webdav_adapter.dart';

void main() {
  const name = 'Illam_ab12cd34_20261120-101500Z_0f1e2d3c.nmbak';

  late FakeWebDavAdapter fake;
  late WebDavDestination d;

  setUp(() {
    fake = FakeWebDavAdapter();
    final dio = buildServerDio()..httpClientAdapter = fake;
    d = WebDavDestination(
      kind: 'webdav',
      dav: WebDavClient(dio, Uri.parse('https://dav.test/nm/'), 'u', 'p'),
    );
  });

  test('upload publishes atomically without leaving .part files', () async {
    final payload = Uint8List.fromList([1, 2, 3, 4, 5]);
    await d.upload(name, payload);

    final items = await d.list();
    expect(items.map((e) => e.name).toList(), [name]);
    expect(fake.files.keys.any((k) => k.endsWith('.part')), isFalse);
  });

  test('download returns uploaded bytes', () async {
    final payload = Uint8List.fromList([10, 20, 30, 40]);
    await d.upload(name, payload);

    expect(await d.download(name), payload);
  });

  test('testWrite cleans up temporary file', () async {
    await d.testWrite();
    expect(fake.files, isEmpty);
  });

  test('upload maps 401 to DestError.auth', () async {
    fake.forceStatus = 401;
    expect(
      () => d.upload(name, Uint8List.fromList([1, 2])),
      throwsA(
        isA<DestinationException>().having(
          (e) => e.error,
          'error',
          DestError.auth,
        ),
      ),
    );
  });

  test('upload maps 507 to DestError.full', () async {
    fake.forceStatus = 507;
    expect(
      () => d.upload(name, Uint8List.fromList([1, 2])),
      throwsA(
        isA<DestinationException>().having(
          (e) => e.error,
          'error',
          DestError.full,
        ),
      ),
    );
  });
}
