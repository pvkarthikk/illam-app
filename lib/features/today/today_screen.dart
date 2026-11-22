import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/today/sections/due_today_section.dart';
import 'package:nm_flat/features/today/sections/help_at_home_section.dart';
import 'package:nm_flat/features/today/sections/hero_section.dart';
import 'package:nm_flat/features/today/sections/month_so_far_section.dart';
import 'package:nm_flat/features/today/sections/ready_to_order_section.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          controller: ref.watch(tabScrollControllersProvider)[NestTab.today.index],
          padding: const EdgeInsets.only(bottom: 96),
          children: const [
            HeroSection(),
            DueTodaySection(),
            // MenuSection — P09
            ReadyToOrderSection(),
            HelpAtHomeSection(),
            MonthSoFarSection(),
          ],
        ),
      ),
    );
  }
}
