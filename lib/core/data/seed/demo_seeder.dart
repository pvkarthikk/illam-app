import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/util/device_model.dart';
import 'package:nm_flat/core/util/ids.dart';
import 'package:nm_flat/features/debug/data_lab_controller.dart';

class DemoSeeder {
  DemoSeeder(this.ref);
  final Ref ref;

  /// Each phase adds ONE private method and ONE line here, in this order. Every method is idempotent.
  Future<void> load() async {
    await _seedHomeAndMembers(); // must stay first (creates the home if missing)
    // P04: await _seedStaff();
    // P05: await _seedPay();
    // P06: await _seedItems();
    // P08: await _seedTasks();
    // P09: await _seedMeals();
    // P10: await _seedMoney();
    await _seedDevNotes();
  }

  Future<void> _seedHomeAndMembers() async {
    final prefs = ref.read(prefsProvider);
    final clock = ref.read(clockProvider);
    if (prefs.currentHomeId == null) {
      final keys = await ref.read(deviceKeysProvider.future);
      await ref
          .read(homeRepoProvider)
          .createHome(
            creatorName: 'Anand Kumar',
            homeName: 'Anand Home',
            keys: keys,
            createdAt: clock.nowMs,
            nonceB64: base64.encode(Ids.randomBytes(16)),
            model: await deviceModel(),
          );
    }
    final homeId = prefs.currentHomeId;
    if (homeId == null) return;

    final db = ref.read(dbProvider);
    final existing = await (db.select(
      db.members,
    )..where((m) => m.id.equals('demo-priya'))).getSingleOrNull();
    if (existing != null) return;

    final now = clock.nowMs;
    const day = 86400000;
    await ref.read(changesProvider).write('Demo data', (c) {
      c.create('members', {
        'full_name': 'Priya Anand',
        'first_name': 'Priya',
        'role': 'admin',
        'status': 'active',
        'color': '#34508A',
        'device_model': 'Galaxy S23',
        'joined_at': now - 209 * day,
        'joined_via': 'qr',
        'invited_by': prefs.memberId,
      }, id: 'demo-priya');
      c.create('members', {
        'full_name': 'Arjun Anand',
        'first_name': 'Arjun',
        'role': 'member',
        'status': 'active',
        'color': '#B0412A',
        'device_model': 'Redmi Note 13',
        'joined_at': now - 120 * day,
        'joined_via': 'phrase',
        'invited_by': 'demo-priya',
      }, id: 'demo-arjun');
    }, homeId: homeId);
  }

  Future<void> _seedDevNotes() async {
    final prefs = ref.read(prefsProvider);
    final home = prefs.currentHomeId ?? labHomeId;
    final db = ref.read(dbProvider);
    final existing =
        await (db.select(db.devNotes)
              ..where((n) => n.homeId.equals(home) & n.deleted.equals(false))
              ..limit(1))
            .getSingleOrNull();
    if (existing != null) return;

    await ref.read(changesProvider).write('Demo data', (c) {
      c.create('dev_notes', {'title': 'Milk 2L'});
      c.create('dev_notes', {'title': 'Call plumber'});
      c.create('dev_notes', {'title': 'Pay rent'});
    }, homeId: home);
  }
}
