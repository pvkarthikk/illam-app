import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';

void main() {
  test('saves and loads BackupConfig with destination and returns defaults when missing', () async {
    final secure = MemorySecureStore();
    final store = BackupConfigStore(secure);

    final missing = await store.load('NM-NONE');
    expect(missing.frequency, 'weekly');
    expect(missing.wifiOnly, isTrue);
    expect(missing.chargingOnly, isTrue);
    expect(missing.keep, 10);
    expect(missing.destinations, isEmpty);

    final cfg = BackupConfig(
      destinations: [
        DestinationConfig(
          destId: 'dest-1',
          kind: 'folder',
          label: 'Documents/Illam',
          settings: {'treeUri': 'content://com.android.externalstorage.documents/tree/primary%3ADocs'},
          lastSuccessAt: 1763600000000,
          lastResult: 'ok',
          keptCount: 2,
          failures: 0,
          lastCommittedHeads: 'abc',
          lastFullName: 'Illam_aaaaaaaa_20261120-000000Z_bbbbbbbb.nmbak',
        ),
      ],
      password: 'correct horse',
      passwordSetAt: 1763600000000,
      frequency: 'daily',
      wifiOnly: false,
      chargingOnly: false,
      keep: 5,
    );

    await store.save('NM-H1', cfg);
    final loaded = await store.load('NM-H1');
    expect(loaded.password, 'correct horse');
    expect(loaded.frequency, 'daily');
    expect(loaded.wifiOnly, isFalse);
    expect(loaded.chargingOnly, isFalse);
    expect(loaded.keep, 5);
    expect(loaded.destinations.length, 1);
    expect(loaded.destinations.single.destId, 'dest-1');
    expect(loaded.destinations.single.kind, 'folder');
    expect(loaded.destinations.single.label, 'Documents/Illam');
    expect(
      loaded.destinations.single.settings['treeUri'],
      'content://com.android.externalstorage.documents/tree/primary%3ADocs',
    );
    expect(loaded.destinations.single.lastResult, 'ok');

    await store.delete('NM-H1');
    expect((await store.load('NM-H1')).destinations, isEmpty);
  });
}
