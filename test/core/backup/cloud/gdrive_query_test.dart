import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/backup/cloud/gdrive_destination.dart';

void main() {
  test('nameQuery formats unescaped filename', () {
    expect(
      GdriveDestination.nameQuery('NestMojo_a.nmbak'),
      "name = 'NestMojo_a.nmbak' and trashed = false",
    );
  });

  test('nameQuery escapes backslashes and single quotes', () {
    expect(
      GdriveDestination.nameQuery(r"a'b\c.nmbak"),
      r"name = 'a\'b\\c.nmbak' and trashed = false",
    );
  });
}
