import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/sync/control_store.dart';

const _dayMs = 24 * 60 * 60 * 1000;

void main() {
  test('drops outbox entries and tombstones older than 90 days on load', () async {
    final secure = MemorySecureStore();
    const now = 200 * _dayMs;
    final store = ControlStore(secure, now: () => now);
    addTearDown(store.dispose);

    const dial = DialInfo(['d1'], {'d1': 'p1'}, ['k1']);
    await store.addOutbox(
      const OutboxEntry('H1', 'opOld', '{}', now - 91 * _dayMs, false, dial),
    );
    await store.addOutbox(
      const OutboxEntry('H2', 'opKeep', '{}', now - 89 * _dayMs, false, dial),
    );
    await store.addTombstone(
      const Tombstone('H1', 'Old', 'deleted', 'A', '{}', now - 91 * _dayMs, false, dial),
    );
    await store.addTombstone(
      const Tombstone('H2', 'New', 'deleted', 'A', '{}', now - 89 * _dayMs, false, dial),
    );

    final pending = await store.allPendingOutbox();
    expect(pending.map((e) => e.opId), ['opKeep']);

    final unshown = await store.unshownTombstones();
    expect(unshown.map((t) => t.homeId), ['H2']);
    expect((await store.tombstonesToPass()).map((t) => t.homeId), ['H2']);
  });

  test('markAcked removes entry from pendingOutbox', () async {
    final secure = MemorySecureStore();
    const now = 1763600000000;
    final store = ControlStore(secure, now: () => now);
    addTearDown(store.dispose);

    await store.addOutbox(
      const OutboxEntry('H1', 'op1', '{}', now, false, DialInfo.empty()),
    );
    expect((await store.pendingOutbox('H1')).length, 1);

    await store.markAcked('op1');
    expect(await store.pendingOutbox('H1'), isEmpty);
    expect(await store.allPendingOutbox(), isEmpty);
  });

  test('markShown removes tombstone from unshownTombstones', () async {
    final secure = MemorySecureStore();
    const now = 1763600000000;
    final store = ControlStore(secure, now: () => now);
    addTearDown(store.dispose);

    await store.addTombstone(
      const Tombstone('H1', 'Flat', 'removed', 'Meera', null, now, false, DialInfo.empty()),
    );
    expect((await store.unshownTombstones()).length, 1);

    await store.markShown('H1');
    expect(await store.unshownTombstones(), isEmpty);
  });
}
