import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
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
