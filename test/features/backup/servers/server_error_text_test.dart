import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/features/backup/servers/server_error_text.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

void main() {
  test('serverErrorText maps server destination errors', () {
    final l10n = lookupAppLocalizations(const Locale('en'));

    expect(
      serverErrorText(l10n, DestError.auth, 'WebDAV'),
      'Wrong username or app password',
    );
    expect(
      serverErrorText(l10n, DestError.bucketNotFound, 'S3'),
      'Bucket not found',
    );
    expect(
      serverErrorText(l10n, DestError.other, 'SFTP'),
      'That didn’t work — check the details and try again.',
    );
  });
}
