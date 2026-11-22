import 'dart:convert';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/backup/backup_health.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/features/backup/backup_texts.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

void main() {
  final l = lookupAppLocalizations(const Locale('en'));
  final now = DateTime.utc(2026, 11, 20, 12).millisecondsSinceEpoch;
  const hour = 3600000;
  const day = 24 * hour;
  const devMe = 'devMe';

  const activeMembers = {
    'me': MemberInfo('Anand', true),
    'priya': MemberInfo('Priya', false),
  };

  BackupStatusRow makeRow({
    required String id,
    required String memberId,
    String frequency = 'weekly',
    bool recoveryCapable = true,
    bool offPhone = true,
    required int lastSuccessAt,
    bool deleted = false,
  }) => BackupStatusRow(
    id: id,
    homeId: 'H1',
    deleted: deleted,
    createdAt: lastSuccessAt,
    createdBy: memberId,
    updatedAt: lastSuccessAt,
    updatedBy: memberId,
    memberId: memberId,
    frequency: frequency,
    recoveryCapable: recoveryCapable,
    offPhone: offPhone,
    destsJson: jsonEncode([
      {
        'providerKind': 'folder',
        'lastSuccessAt': lastSuccessAt,
        'lastResult': 'ok',
      },
    ]),
  );

  test('1. no rows -> No backups yet and Not backing up from this phone', () {
    final h = BackupHealth.compute(const [], activeMembers, devMe, now);
    final t = healthTexts(l, h, now);
    expect(t.title, 'No backups yet');
    expect(t.thisPhone, 'Not backing up from this phone — add your own copy');
    expect(t.ok, isFalse);
    expect(t.others, isEmpty);
    expect(t.hint, isNull);
  });

  test('2. my row local folder 1 h ago -> Only on this phone', () {
    final h = BackupHealth.compute(
      [
        makeRow(
          id: devMe,
          memberId: 'me',
          offPhone: false,
          lastSuccessAt: now - hour,
        ),
      ],
      activeMembers,
      devMe,
      now,
    );
    final t = healthTexts(l, h, now);
    expect(t.title, 'Only on this phone — add another place');
    expect(t.thisPhone, 'Backing up from this phone · a folder');
    expect(t.ok, isFalse);
  });

  test('3. Priya off-phone not recovery-capable -> No recovery-ready backup', () {
    final h = BackupHealth.compute(
      [
        makeRow(
          id: 'devPriya',
          memberId: 'priya',
          recoveryCapable: false,
          offPhone: true,
          lastSuccessAt: now - hour,
        ),
      ],
      activeMembers,
      devMe,
      now,
    );
    final t = healthTexts(l, h, now);
    expect(t.title, 'No recovery-ready backup');
  });

  test('4. Priya weekly both true 20 days ago -> No backup in 20 days', () {
    final h = BackupHealth.compute(
      [
        makeRow(
          id: 'devPriya',
          memberId: 'priya',
          frequency: 'weekly',
          recoveryCapable: true,
          offPhone: true,
          lastSuccessAt: now - 20 * day,
        ),
      ],
      activeMembers,
      devMe,
      now,
    );
    final t = healthTexts(l, h, now);
    expect(t.title, 'No backup in 20 days');
  });

  test('5. Priya both true 2 h ago -> Backed up 2 h ago + Also + admin hint', () {
    final h = BackupHealth.compute(
      [
        makeRow(
          id: 'devPriya',
          memberId: 'priya',
          recoveryCapable: true,
          offPhone: true,
          lastSuccessAt: now - 2 * hour,
        ),
      ],
      activeMembers,
      devMe,
      now,
    );
    final t = healthTexts(l, h, now);
    expect(t.ok, isTrue);
    expect(t.title, 'Backed up 2 h ago to a folder · by Priya');
    expect(t.others, ['Also: Priya backs up to a folder (2 h ago)']);
    expect(t.hint, isNotNull);
  });

  test('6. removed member row is ignored -> No backups yet', () {
    final h = BackupHealth.compute(
      [
        makeRow(
          id: 'devRemoved',
          memberId: 'removed',
          recoveryCapable: true,
          offPhone: true,
          lastSuccessAt: now - hour,
        ),
      ],
      activeMembers,
      devMe,
      now,
    );
    final t = healthTexts(l, h, now);
    expect(t.title, 'No backups yet');
  });

  test('7. success 30 s ago -> backupAgo gives just now', () {
    expect(backupAgo(l, now, now - 30 * 1000), 'just now');
  });
}
