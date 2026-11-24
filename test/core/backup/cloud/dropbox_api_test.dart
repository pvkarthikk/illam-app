import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/backup/cloud/dropbox_destination.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';

void main() {
  test('argHeader escapes non-ASCII code units for Dropbox-API-Arg', () {
    expect(
      DropboxDestination.argHeader({'path': '/Nest é.nmbak'}),
      r'{"path":"/Nest \u00e9.nmbak"}',
    );
  });

  test('parseListFolder filters file entries and reads hasMore', () {
    final parsed = DropboxDestination.parseListFolder(const {
      'entries': [
        {'.tag': 'folder', 'name': 'x'},
        {
          '.tag': 'file',
          'name': 'Illam_a.nmbak',
          'size': 2457600,
          'server_modified': '2026-11-20T10:15:02Z',
        },
      ],
      'has_more': false,
      'cursor': 'c',
    });

    expect(parsed.hasMore, isFalse);
    expect(parsed.cursor, 'c');
    expect(parsed.files.length, 1);
    expect(parsed.files.single['name'], 'Illam_a.nmbak');
  });

  test('dropboxErrorKind maps 409 insufficient_space vs not_found', () {
    expect(
      DropboxDestination.dropboxErrorKind(409, 'path/insufficient_space/..'),
      DestError.full,
    );
    expect(
      DropboxDestination.dropboxErrorKind(409, 'path/not_found/'),
      isNull,
    );
  });
}
