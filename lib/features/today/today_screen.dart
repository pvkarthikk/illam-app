import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/notify/notification_permission.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/onboarding/join_controller.dart';
import 'package:nm_flat/features/today/restore_banner.dart';
import 'package:nm_flat/features/today/sections/due_today_section.dart';
import 'package:nm_flat/features/today/sections/help_at_home_section.dart';
import 'package:nm_flat/features/today/sections/hero_section.dart';
import 'package:nm_flat/features/today/sections/hero_tags.dart';
import 'package:nm_flat/features/today/sections/menu_section.dart';
import 'package:nm_flat/features/today/sections/month_so_far_section.dart';
import 'package:nm_flat/features/today/sections/ready_to_order_section.dart';
import 'package:nm_flat/features/today/sections/upcoming_trip_section.dart';
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
    final controller = ref.watch(
      tabScrollControllersProvider.select((list) => list[NestTab.today.index]),
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.only(bottom: 96),
          children: const [
            OfflineIndicator(),
            RestoreBanner(),
            _SetupBanner(),
            HeroSection(),
            UpcomingTripSection(),
            DueTodaySection(),
            MenuSection(),
            ReadyToOrderSection(),
            HelpAtHomeSection(),
            MonthSoFarSection(),
          ],
        ),
      ),
    );
  }
}

class _SetupBanner extends ConsumerWidget {
  const _SetupBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.read(prefsProvider);
    final homeId =
        ref.watch(currentHomeIdProvider.select((v) => v.value)) ??
        prefs.currentHomeId;
    final activePct = ref.watch(
      joinControllerProvider.select(
        (j) => j.copy == JoinStepState.active ? j.pct : -1,
      ),
    );
    if (homeId == null || prefs.setupIncompleteHomeId != homeId) {
      return const SizedBox.shrink();
    }
    final setupPct = activePct >= 0 ? activePct : prefs.setupPct;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: InfoBanner(
        icon: Icons.sync_rounded,
        title: l10n.setupBanner(setupPct),
        subtitle: '',
        info: true,
      ),
    );
  }
}
