import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/greeting.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/ui/rich_text.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/today/sections/hero_tags.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class HeroSection extends ConsumerWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    ref.watch(minuteTickProvider);
    final now = ref.watch(clockProvider).now();
    final home = ref.watch(currentHomeProvider).value;
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final meId = ref.watch(myMemberIdProvider);
    final me = ref.watch(myMemberProvider).value;

    final others = [
      for (final m in members)
        if (m.id != meId) m,
    ];
    final otherPeople = [
      for (final m in others)
        (
          name: m.firstName ?? Names.firstName(m.fullName ?? ''),
          color: NestPalette.fromHex(
            (m.color != null && m.color!.isNotEmpty) ? m.color! : '#23503A',
          ),
        ),
    ];

    final greeting = switch (greetingFor(now.hour)) {
      Greeting.late => l10n.todayGreetingLate,
      Greeting.morning => l10n.todayGreetingMorning,
      Greeting.afternoon => l10n.todayGreetingAfternoon,
      Greeting.evening => l10n.todayGreetingEvening,
    };
    final em = l10n.todayAllSetEm;
    final n = ref.watch(tasksBadgeProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: home == null
                    ? const SizedBox.shrink()
                    : Text(
                        l10n
                            .todayEyebrow(
                              home.name ?? '',
                              DateFormat('EEEE, d MMMM', 'en').format(now),
                            )
                            .toUpperCase(),
                        style: NestText.eyebrow12.copyWith(color: c.ink3),
                      ),
              ),
              if (home != null && others.isNotEmpty)
                Semantics(
                  button: true,
                  excludeSemantics: true,
                  label: l10n.todayFamilyButton(
                    home.name ?? '',
                    others.length + 1,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => context.push(Routes.home),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Center(
                          child: AvatarStack(people: otherPeople, max: 3),
                        ),
                      ),
                    ),
                  ),
                ),
              if (me != null)
                Semantics(
                  button: true,
                  excludeSemantics: true,
                  label: l10n.todayYourProfile,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => context.push(Routes.profile),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      child: Center(
                        child: Avatar(
                          name: me.fullName ?? '',
                          color: NestPalette.fromHex(
                            (me.color != null && me.color!.isNotEmpty)
                                ? me.color!
                                : '#23503A',
                          ),
                          ring: true,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          GestureDetector(
            onLongPress: kDebugMode ? () => context.push(Routes.debug) : null,
            child: Text.rich(
              TextSpan(
                style: NestText.display38.copyWith(color: c.ink),
                children: n > 0
                    ? [
                        TextSpan(text: '$greeting.\n'),
                        TextSpan(
                          text: l10n.todayThingsCount(n),
                          style: TextStyle(color: c.accent),
                        ),
                        TextSpan(text: l10n.todayThingsNeed(n)),
                      ]
                    : [
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
          const SizedBox(height: 10),
          const HeroTags(),
        ],
      ),
    );
  }
}
