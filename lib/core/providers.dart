import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/repo/expenses_repo.dart';
import 'package:nm_flat/core/data/repo/home_repo.dart';
import 'package:nm_flat/core/data/repo/lists_repo.dart';
import 'package:nm_flat/core/data/repo/salary_repo.dart';
import 'package:nm_flat/core/data/repo/staff_repo.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/data/seed/demo_seeder.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';
import 'package:nm_flat/core/ui/snackbar.dart';

final snackbarProvider = Provider((ref) => SnackbarService());
final themeModeProvider = Provider<ThemeMode>((ref) => ThemeMode.system);
final tasksBadgeProvider = Provider<int>((ref) => 0);
final moneyBadgeProvider = Provider<int>((ref) => 0);
final tabScrollControllersProvider = Provider<List<ScrollController>>((ref) {
  final list = List.generate(NestTab.values.length, (_) => ScrollController());
  ref.onDispose(() {
    for (final c in list) {
      c.dispose();
    }
  });
  return list;
});
final clockProvider = Provider<Clock>((ref) => SystemClock());
final prefsProvider = Provider<DevicePrefs>(
  (ref) => throw UnimplementedError(),
); // overridden in main()
final dbProvider = Provider<NestDatabase>(
  (ref) => throw UnimplementedError(),
); // overridden in main()
final currentHomeIdProvider = StreamProvider<String?>(
  (ref) => ref.watch(prefsProvider).currentHomeIdStream(),
);
final registryProvider = Provider(
  (ref) => CollectionRegistry.build(ref.watch(dbProvider)),
);
final hlcProvider = Provider(
  (ref) => HlcClock(ref.watch(clockProvider), ref.watch(prefsProvider)),
);
final changesProvider = Provider(
  (ref) => ChangeWriter(
    ref.watch(dbProvider),
    ref.watch(registryProvider),
    ref.watch(hlcProvider),
    ref.watch(prefsProvider),
  ),
);
final demoSeederProvider = Provider((ref) => DemoSeeder(ref));

final secureStoreProvider = Provider<SecureStore>(
  (ref) => throw UnimplementedError(),
); // overridden in main()
final deviceKeysProvider = FutureProvider<DeviceKeys>(
  (ref) => DeviceKeys.ensure(ref.watch(secureStoreProvider)),
);
final homeRepoProvider = Provider(
  (ref) => HomeRepo(
    ref.watch(dbProvider),
    ref.watch(changesProvider),
    ref.watch(prefsProvider),
    ref.watch(secureStoreProvider),
    ref.watch(clockProvider),
  ),
);
final currentHomeProvider = StreamProvider<Home?>((ref) {
  final id = ref.watch(currentHomeIdProvider).value;
  if (id == null) return Stream.value(null);
  return ref.watch(homeRepoProvider).watchHome(id);
});
final membersProvider = StreamProvider<List<Member>>((ref) {
  final id = ref.watch(currentHomeIdProvider).value;
  if (id == null) return Stream.value(const <Member>[]);
  return ref.watch(homeRepoProvider).watchMembers(id);
});
final myMemberIdProvider = Provider<String>((ref) {
  ref.watch(currentHomeIdProvider);
  final prefs = ref.watch(prefsProvider);
  return prefs.memberId ?? prefs.deviceId;
});
final myMemberProvider = StreamProvider<Member?>((ref) {
  final id = ref.watch(currentHomeIdProvider).value;
  if (id == null) return Stream.value(null);
  final me = ref.watch(myMemberIdProvider);
  return ref.watch(homeRepoProvider).watchMember(id, me);
});

class ViewAsMemberController extends Notifier<bool> {
  @override
  bool build() => ref.read(prefsProvider).getFlag('devViewAsMember');

  Future<void> set(bool v) async {
    state = v;
    await ref.read(prefsProvider).setFlag('devViewAsMember', v);
  }
}

final viewAsMemberProvider = NotifierProvider<ViewAsMemberController, bool>(
  ViewAsMemberController.new,
);

/// Until a later membership service exists, every screen hides admin-only UI with this.
final isAdminProvider = Provider<bool>((ref) {
  final member = ref.watch(myMemberProvider).value;
  final viewingAsMember = kDebugMode && ref.watch(viewAsMemberProvider);
  return member != null && member.role == 'admin' && !viewingAsMember;
});
final staffRepoProvider = Provider(
  (ref) => StaffRepo(
    ref.watch(dbProvider),
    ref.watch(changesProvider),
    ref.watch(clockProvider),
  ),
);
final expensesRepoProvider = Provider(
  (ref) => ExpensesRepo(ref.watch(dbProvider), ref.watch(prefsProvider)),
);
final salaryRepoProvider = Provider(
  (ref) => SalaryRepo(
    ref.watch(dbProvider),
    ref.watch(changesProvider),
    ref.watch(expensesRepoProvider),
    ref.watch(prefsProvider),
  ),
);
final adminNamesProvider = Provider<List<String>>((ref) {
  final members = ref.watch(membersProvider).value ?? const <Member>[];
  final me = ref.watch(myMemberIdProvider);
  return [
    for (final m in members)
      if (m.role == 'admin' && m.status == 'active')
        m.id == me ? 'you' : (m.firstName ?? ''),
  ];
});
final listsRepoProvider = Provider(
  (ref) => ListsRepo(
    ref.watch(dbProvider),
    ref.watch(changesProvider),
    ref.watch(prefsProvider),
    ref.watch(clockProvider),
  ),
);
final listItemsProvider = StreamProvider.family<List<ItemRow>, String>((
  ref,
  list,
) {
  final home = ref.watch(currentHomeIdProvider).value;
  if (home == null) return Stream.value(const <ItemRow>[]);
  return ref.watch(listsRepoProvider).watchItems(home, list);
});
final openItemsProvider = StreamProvider<List<ItemRow>>((ref) {
  final home = ref.watch(currentHomeIdProvider).value;
  if (home == null) return Stream.value(const <ItemRow>[]);
  return ref.watch(listsRepoProvider).watchOpenItems(home);
});
final listHistoryProvider =
    StreamProvider.family<List<ItemHistoryRow>, String>((ref, list) {
      final home = ref.watch(currentHomeIdProvider).value;
      if (home == null) return Stream.value(const <ItemHistoryRow>[]);
      return ref.watch(listsRepoProvider).watchHistory(home, list);
    });
final _usualRowsProvider =
    StreamProvider.family<List<ItemHistoryRow>, String>((ref, list) {
      final home = ref.watch(currentHomeIdProvider).value;
      if (home == null) return Stream.value(const <ItemHistoryRow>[]);
      return ref.watch(listsRepoProvider).watchUsual(home, list);
    });
final usualMapProvider = Provider.family<Map<String, String>, String>((
  ref,
  list,
) {
  final rows = ref.watch(_usualRowsProvider(list)).value ?? const [];
  return {
    for (final h in rows)
      if (h.usualChannel != null) h.nameKey: h.usualChannel!,
  };
});
