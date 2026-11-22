import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/domain/avatar_colors.dart';
import 'package:nm_flat/core/domain/home_ids.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/util/ids.dart';

class HomeRepo {
  HomeRepo(this.db, this.changes, this.prefs, this.secure, this.clock);

  final NestDatabase db;
  final ChangeWriter changes;
  final DevicePrefs prefs;
  final SecureStore secure;
  final Clock clock;

  Stream<Home?> watchHome(String homeId) =>
      (db.select(db.homes)
            ..where((h) => h.id.equals(homeId) & h.deleted.equals(false)))
          .watchSingleOrNull();

  Stream<List<Member>> watchMembers(String homeId) =>
      (db.select(db.members)
            ..where(
              (m) =>
                  m.homeId.equals(homeId) &
                  m.deleted.equals(false) &
                  m.status.equals('active'),
            )
            ..orderBy([(m) => OrderingTerm(expression: m.joinedAt)]))
          .watch();

  Stream<Member?> watchMember(String homeId, String memberId) =>
      (db.select(db.members)..where(
            (m) =>
                m.homeId.equals(homeId) &
                m.id.equals(memberId) &
                m.deleted.equals(false),
          ))
          .watchSingleOrNull();

  /// Creates a home on this phone (works offline) and makes it current.
  Future<String> createHome({
    required String creatorName,
    required String homeName,
    required DeviceKeys keys,
    required int createdAt,
    required String nonceB64,
    required String model,
  }) async {
    final full = Names.titleCase(creatorName);
    final name = homeName.trim();
    final genesis = HomeIds.genesisJson(
      homeName: name,
      creatorName: full,
      creatorDeviceId: keys.deviceId,
      signPubB64: keys.signPubB64,
      createdAt: createdAt,
      nonceB64: nonceB64,
    );
    final homeId = await HomeIds.fromGenesis(genesis);
    final memberId = keys.deviceId;

    await secure.write(
      SecureKeys.homeKey(homeId, 'genesis'),
      base64.encode(Ids.randomBytes(32)),
    );

    await changes.write('Created home', (c) {
      c.create('homes', {
        'name': name,
        'vault_id': Ids.hex(Ids.randomBytes(16)),
        'genesis_json': genesis,
        'home_key_id': 'genesis',
      }, id: homeId);
      c.create('members', {
        'full_name': full,
        'first_name': Names.firstName(full),
        'role': 'admin',
        'status': 'active',
        'color': AvatarColors.pick(memberId, {}),
        'device_model': model,
        'joined_at': clock.nowMs,
        'joined_via': 'created',
      }, id: memberId);
    }, homeId: homeId);

    await prefs.setMemberId(memberId);
    await prefs.setCurrentHomeId(homeId);
    return homeId;
  }
}
