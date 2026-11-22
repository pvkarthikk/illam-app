import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class ShellScaffold extends ConsumerWidget {
  const ShellScaffold({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tasksBadge = ref.watch(tasksBadgeProvider);
    final moneyBadge = ref.watch(moneyBadgeProvider);

    Widget badged(Widget icon, int count) => Badge(
      isLabelVisible: count > 0,
      label: Text('$count'),
      backgroundColor: context.nest.danger,
      textColor: Colors.white,
      child: icon,
    );

    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          shell.goBranch(0);
        }
      },
      child: Scaffold(
        body: shell,
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
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l10n.tabToday,
            ),
            NavigationDestination(
              icon: const Icon(Icons.list_alt_outlined),
              selectedIcon: const Icon(Icons.list_alt_rounded),
              label: l10n.tabLists,
            ),
            NavigationDestination(
              icon: badged(const Icon(Icons.task_alt_outlined), tasksBadge),
              selectedIcon: badged(const Icon(Icons.task_alt_rounded), tasksBadge),
              label: l10n.tabTasks,
            ),
            NavigationDestination(
              icon: const Icon(Icons.restaurant_outlined),
              selectedIcon: const Icon(Icons.restaurant_rounded),
              label: l10n.tabMeals,
            ),
            NavigationDestination(
              icon: badged(
                const Icon(Icons.account_balance_wallet_outlined),
                moneyBadge,
              ),
              selectedIcon: badged(
                const Icon(Icons.account_balance_wallet_rounded),
                moneyBadge,
              ),
              label: l10n.tabMoney,
            ),
          ],
        ),
      ),
    );
  }
}
