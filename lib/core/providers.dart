import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show BooleanExpressionOperators, Variable;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/backup_health.dart' as bh;
import 'package:nm_flat/core/backup/recovery_kits.dart';
import 'package:nm_flat/core/backup/snapshot.dart';
import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/crypto/home_key_ring.dart';
import 'package:nm_flat/core/crypto/sign_worker.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/ops/op_applier.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/repo/expenses_repo.dart';
import 'package:nm_flat/core/data/repo/home_eraser.dart';
import 'package:nm_flat/core/data/repo/home_repo.dart';
import 'package:nm_flat/core/data/repo/lists_repo.dart';
import 'package:nm_flat/core/data/repo/local_membership_service.dart';
import 'package:nm_flat/core/data/repo/log_membership_service.dart';
import 'package:nm_flat/core/data/repo/meals_repo.dart';
import 'package:nm_flat/core/data/repo/membership_service.dart';
import 'package:nm_flat/core/data/repo/money_repo.dart';
import 'package:nm_flat/core/data/repo/recipes_repo.dart';
import 'package:nm_flat/core/data/repo/salary_repo.dart';
import 'package:nm_flat/core/data/repo/staff_repo.dart';
import 'package:nm_flat/core/data/repo/tasks_repo.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/data/seed/demo_seeder.dart';
import 'package:nm_flat/core/data/wipe.dart';
import 'package:nm_flat/core/design/nest_colors.dart';
import 'package:nm_flat/core/domain/bills.dart';
import 'package:nm_flat/core/domain/duplicate_hint.dart';
import 'package:nm_flat/core/domain/money_math.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/domain/routine_state.dart';
import 'package:nm_flat/core/domain/salary_months.dart';
import 'package:nm_flat/core/domain/sync_status.dart';
import 'package:nm_flat/core/gmail/gmail_import_config.dart';
import 'package:nm_flat/core/gmail/gmail_invoice_scanner.dart';
import 'package:nm_flat/core/gmail/gmail_loopback_auth.dart'
    if (dart.library.js_interop) 'package:nm_flat/core/gmail/gmail_loopback_auth_web.dart';
import 'package:nm_flat/core/gmail/gmail_rest_client.dart';
import 'package:nm_flat/core/gmail/pdf_text_extractor.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/sync/control_store.dart';
import 'package:nm_flat/core/sync/incoming.dart';
import 'package:nm_flat/core/sync/key_rotation.dart';
import 'package:nm_flat/core/sync/membership_log.dart';
import 'package:nm_flat/core/sync/op_ignored_notifier.dart';
import 'package:nm_flat/core/sync/protocol/op_wire.dart';
import 'package:nm_flat/core/sync/remote/firebase_rest_client.dart';
import 'package:nm_flat/core/sync/remote/remote_sync_config.dart';
import 'package:nm_flat/core/sync/remote/remote_sync_engine.dart';
import 'package:nm_flat/core/sync/sync_engine.dart';
import 'package:nm_flat/core/sync/sync_reactions.dart';
import 'package:nm_flat/core/sync/sync_store.dart';
import 'package:nm_flat/core/sync/validator.dart';
import 'package:nm_flat/core/sync/version_vector.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/time/hlc.dart';
import 'package:nm_flat/core/ui/snackbar.dart';
import 'package:nm_flat/features/account/appearance_controller.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

String rejectText(String reason) {
  final l = lookupAppLocalizations(const Locale('en'));
  final text = switch (reason) {
    'adminOnly' => l.syncReasonAdminOnly,
    'ownOnly' => l.syncReasonOwnOnly,
    'tooOld' => l.syncReasonTooOld,
    'lastAdmin' => l.syncReasonLastAdmin,
    _ => l.syncReasonOther,
  };
  return l.syncChangeNotApplied(text);
}

final snackbarProvider = Provider((ref) => SnackbarService());
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
final _routineClocksProvider =
    StreamProvider<List<({String lastDone, int everyDays})>>((ref) {
      final home = ref.watch(currentHomeIdProvider).value;
      if (home == null) return Stream.value(const []);
      return ref.watch(tasksRepoProvider).watchRoutineClocks(home);
    });
final _openTodoDuesProvider = StreamProvider<List<({String due, bool done})>>((
  ref,
) {
  final home = ref.watch(currentHomeIdProvider).value;
  if (home == null) return Stream.value(const []);
  return ref.watch(tasksRepoProvider).watchOpenTodoDues(home);
});
final tasksBadgeProvider = Provider<int>((ref) {
  final routines = ref.watch(_routineClocksProvider).value ?? const [];
  final todos = ref.watch(_openTodoDuesProvider).value ?? const [];
  final today = ref.watch(todayDateProvider);
  return tasksDueCount(routines: routines, todos: todos, today: today);
});
// One shared recount of the bill statuses feeds both badges.
final _billBadgesProvider = Provider<({int money, int due})>((ref) {
  final list = ref.watch(billStatusesProvider).value ?? const [];
  final statuses = <BillStatus>[for (final item in list) item.$2];
  return (money: moneyBadgeCount(statuses), due: billsDueCount(statuses));
});
final moneyBadgeProvider = Provider<int>(
  (ref) => ref.watch(_billBadgesProvider.select((b) => b.money)),
);
final billsDueCountProvider = Provider<int>(
  (ref) => ref.watch(_billBadgesProvider.select((b) => b.due)),
);
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
class CurrentHomeIdController extends AsyncNotifier<String?> {
  @override
  FutureOr<String?> build() {
    final prefs = ref.watch(prefsProvider);
    final sub = prefs.currentHomeIdStream().skip(1).listen((id) {
      state = AsyncData(id);
    });
    ref.onDispose(sub.cancel);
    return prefs.currentHomeId;
  }
}

final currentHomeIdProvider =
    AsyncNotifierProvider<CurrentHomeIdController, String?>(
      CurrentHomeIdController.new,
    );
final registryProvider = Provider(
  (ref) => CollectionRegistry.build(ref.watch(dbProvider)),
);
final hlcProvider = Provider(
  (ref) => HlcClock(ref.watch(clockProvider), ref.watch(prefsProvider)),
);
final changesProvider = Provider((ref) {
  final snackbar = ref.watch(snackbarProvider);
  return ChangeWriter(
    ref.watch(dbProvider),
    ref.watch(registryProvider),
    ref.watch(hlcProvider),
    ref.watch(prefsProvider),
    validator: const Validator(),
    signer: ref.watch(opSignerProvider),
    clock: ref.watch(clockProvider),
    onRejected: (reason) => snackbar.show(rejectText(reason)),
  );
});
final demoSeederProvider = Provider((ref) => DemoSeeder(ref));

final secureStoreProvider = Provider<SecureStore>(
  (ref) => throw UnimplementedError(),
); // overridden in main()
final deviceKeysProvider = FutureProvider<DeviceKeys>(
  (ref) => DeviceKeys.ensure(ref.watch(secureStoreProvider)),
);
final opSignerProvider = Provider((ref) {
  final keys = ref.watch(deviceKeysProvider.future);
  final worker = SignWorker(keys);
  ref.onDispose(worker.dispose);
  return OpSigner(keys, worker: worker);
});
final controlStoreProvider = Provider<ControlStore>((ref) {
  final store = ControlStore(
    ref.watch(secureStoreProvider),
    now: () => ref.watch(clockProvider).nowMs,
  );
  ref.onDispose(() => unawaited(store.dispose()));
  return store;
});
final homeEraserProvider = Provider<HomeEraser>(
  (ref) => HomeEraser(
    ref.watch(dbProvider),
    ref.watch(registryProvider),
    ref.watch(prefsProvider),
    ref.watch(homeKeyRingProvider),
    ref.watch(controlStoreProvider),
    ref.watch(clockProvider),
  ),
);
final homeGoneProvider = StreamProvider<Tombstone?>((ref) async* {
  final store = ref.watch(controlStoreProvider);
  yield (await store.unshownTombstones()).firstOrNull;
  await for (final _ in store.changes) {
    yield (await store.unshownTombstones()).firstOrNull;
  }
});
final Provider<MembershipLog> membershipLogProvider = Provider<MembershipLog>((ref) {
  final log = MembershipLog(
    ref.watch(dbProvider),
    ref.watch(deviceKeysProvider.future),
    ref.watch(hlcProvider),
    ref.watch(clockProvider),
  );
  log.onReplayed = (s) async {
    final homeId = log.lastReplayedHomeId;
    if (homeId == null) return;
    final me = (await ref.read(deviceKeysProvider.future)).deviceId;
    await ref.read(opIgnoredProvider).check(s, me);
    await ref.read(keyRotationProvider).afterReplay(s, me: me, homeId: homeId);
  };
  return log;
});
final syncStoreProvider = Provider((ref) => SyncStore(ref.watch(dbProvider)));
final syncReactionsProvider = Provider((ref) {
  final reactions = SyncReactions(
    ref.watch(dbProvider),
    ref.watch(prefsProvider),
  );
  ref.watch(membershipLogProvider).onMemberJoined = reactions.memberJoined;
  return reactions;
});
final incomingProvider = Provider((ref) {
  final db = ref.watch(dbProvider);
  final registry = ref.watch(registryProvider);
  final reactions = ref.watch(syncReactionsProvider);
  return IncomingPipeline(
    db: db,
    registry: registry,
    applier: OpApplier(db, registry),
    membership: ref.watch(membershipLogProvider),
    hlc: ref.watch(hlcProvider),
    clock: ref.watch(clockProvider),
    onApplied: reactions.onApplied,
    afterIngest: reactions.flush,
  );
});
final syncEngineProvider = Provider((ref) {
  final homeId = ref.watch(currentHomeIdProvider).value;
  final membership = ref.watch(membershipLogProvider);
  final engine = SyncEngine(
    db: ref.watch(dbProvider),
    prefs: ref.watch(prefsProvider),
    secure: ref.watch(secureStoreProvider),
    keys: ref.watch(deviceKeysProvider.future),
    membership: membership,
    incoming: ref.watch(incomingProvider),
    clock: ref.watch(clockProvider),
    homeId: homeId,
    controlStore: ref.watch(controlStoreProvider),
    homeEraser: ref.watch(homeEraserProvider),
  );
  membership.onAppended = () {
    engine.onLocalChange();
    ref.read(remoteSyncEngineProvider).onLocalChange();
  };
  ref.onDispose(() => unawaited(engine.dispose()));
  return engine;
});
final syncEngineStateProvider = StreamProvider<SyncEngineState>((ref) async* {
  final engine = ref.watch(syncEngineProvider);
  yield engine.state;
  yield* engine.states;
});
final remoteSyncConfigStoreProvider = Provider<RemoteSyncConfigStore>((ref) {
  final store = RemoteSyncConfigStore(ref.watch(secureStoreProvider));
  ref.onDispose(() => unawaited(store.dispose()));
  return store;
});
final remoteSyncConfigProvider = StreamProvider<RemoteSyncConfig>((ref) async* {
  final homeId = ref.watch(currentHomeIdProvider).value;
  if (homeId == null) {
    yield RemoteSyncConfig.empty();
    return;
  }
  final store = ref.watch(remoteSyncConfigStoreProvider);
  yield await store.load(homeId);
  await for (final changed in store.changes) {
    if (changed == homeId) {
      yield await store.load(homeId);
    }
  }
});
final firebaseRestClientProvider = Provider<FirebaseRestClient>(
  (ref) => FirebaseRestClient(),
);
final remoteSyncEngineProvider = Provider<RemoteSyncEngine>((ref) {
  final homeId = ref.watch(currentHomeIdProvider).value;
  final engine = RemoteSyncEngine(
    db: ref.watch(dbProvider),
    prefs: ref.watch(prefsProvider),
    secure: ref.watch(secureStoreProvider),
    keys: ref.watch(deviceKeysProvider.future),
    membership: ref.watch(membershipLogProvider),
    incoming: ref.watch(incomingProvider),
    clock: ref.watch(clockProvider),
    homeId: homeId,
    configStore: ref.watch(remoteSyncConfigStoreProvider),
    client: ref.watch(firebaseRestClientProvider),
  );
  ref.onDispose(() => unawaited(engine.dispose()));
  return engine;
});
final remoteSyncStateProvider = StreamProvider<RemoteSyncState>((ref) async* {
  final engine = ref.watch(remoteSyncEngineProvider);
  yield engine.state;
  yield* engine.states;
});
final gmailImportStoreProvider = Provider<GmailImportStore>((ref) {
  final store = GmailImportStore(ref.watch(secureStoreProvider));
  ref.onDispose(() => unawaited(store.dispose()));
  return store;
});
final gmailImportConfigProvider = StreamProvider<GmailImportConfig>((ref) async* {
  final homeId = ref.watch(currentHomeIdProvider).value;
  if (homeId == null) {
    yield GmailImportConfig.empty();
    return;
  }
  final store = ref.watch(gmailImportStoreProvider);
  yield* store.watch(homeId);
});
final gmailDraftOrdersProvider = Provider<List<DraftExpenseOrder>>((ref) {
  final cfg = ref.watch(gmailImportConfigProvider).value;
  if (cfg == null || !cfg.enabled) return const [];
  return cfg.drafts;
});
final gmailRestClientProvider = Provider<GmailRestClient>(
  (ref) => GmailRestClient(nowMs: () => ref.read(clockProvider).nowMs),
);
final pdfTextExtractorProvider = Provider<PdfTextExtractor>(
  (ref) => const MethodChannelPdfTextExtractor(),
);
final gmailInvoiceScannerProvider = Provider<GmailInvoiceScanner>(
  (ref) => GmailInvoiceScanner(
    client: ref.watch(gmailRestClientProvider),
    pdfExtractor: ref.watch(pdfTextExtractorProvider),
    nowMs: () => ref.read(clockProvider).nowMs,
  ),
);
final gmailLoopbackAuthProvider = Provider<GmailLoopbackAuthenticator>((ref) {
  final auth = GmailLoopbackAuthenticator();
  ref.onDispose(() => unawaited(auth.cancel()));
  return auth;
});
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) async* {
  try {
    final c = Connectivity();
    yield await c.checkConnectivity();
    yield* c.onConnectivityChanged;
  } on Object {
    yield const <ConnectivityResult>[];
  }
});
final isOfflineProvider = Provider<bool>((ref) {
  final list = ref.watch(connectivityProvider).value;
  if (list == null || list.isEmpty) return false;
  return list.every((r) => r == ConnectivityResult.none);
});
final syncPeersProvider = StreamProvider<List<SyncPeerRow>>((ref) {
  final home = ref.watch(currentHomeIdProvider).value;
  if (home == null) return Stream.value(const <SyncPeerRow>[]);
  return ref.watch(syncStoreProvider).watchPeers(home);
});
final memberDevicesProvider = StreamProvider<List<DeviceInfo>>((ref) {
  final home = ref.watch(currentHomeIdProvider).value;
  if (home == null) return Stream.value(const <DeviceInfo>[]);
  final db = ref.watch(dbProvider);
  return db
      .customSelect(
        'SELECT d.device_id, d.member_id, m.first_name, m.full_name, d.model '
        'FROM member_devices d '
        'LEFT JOIN members m ON m.id = d.member_id AND m.home_id = d.home_id '
        'WHERE d.home_id = ? AND d.active = 1',
        variables: [Variable.withString(home)],
        readsFrom: {db.memberDevices, db.members},
      )
      .watch()
      .map(
        (rows) => [
          for (final r in rows)
            DeviceInfo(
              r.data['device_id'] as String,
              r.data['member_id'] as String,
              ((r.data['first_name'] as String?)?.isNotEmpty ?? false)
                  ? r.data['first_name'] as String
                  : ((r.data['full_name'] as String?) ?? ''),
              (r.data['model'] as String?) ?? '',
            ),
        ],
      );
});
final opsTickProvider = StreamProvider<int>((ref) {
  final home = ref.watch(currentHomeIdProvider).value;
  if (home == null) return Stream.value(0);
  final db = ref.watch(dbProvider);
  return db
      .customSelect(
        'SELECT COUNT(*) AS n FROM ops WHERE home_id = ?',
        variables: [Variable.withString(home)],
        readsFrom: {db.ops},
      )
      .watchSingle()
      .map((r) => r.data['n'] as int);
});
final localChangeTickProvider = StreamProvider<int>((ref) {
  final controller = StreamController<int>();
  Timer? timer;
  var tick = 0;
  final sub = ref.watch(changesProvider).changed.listen((_) {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 2), () {
      if (!controller.isClosed) {
        controller.add(++tick);
      }
    });
  });
  ref.onDispose(() {
    timer?.cancel();
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});
final syncSummaryProvider = FutureProvider<SyncSummary>((ref) async {
  final home = ref.watch(currentHomeIdProvider).value;
  if (home == null) {
    return const SyncSummary([], 0, 0, null, false);
  }
  final devices = await ref.watch(memberDevicesProvider.future);
  final peers = await ref.watch(syncPeersProvider.future);
  final engineState =
      ref.watch(syncEngineStateProvider).value ?? const SyncEngineState();
  ref.watch(localChangeTickProvider);

  final store = ref.watch(syncStoreProvider);
  final keys = await ref.watch(deviceKeysProvider.future);
  final myVector = await store.myVector(home);
  final myMemberOps = await store.memberOpCount(home);

  final acks = <String, PeerAck>{};
  for (final p in peers) {
    final decoded = jsonDecode(p.ackedVectorJson) as Map<String, Object?>;
    acks[p.deviceId] = PeerAck(
      vector: VersionVector.fromJson(decoded),
      memberOps: p.ackedMemberOps,
      lastSyncAt: p.lastSyncAt,
      clockSkewMs: p.clockSkewMs,
    );
  }

  return computeSyncSummary(
    myDeviceId: keys.deviceId,
    devices: devices,
    acks: acks,
    myVector: myVector,
    myMemberOps: myMemberOps,
    connected: engineState.connected,
    nowMs: ref.read(clockProvider).nowMs,
  );
});
final homeRepoProvider = Provider(
  (ref) => HomeRepo(
    ref.watch(dbProvider),
    ref.watch(changesProvider),
    ref.watch(prefsProvider),
    ref.watch(secureStoreProvider),
    ref.watch(clockProvider),
    membershipLog: ref.watch(membershipLogProvider),
  ),
);
final currentHomeProvider = StreamProvider<Home?>((ref) {
  final id = ref.watch(currentHomeIdProvider).value;
  if (id == null) return Stream.value(null);
  return ref.watch(homeRepoProvider).watchHome(id);
});
final startupProvider = FutureProvider<void>((ref) async {
  final home = await ref.watch(currentHomeProvider.future);
  if (home != null) {
    await ref
        .read(membershipLogProvider)
        .ensureGenesis(home.id, home.genesisJson);
  }
});
final membershipServiceProvider = Provider<MembershipService>((ref) {
  final homeId =
      ref.watch(currentHomeIdProvider).value ??
      ref.watch(prefsProvider).currentHomeId ??
      '';
  final myMemberId = ref.watch(myMemberIdProvider);
  final changes = ref.watch(changesProvider);
  final tasks = ref.watch(tasksRepoProvider);
  final local = LocalMembershipService(
    ref.watch(dbProvider),
    changes,
    tasks,
    ref.watch(phoneWiperProvider),
    homeId,
    myMemberId,
  );
  return LogMembershipService(
    local,
    ref.watch(membershipLogProvider),
    changes,
    tasks,
    homeId,
    myMemberId,
    keyRotation: ref.watch(keyRotationProvider),
    keyRing: ref.watch(homeKeyRingProvider),
    controlStore: ref.watch(controlStoreProvider),
    homeEraser: ref.watch(homeEraserProvider),
    closeSessionsWith: (ids) =>
        ref.read(syncEngineProvider).closeSessionsWith(ids),
    clock: ref.watch(clockProvider),
  );
});
final membersProvider = StreamProvider<List<Member>>((ref) {
  final id = ref.watch(currentHomeIdProvider).value;
  if (id == null) return Stream.value(const <Member>[]);
  return ref.watch(membershipServiceProvider).members();
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
final tasksRepoProvider = Provider(
  (ref) => TasksRepo(
    ref.watch(dbProvider),
    ref.watch(changesProvider),
    ref.watch(prefsProvider),
  ),
);
final routinesProvider = StreamProvider<List<RoutineRow>>((ref) {
  final home = ref.watch(currentHomeIdProvider).value;
  if (home == null) return Stream.value(const <RoutineRow>[]);
  return ref.watch(tasksRepoProvider).watchRoutines(home);
});
final todosProvider = StreamProvider<List<TodoRow>>((ref) {
  final home = ref.watch(currentHomeIdProvider).value;
  if (home == null) return Stream.value(const <TodoRow>[]);
  return ref.watch(tasksRepoProvider).watchTodos(home);
});
final doneTodosProvider = StreamProvider<List<TodoRow>>((ref) {
  final home = ref.watch(currentHomeIdProvider).value;
  if (home == null) return Stream.value(const <TodoRow>[]);
  return ref.watch(tasksRepoProvider).watchDoneTodos(home);
});
final taskPeopleProvider = Provider<AsyncValue<List<TaskPerson>>>((ref) {
  final mAsync = ref.watch(membersProvider);
  final sAsync = ref.watch(activeStaffProvider);
  if (mAsync case AsyncError(:final error, :final stackTrace)) {
    return AsyncError(error, stackTrace);
  }
  if (sAsync case AsyncError(:final error, :final stackTrace)) {
    return AsyncError(error, stackTrace);
  }
  if (mAsync is! AsyncData<List<Member>> ||
      sAsync is! AsyncData<List<StaffData>>) {
    return const AsyncLoading();
  }
  final me = ref.watch(myMemberIdProvider);
  final activeMembers = [
    for (final m in mAsync.value)
      if (m.status == 'active') m,
  ];
  Color colorOf(String? hex) => NestPalette.fromHex(
    (hex == null || hex.isEmpty) ? '#4F8A8B' : hex,
  );
  TaskPerson memberPerson(Member m) => TaskPerson(
    id: m.id,
    type: 'member',
    firstName: m.firstName ?? '',
    color: colorOf(m.color),
    isMe: m.id == me,
  );
  return AsyncData([
    for (final m in activeMembers)
      if (m.id == me) memberPerson(m),
    for (final m in activeMembers)
      if (m.id != me) memberPerson(m),
    for (final s in sAsync.value)
      TaskPerson(
        id: s.id,
        type: 'staff',
        firstName: Names.firstName(s.name ?? ''),
        color: colorOf(s.color),
      ),
  ]);
});
final taskPeopleByIdProvider = Provider<Map<String, TaskPerson>>((ref) {
  final people = ref.watch(taskPeopleProvider).value ?? const <TaskPerson>[];
  return {for (final p in people) p.id: p};
});

final moneyRepoProvider = Provider<MoneyRepo>(
  (ref) => MoneyRepo(
    ref.watch(dbProvider),
    ref.watch(changesProvider),
    ref.watch(expensesRepoProvider),
    ref.watch(currentHomeIdProvider).value ??
        ref.watch(prefsProvider).currentHomeId ??
        '',
    ref.watch(myMemberIdProvider),
  ),
);

final merchantRulesProvider = StreamProvider<Map<String, String>>(
  (ref) => ref.watch(moneyRepoProvider).watchMerchantRules(),
);

final billsProvider = StreamProvider<List<Bill>>(
  (ref) => ref.watch(moneyRepoProvider).watchBills(),
);

final monthExpensesProvider = StreamProvider.family<List<ExpenseRow>, String>(
  (ref, month) => ref.watch(moneyRepoProvider).watchExpensesInMonth(month),
);

final recentSpendsProvider = StreamProvider<List<ExpenseRow>>((ref) {
  final today = ref.watch(todayDateProvider);
  final fromIso = Dates.addDays(today, -90);
  return ref.watch(moneyRepoProvider).watchExpensesSince(fromIso);
});

final billPaymentsProvider = StreamProvider<List<SpendLite>>((ref) {
  final today = ref.watch(todayDateProvider);
  final prevStart = Dates.monthStart(prevMonth(Dates.month(today)));
  final repo = ref.watch(moneyRepoProvider);
  return repo
      .watchBillPaymentsSince(prevStart)
      .map((rows) => [for (final e in rows) repo.toSpendLite(e)]);
});

final billStatusesProvider = FutureProvider<List<(Bill, BillStatus)>>((
  ref,
) async {
  final bills = await ref.watch(billsProvider.future);
  final payments = await ref.watch(billPaymentsProvider.future);
  final today = ref.watch(todayDateProvider);
  final byBill = <String, List<SpendLite>>{};
  for (final p in payments) {
    final id = p.billId;
    if (id != null) {
      (byBill[id] ??= []).add(p);
    }
  }
  final out = <(Bill, BillStatus)>[
    for (final b in bills)
      if (b.active)
        (
          b,
          billStatus(
            firstDueMonth: b.firstDueMonth,
            dueDay: b.dueDay,
            payments: byBill[b.id] ?? const [],
            today: today,
          ),
        ),
  ];
  out.sort((a, b) => compareBills(a.$2, a.$1.name, b.$2, b.$1.name));
  return out;
});

final monthSpentProvider = Provider<int>((ref) {
  final today = ref.watch(todayDateProvider);
  final month = Dates.month(today);
  final rows = ref.watch(monthExpensesProvider(month)).value;
  if (rows == null) return 0;
  final repo = ref.watch(moneyRepoProvider);
  final dupAttempts =
      ref.watch(duplicateSalaryAttemptIdsProvider).value ?? const <String>{};
  final lites = [for (final r in rows) repo.toSpendLite(r)];
  final excluded = duplicateSalaryExpenseIds(rows, dupAttempts);
  return monthTotal(lites, month, excluded);
});

final budgetPaiseProvider = Provider<int?>((ref) {
  final budget = ref.watch(currentHomeProvider).value?.budgetMonthlyPaise;
  return (budget == null || budget <= 0) ? null : budget;
});

final recipesRepoProvider = Provider<RecipesRepo>(
  (ref) => RecipesRepo(
    ref.watch(dbProvider),
    ref.watch(changesProvider),
    ref.watch(currentHomeIdProvider).value ??
        ref.watch(prefsProvider).currentHomeId ??
        '',
  ),
);

final mealsRepoProvider = Provider<MealsRepo>(
  (ref) => MealsRepo(
    ref.watch(dbProvider),
    ref.watch(changesProvider),
    ref.watch(prefsProvider),
    ref.watch(currentHomeIdProvider).value ??
        ref.watch(prefsProvider).currentHomeId ??
        '',
  ),
);

final recipesProvider = StreamProvider<List<RecipeView>>(
  (ref) => ref.watch(recipesRepoProvider).watchAll(),
);

final recipeProvider = StreamProvider.family<RecipeView?, String>(
  (ref, id) => ref.watch(recipesRepoProvider).watchOne(id),
);

final weekSlotsProvider = StreamProvider.family<List<MealSlot>, String>(
  (ref, mondayIso) => ref
      .watch(mealsRepoProvider)
      .watchRange(mondayIso, Dates.addDays(mondayIso, 6)),
);

final pantryKeysProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(mealsRepoProvider).watchPantryInStock(),
);

final openGroceryKeysProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(mealsRepoProvider).watchOpenGroceryKeys(),
);

final backupConfigStoreProvider = Provider<BackupConfigStore>(
  (ref) => BackupConfigStore(ref.watch(secureStoreProvider)),
);

final recoveryKitsProvider = Provider<RecoveryKits>(
  (ref) => RecoveryKits(
    ref.watch(backupConfigStoreProvider),
    ref.watch(membershipLogProvider),
    ref.watch(deviceKeysProvider.future),
    ref.watch(prefsProvider),
  ),
);

final snapshotBuilderProvider = Provider<SnapshotBuilder>(
  (ref) => SnapshotBuilder(
    ref.watch(dbProvider),
    ref.watch(membershipLogProvider),
    ref.watch(homeKeyRingProvider),
    ref.watch(prefsProvider),
    ref.watch(deviceKeysProvider.future),
    ref.watch(backupConfigStoreProvider),
    ref.watch(recoveryKitsProvider),
  ),
);

final snapshotImporterProvider = Provider<SnapshotImporter>(
  (ref) => SnapshotImporter(
    ref.watch(membershipLogProvider),
    ref.watch(incomingProvider),
    ref.watch(homeKeyRingProvider),
    ref.watch(homeEraserProvider),
  ),
);

final backupHealthProvider = StreamProvider<bh.BackupHealth>((ref) {
  final home = ref.watch(currentHomeIdProvider).value;
  if (home == null) {
    return Stream.value(const bh.BackupHealth(state: bh.HealthState.none));
  }
  final db = ref.watch(dbProvider);
  final prefs = ref.watch(prefsProvider);
  final clock = ref.watch(clockProvider);
  final members = ref.watch(membersProvider).value ?? const <Member>[];
  ref.watch(minuteTickProvider);
  final activeMembers = <String, bh.MemberInfo>{
    for (final m in members)
      if (m.status == 'active')
        m.id: bh.MemberInfo(
          (m.firstName != null && m.firstName!.isNotEmpty)
              ? m.firstName!
              : (m.fullName ?? ''),
          m.role == 'admin',
        ),
  };
  return (db.select(
        db.backupStatus,
      )..where((b) => b.homeId.equals(home) & b.deleted.equals(false)))
      .watch()
      .map(
        (rows) => bh.BackupHealth.compute(
          rows,
          activeMembers,
          prefs.deviceId,
          clock.nowMs,
        ),
      );
});
