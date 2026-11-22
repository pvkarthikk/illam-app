import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/greeting.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/ui/rich_text.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class HeroSection extends ConsumerWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final now = ref.watch(clockProvider).now();
    final home = ref.watch(currentHomeProvider).value;

    final greeting = switch (greetingFor(now.hour)) {
      Greeting.late => l10n.todayGreetingLate,
      Greeting.morning => l10n.todayGreetingMorning,
      Greeting.afternoon => l10n.todayGreetingAfternoon,
      Greeting.evening => l10n.todayGreetingEvening,
    };
    final em = l10n.todayAllSetEm;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (home != null)
            Text(
              l10n
                  .todayEyebrow(
                    home.name ?? '',
                    DateFormat('EEEE, d MMMM', 'en').format(now),
                  )
                  .toUpperCase(),
              style: NestText.eyebrow12.copyWith(color: c.ink3),
            ),
          GestureDetector(
            onLongPress: kDebugMode ? () => context.push(Routes.debug) : null,
            child: Text.rich(
              TextSpan(
                style: NestText.display38.copyWith(color: c.ink),
                children: [
                  TextSpan(text: '$greeting.\n'),
                  emphasise(
                    l10n.todayHeadlineAllSet(em),
                    em,
                    TextStyle(color: c.accent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
