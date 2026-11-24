import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/backup/cloud/onedrive_destination.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';

void main() {
  test('parseChildren skips folders and returns @odata.nextLink', () {
    final parsed = OneDriveDestination.parseChildren(const {
      'value': [
        {'id': '1', 'name': 'Illam_a.nmbak', 'size': 10},
        {'id': '2', 'name': 'Sub', 'folder': <String, Object?>{}},
      ],
      '@odata.nextLink': 'https://next',
    });

    expect(parsed.files.length, 1);
    expect(parsed.files.single['name'], 'Illam_a.nmbak');
    expect(parsed.nextLink, 'https://next');
  });

  test('graphErrorKind maps status and error code', () {
    expect(OneDriveDestination.graphErrorKind(507, null), DestError.full);
    expect(
      OneDriveDestination.graphErrorKind(403, 'accessDenied'),
      DestError.noPermission,
    );
  });
}
