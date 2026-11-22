import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/nav/shell_scaffold.dart';
import 'package:nm_flat/features/debug/data_lab_screen.dart';
import 'package:nm_flat/features/debug/debug_screen.dart';
import 'package:nm_flat/features/debug/gallery_screen.dart';
import 'package:nm_flat/features/lists/lists_screen.dart';
import 'package:nm_flat/features/meals/meals_screen.dart';
import 'package:nm_flat/features/money/money_screen.dart';
import 'package:nm_flat/features/tasks/tasks_screen.dart';
import 'package:nm_flat/features/today/today_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.today,
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
          ],
        ),
    ],
  ),
);
