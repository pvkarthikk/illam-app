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
import 'package:nm_flat/core/data/repo/local_membership_service.dart';
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
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/time/hlc.dart';
import 'package:nm_flat/core/ui/snackbar.dart';
import 'package:nm_flat/features/account/appearance_controller.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';

final snackbarProvider = Provider((ref) => SnackbarService());
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
final tasksBadgeProvider = Provider<int>((ref) {
  final routines = ref.watch(routinesProvider).value ?? const <RoutineRow>[];
  final todos = ref.watch(todosProvider).value ?? const <TodoRow>[];
  final today = ref.watch(todayDateProvider);
  return tasksDueCount(
    routines: [
      for (final r in routines)
        (lastDone: r.lastDone, everyDays: r.everyDays),
    ],
    todos: [
      for (final t in todos) (due: t.due, done: t.done),
    ],
    today: today,
  );
});
final moneyBadgeProvider = Provider<int>((ref) {
  final list = ref.watch(billStatusesProvider).value ?? const [];
  return moneyBadgeCount([for (final item in list) item.$2]);
});
final billsDueCountProvider = Provider<int>((ref) {
  final list = ref.watch(billStatusesProvider).value ?? const [];
  return billsDueCount([for (final item in list) item.$2]);
});
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
final membershipServiceProvider = Provider<MembershipService>(
  (ref) => LocalMembershipService(
    ref.watch(dbProvider),
    ref.watch(changesProvider),
    ref.watch(tasksRepoProvider),
    ref.watch(phoneWiperProvider),
    ref.watch(currentHomeIdProvider).value ??
        ref.watch(prefsProvider).currentHomeId ??
        '',
    ref.watch(myMemberIdProvider),
  ),
);
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
  return repo.watchExpensesSince(prevStart).map((rows) => [
    for (final e in rows)
      if (e.billId != null) repo.toSpendLite(e),
  ]);
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
