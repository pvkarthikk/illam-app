import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';

class GalleryMoreSections extends ConsumerStatefulWidget {
  const GalleryMoreSections({super.key});

  @override
  ConsumerState<GalleryMoreSections> createState() =>
      _GalleryMoreSectionsState();
}

class _GalleryMoreSectionsState extends ConsumerState<GalleryMoreSections> {
  bool sw = true;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    final tokens = <(String, Color)>[
      ('paper', c.paper),
      ('paper2', c.paper2),
      ('card', c.card),
      ('card2', c.card2),
      ('ink', c.ink),
      ('ink2', c.ink2),
      ('ink3', c.ink3),
      ('line', c.line),
      ('line2', c.line2),
      ('primary', c.primary),
      ('onPrimary', c.onPrimary),
      ('primarySoft', c.primarySoft),
      ('accent', c.accent),
      ('accentInk', c.accentInk),
      ('accentSoft', c.accentSoft),
      ('danger', c.danger),
      ('dangerSoft', c.dangerSoft),
      ('info', c.info),
      ('infoSoft', c.infoSoft),
      ('ok', c.ok),
      ('dot', c.dot),
      ('scrim', c.scrim),
      for (final entry in NestPalette.categories.entries)
        (entry.key, entry.value),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        const SectionHeader(title: 'Avatars'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final s in AvatarSize.values)
              Avatar(name: 'Priya', color: NestPalette.avatars[1], size: s),
            Avatar(
              name: 'You',
              color: NestPalette.avatars[0],
              size: AvatarSize.s52,
              ring: true,
            ),
            AvatarStack(
              people: [
                (name: 'You', color: NestPalette.avatars[0]),
                (name: 'Priya', color: NestPalette.avatars[1]),
                (name: 'Arjun', color: NestPalette.avatars[2]),
                (name: 'Lakshmi', color: NestPalette.avatars[3]),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        const SectionHeader(title: 'Channels'),
        const SizedBox(height: 8),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChannelBadge(channel: 'zepto'),
            ChannelBadge(channel: 'blinkit'),
            ChannelBadge(channel: 'bigbasket'),
            ChannelBadge(channel: 'amazon'),
            ChannelBadge(channel: 'flipkart'),
            ChannelBadge(channel: 'meesho'),
            ChannelBadge(channel: 'offline'),
          ],
        ),
        const SizedBox(height: 12),
        const SectionHeader(title: 'Rows'),
        const SizedBox(height: 8),
        NestCard(
          child: Column(
            children: [
              SwitchRow(
                title: 'Reminders',
                subtitle: 'Every morning at 8',
                value: sw,
                onChanged: (v) => setState(() => sw = v),
              ),
              SettingsRow(
                label: 'Home',
                value: 'Sharma flat',
                sub: '3 members',
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const SectionHeader(title: 'Empty state'),
        const SizedBox(height: 8),
        const EmptyState(
          icon: Icons.inbox_outlined,
          title: 'Nothing here',
          body: 'Add something to get started.',
        ),
        const SizedBox(height: 12),
        const SectionHeader(title: 'Feedback'),
        const SizedBox(height: 8),
        AlertLine(
          icon: Icons.warning_amber_rounded,
          text: 'Milk runs out tomorrow',
          actionLabel: 'Add to list',
          onAction: () {},
        ),
        const SizedBox(height: 8),
        InfoBanner(
          icon: Icons.lock_outline_rounded,
          title: 'Private to you',
          subtitle: 'Only this phone sees it',
          onTap: () {},
          info: true,
        ),
        const SizedBox(height: 12),
        const SectionHeader(title: 'Overlays'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            NestButton(
              label: 'Show sheet',
              onPressed: () => showNestSheet<void>(
                context,
                (sheetCtx) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const NestSheetHeader(
                      title: 'Add milk?',
                      lead: 'It goes on the grocery list.',
                    ),
                    NestSheetActions(
                      children: [
                        NestButton(
                          label: 'Cancel',
                          kind: NestButtonKind.ghost,
                          size: NestButtonSize.block,
                          onPressed: () => Navigator.pop(sheetCtx),
                        ),
                        NestButton(
                          label: 'Add',
                          size: NestButtonSize.block,
                          onPressed: () => Navigator.pop(sheetCtx),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            NestButton(
              label: 'Show snackbar',
              onPressed: () =>
                  ref.read(snackbarProvider).show('Milk added', onUndo: () {}),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const SectionHeader(title: 'Colours'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final (name, color) in tokens)
              SizedBox(
                width: 72,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: c.line2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: NestText.small12.copyWith(color: c.ink2),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
