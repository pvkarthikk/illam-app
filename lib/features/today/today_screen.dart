import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/notify/notification_permission.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/onboarding/join_controller.dart';
import 'package:nm_flat/features/today/sections/due_today_section.dart';
import 'package:nm_flat/features/today/sections/help_at_home_section.dart';
import 'package:nm_flat/features/today/sections/hero_section.dart';
import 'package:nm_flat/features/today/sections/hero_tags.dart';
import 'package:nm_flat/features/today/sections/menu_section.dart';
import 'package:nm_flat/features/today/sections/month_so_far_section.dart';
import 'package:nm_flat/features/today/sections/ready_to_order_section.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAskPermission());
  }

  Future<void> _maybeAskPermission() async {
    if (!mounted) return;
    final homeId =
        ref.read(currentHomeIdProvider).value ??
        ref.read(prefsProvider).currentHomeId;
    final prefs = ref.read(prefsProvider);
    if (homeId != null && !prefs.notifAsked) {
      await ensureNotificationPermission(context, ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final joinUi = ref.watch(joinControllerProvider);
    final prefs = ref.watch(prefsProvider);
    final homeId =
        ref.watch(currentHomeIdProvider).value ?? prefs.currentHomeId;
    final showSetupBanner =
        homeId != null && prefs.setupIncompleteHomeId == homeId;
    final setupPct = joinUi.copy == JoinStepState.active
        ? joinUi.pct
        : prefs.setupPct;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          controller:
              ref.watch(tabScrollControllersProvider)[NestTab.today.index],
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            const OfflineIndicator(),
            if (showSetupBanner)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: InfoBanner(
                  icon: Icons.sync_rounded,
                  title: l10n.setupBanner(setupPct),
                  subtitle: '',
                  info: true,
                ),
              ),
            const HeroSection(),
            const DueTodaySection(),
            const MenuSection(),
            const ReadyToOrderSection(),
            const HelpAtHomeSection(),
            const MonthSoFarSection(),
          ],
        ),
      ),
    );
  }
}
