import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/quickadd/quick_add_sheet.dart';
import 'package:nm_flat/features/store/handoff_watcher.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class ShellScaffold extends ConsumerWidget {
  const ShellScaffold({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          shell.goBranch(0);
        }
      },
      child: Scaffold(
        body: HandoffWatcher(child: shell),
        floatingActionButton: shell.currentIndex <= 3
            ? NestFab(
                onPressed: () =>
                    showQuickAdd(context, ref, origin: shell.currentIndex),
              )
            : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) {
            if (i == shell.currentIndex) {
              final c = ref.read(tabScrollControllersProvider)[i];
              if (c.hasClients) {
                c.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              }
            }
            shell.goBranch(i, initialLocation: i == shell.currentIndex);
          },
          destinations: [
            NavigationDestination(
              key: const Key('nav_today'),
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l10n.tabToday,
            ),
            NavigationDestination(
              key: const Key('nav_lists'),
              icon: const Icon(Icons.list_alt_outlined),
              selectedIcon: const Icon(Icons.list_alt_rounded),
              label: l10n.tabLists,
            ),
            NavigationDestination(
              key: const Key('nav_tasks'),
              icon: _NavBadgeIcon(
                provider: tasksBadgeProvider,
                icon: const Icon(Icons.task_alt_outlined),
              ),
              selectedIcon: _NavBadgeIcon(
                provider: tasksBadgeProvider,
                icon: const Icon(Icons.task_alt_rounded),
              ),
              label: l10n.tabTasks,
            ),
            NavigationDestination(
              key: const Key('nav_meals'),
              icon: const Icon(Icons.restaurant_outlined),
              selectedIcon: const Icon(Icons.restaurant_rounded),
              label: l10n.tabMeals,
            ),
            NavigationDestination(
              key: const Key('nav_money'),
              icon: _NavBadgeIcon(
                provider: moneyBadgeProvider,
                icon: const Icon(Icons.account_balance_wallet_outlined),
              ),
              selectedIcon: _NavBadgeIcon(
                provider: moneyBadgeProvider,
                icon: const Icon(Icons.account_balance_wallet_rounded),
              ),
              label: l10n.tabMoney,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBadgeIcon extends ConsumerWidget {
  const _NavBadgeIcon({required this.provider, required this.icon});

  final Provider<int> provider;
  final Widget icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(provider);
    return Badge(
      isLabelVisible: count > 0,
      label: Text('$count'),
      backgroundColor: context.nest.danger,
      textColor: Colors.white,
      child: icon,
    );
  }
}
