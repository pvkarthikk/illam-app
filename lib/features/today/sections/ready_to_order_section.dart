import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/list_groups.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/lists/lists_controller.dart';
import 'package:nm_flat/features/lists/lists_text.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class ReadyToOrderSection extends ConsumerWidget {
  const ReadyToOrderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rows = ref.watch(openItemsProvider).value ?? const <ItemRow>[];
    if (rows.isEmpty) return const SizedBox.shrink();

    final byList = <String, List<ItemRow>>{};
    final byId = <String, ItemRow>{};
    for (final r in rows) {
      byId[r.id] = r;
      (byList[r.list] ??= []).add(r);
    }

    final counts = <String, int>{};
    final firstListFor = <String, String>{};
    for (final entry in byList.entries) {
      for (final g in groupOpenItems(snapsOf(entry.value))) {
        final s = byId[g.survivor.id];
        if (s == null) continue;
        counts[s.channel] = (counts[s.channel] ?? 0) + 1;
        firstListFor.putIfAbsent(s.channel, () => entry.key);
      }
    }
    if (counts.isEmpty) return const SizedBox.shrink();

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        SectionHeader(
          title: l10n.todayReadyToOrder,
          actionLabel: l10n.todayListsLink,
          onAction: () => context.go(Routes.lists),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Column(
            children: [
              for (var i = 0; i < top.length; i += 2) ...[
                if (i > 0) const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _StorePill(
                        channel: top[i].key,
                        count: top[i].value,
                        listType: firstListFor[top[i].key] ?? 'grocery',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: i + 1 < top.length
                          ? _StorePill(
                              channel: top[i + 1].key,
                              count: top[i + 1].value,
                              listType:
                                  firstListFor[top[i + 1].key] ?? 'grocery',
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StorePill extends ConsumerWidget {
  const _StorePill({
    required this.channel,
    required this.count,
    required this.listType,
  });

  final String channel;
  final int count;
  final String listType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final eta = channel == 'offline'
        ? l10n.todayStoreRun
        : channelEta(l10n, channel);

    return NestCard(
      padding: const EdgeInsets.all(12),
      onTap: () {
        ref.read(listsControllerProvider.notifier).showChannel(listType, channel);
        context.go(Routes.lists);
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 36),
        child: Row(
          children: [
            ChannelBadge(channel: channel),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    channelName(l10n, channel),
                    style: TextStyle(
                      fontFamily: NestText.sans,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontVariations: const [FontVariation.weight(700)],
                      color: c.ink,
                    ),
                  ),
                  Text(
                    '${l10n.todayPillCount(count)} · $eta',
                    style: NestText.meta13.copyWith(color: c.ink3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
