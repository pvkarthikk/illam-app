import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/nav/shell_scaffold.dart';
import 'package:nm_flat/features/account/home_members_screen.dart';
import 'package:nm_flat/features/account/profile_screen.dart';
import 'package:nm_flat/features/backup/backup_screen.dart';
import 'package:nm_flat/features/debug/backup_lab_screen.dart';
import 'package:nm_flat/features/debug/data_lab_screen.dart';
import 'package:nm_flat/features/debug/debug_screen.dart';
import 'package:nm_flat/features/debug/gallery_screen.dart';
import 'package:nm_flat/features/debug/sync_lab_screen.dart';
import 'package:nm_flat/features/gmail_import/gmail_import_screen.dart';
import 'package:nm_flat/features/invite/invite_screen.dart';
import 'package:nm_flat/features/lists/lists_screen.dart';
import 'package:nm_flat/features/meals/cook_screen.dart';
import 'package:nm_flat/features/meals/meals_screen.dart';
import 'package:nm_flat/features/meals/recipe_edit_screen.dart';
import 'package:nm_flat/features/meals/recipe_screen.dart';
import 'package:nm_flat/features/money/money_screen.dart';
import 'package:nm_flat/features/money/transactions_screen.dart';
import 'package:nm_flat/features/onboarding/onboarding_screen.dart';
import 'package:nm_flat/features/remote_sync/remote_sync_screen.dart';
import 'package:nm_flat/features/salary/salary_screen.dart';
import 'package:nm_flat/features/sms_import/sms_import_screen.dart';
import 'package:nm_flat/features/staff/staff_screen.dart';
import 'package:nm_flat/features/store/store_mode_screen.dart';
import 'package:nm_flat/features/tasks/tasks_screen.dart';
import 'package:nm_flat/features/today/today_screen.dart';
import 'package:nm_flat/features/trips/trip_detail_screen.dart';
import 'package:nm_flat/features/trips/trip_template_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Start-up rule: with no home the app always starts at Welcome; with a home
/// it goes to Today and onboarding pages are closed.
String? startRedirect({required bool hasHome, required String location}) {
  if (location.startsWith('/debug')) return null;
  final onboarding = location.startsWith('/onboarding');
  if (!hasHome) {
    return onboarding ? null : Routes.onboardingStep('welcome');
  }
  if (onboarding) return Routes.today;
  return null;
}

class StreamListenable extends ChangeNotifier {
  StreamListenable(Stream<Object?> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(prefsProvider);
  final refresh = StreamListenable(prefs.currentHomeIdStream().skip(1));
  ref.onDispose(refresh.dispose);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.today,
    refreshListenable: refresh,
    redirect: (context, state) {
      if (state.uri.path == '/oauth-pcloud') return Routes.today;
      return startRedirect(
        hasHome: prefs.currentHomeId != null,
        location: state.matchedLocation,
      );
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.today,
                builder: (_, _) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.lists,
                builder: (_, _) => const ListsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.tasks,
                builder: (_, _) => const TasksScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.meals,
                builder: (_, _) => const MealsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.money,
                builder: (_, _) => const MoneyScreen(),
              ),
            ],
          ),
        ],
      ),
      if (kDebugMode)
        GoRoute(
          path: Routes.debug,
          builder: (_, _) => const DebugScreen(),
          routes: [
            GoRoute(
              path: 'gallery',
              builder: (_, _) => const GalleryScreen(),
            ),
            GoRoute(
              path: 'data-lab',
              builder: (_, _) => const DataLabScreen(),
            ),
            GoRoute(
              path: 'sync-lab',
              builder: (_, _) => const SyncLabScreen(),
            ),
            GoRoute(
              path: 'backup-lab',
              builder: (_, _) => const BackupLabScreen(),
            ),
          ],
        ),
      GoRoute(
        path: '/onboarding/:step',
        builder: (_, state) =>
            OnboardingScreen(step: state.pathParameters['step'] ?? 'welcome'),
      ),
      GoRoute(
        path: '/staff/:id',
        builder: (_, state) =>
            StaffScreen(staffId: state.pathParameters['id'] ?? ''),
        routes: [
          GoRoute(
            path: 'salary',
            builder: (_, state) =>
                SalaryScreen(staffId: state.pathParameters['id'] ?? ''),
          ),
        ],
      ),
      GoRoute(
        path: Routes.moneyTransactions,
        builder: (_, state) => TransactionsScreen(
          category: state.uri.queryParameters['category'],
        ),
      ),
      GoRoute(
        path: '/meals/recipe/:id',
        builder: (_, state) =>
            RecipeScreen(id: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/meals/recipe-edit/:id',
        builder: (_, state) =>
            RecipeEditScreen(id: state.pathParameters['id'] ?? 'new'),
      ),
      GoRoute(
        path: '/meals/cook/:id',
        builder: (_, state) =>
            CookScreen(id: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: Routes.listsStore,
        builder: (_, _) => const StoreModeScreen(),
      ),
      GoRoute(
        path: '/tasks/trip/:id',
        builder: (_, state) =>
            TripDetailScreen(tripId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: Routes.tripTemplate,
        builder: (_, _) => const TripTemplateScreen(),
      ),
      GoRoute(
        path: Routes.profile,
        builder: (_, _) => const ProfileScreen(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (_, _) => const HomeMembersScreen(),
      ),
      GoRoute(
        path: Routes.backup,
        builder: (_, _) => const BackupScreen(),
      ),
      GoRoute(
        path: Routes.remoteSync,
        builder: (_, _) => const RemoteSyncScreen(),
      ),
      GoRoute(
        path: Routes.gmailImport,
        builder: (_, _) => const GmailImportScreen(),
      ),
      GoRoute(
        path: Routes.smsImport,
        builder: (_, _) => const SmsImportScreen(),
      ),
      GoRoute(
        path: Routes.invite,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => InviteScreen(
          firstRun: state.uri.queryParameters['first'] == '1',
        ),
      ),
    ],
  );
});
