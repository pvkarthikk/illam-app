import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Maps a [DestError] from a server destination to a localised user message.
String serverErrorText(AppLocalizations l10n, DestError e, String provider) =>
    switch (e) {
      DestError.unreachable ||
      DestError.untrustedCert => l10n.backupErrUnreachable,
      DestError.auth => l10n.bkSrvErrAuth,
      DestError.noPermission => l10n.backupErrNoPermission,
      DestError.full => l10n.backupReasonFull(provider),
      DestError.bucketNotFound => l10n.bkSrvErrBucket,
      DestError.hostKeyChanged => l10n.bkSrvErrHostKeyChanged,
      DestError.httpsRequired => l10n.bkSrvErrHttps,
      _ => l10n.bkSrvErrOther,
    };
