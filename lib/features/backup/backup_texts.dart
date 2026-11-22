import 'package:nm_flat/core/backup/backup_health.dart';
import 'package:nm_flat/core/domain/sync_status.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

String backupAgo(AppLocalizations l, int nowMs, int thenMs) {
  final (unit, n) = agoParts(nowMs, thenMs);
  return switch (unit) {
    AgoUnit.now => l.backupJustNow,
    AgoUnit.minutes => l.agoMinutes(n),
    AgoUnit.hours => l.agoHours(n),
    AgoUnit.days => l.agoDays(n),
  };
}

String providerShort(AppLocalizations l, String kind) => switch (kind) {
  'folder' => l.backupProviderFolderShort,
  'gdrive' => l.backupProvGdrive,
  'onedrive' => l.backupProvOnedrive,
  'dropbox' => l.backupProvDropbox,
  'pcloud' => l.backupProvPcloud,
  'webdav' => l.backupProvWebdav,
  'nextcloud' => l.backupProvNextcloud,
  's3' => l.backupProvS3,
  'sftp' => l.backupProvSftp,
  _ => kind,
};

String providerTitle(AppLocalizations l, String kind) => switch (kind) {
  'folder' => l.backupProvFolder,
  'gdrive' => l.backupProvGdrive,
  'onedrive' => l.backupProvOnedrive,
  'dropbox' => l.backupProvDropbox,
  'pcloud' => l.backupProvPcloud,
  'webdav' => l.backupProvWebdav,
  'nextcloud' => l.backupProvNextcloud,
  's3' => l.backupProvS3,
  'sftp' => l.backupProvSftp,
  _ => kind,
};

({String title, bool ok, String thisPhone, List<String> others, String? hint})
healthTexts(AppLocalizations l, BackupHealth h, int nowMs) {
  final ok = h.state == HealthState.ok;
  final okRow = h.okRow;
  final title = switch (h.state) {
    HealthState.ok when okRow != null => l.backupHealthOk(
      backupAgo(l, nowMs, okRow.lastSuccessAt),
      providerShort(l, okRow.providerKind),
      okRow.name,
    ),
    HealthState.ok || HealthState.none => l.homeBackupNone,
    HealthState.onlyOnPhone => l.backupOnlyOnPhone,
    HealthState.noRecoveryReady => l.backupNoRecoveryReady,
    HealthState.stale => l.backupNoBackupDays(h.staleDays),
  };

  final mine = h.mine;
  final thisPhone = mine != null
      ? l.backupThisPhoneOn(providerShort(l, mine.providerKind))
      : l.homeBackupNotThisPhone;

  final others = [
    for (final row in h.others)
      l.backupAlso(
        row.name,
        providerShort(l, row.providerKind),
        backupAgo(l, nowMs, row.lastSuccessAt),
      ),
  ];

  final hint = h.noAdminHint ? l.backupNoAdminHint : null;

  return (
    title: title,
    ok: ok,
    thisPhone: thisPhone,
    others: others,
    hint: hint,
  );
}
