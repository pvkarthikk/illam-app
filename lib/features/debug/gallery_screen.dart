import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/features/debug/gallery_parts.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  bool dark = false;
  bool box = true;
  bool round = false;
  int qty = 2;
  int seg = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: NestTopBar.sub(
        title: l10n.debugGallery,
        actions: [
          Semantics(
            label: l10n.debugDarkTheme,
            child: Switch(
              value: dark,
              onChanged: (v) => setState(() => dark = v),
            ),
          ),
        ],
      ),
      body: Theme(
        data: dark ? NestTheme.dark() : NestTheme.light(),
        child: Builder(
          builder: (context) => ColoredBox(
            color: context.nest.paper,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                const SectionHeader(title: 'Buttons'),
                const SizedBox(height: 8),
                for (final kind in NestButtonKind.values) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      NestButton(
                        label: kind.name,
                        kind: kind,
                        size: NestButtonSize.sm,
                        onPressed: () {},
                      ),
                      NestButton(
                        label: kind.name,
                        kind: kind,
                        size: NestButtonSize.md,
                        onPressed: () {},
                      ),
                      NestButton(
                        label: kind.name,
                        kind: kind,
                        size: NestButtonSize.block,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const NestButton(label: 'Disabled', onPressed: null),
                    NestButton(
                      label: 'With icon',
                      icon: Icons.add_rounded,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const SectionHeader(title: 'Card'),
                const SizedBox(height: 8),
                NestCard(
                  padding: const EdgeInsets.all(16),
                  child: KolamBackground(
                    child: SizedBox(
                      height: 80,
                      child: Center(
                        child: Text(
                          'Kolam card',
                          style: NestText.cardTitle20.copyWith(
                            color: context.nest.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const SectionHeader(title: 'Chips'),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const NestChip(label: 'All', selected: true),
                      const SizedBox(width: 8),
                      NestChip(
                        label: 'Groceries',
                        dotColor: NestPalette.categories['Groceries'],
                      ),
                      const SizedBox(width: 8),
                      const NestChip(label: 'Due', count: 3),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const SectionHeader(title: 'Segmented'),
                const SizedBox(height: 8),
                SegmentedTabs<int>(
                  segments: const [(0, 'Grocery', 8), (1, 'Shopping', 5)],
                  selected: seg,
                  onChanged: (v) => setState(() => seg = v),
                ),
                const SizedBox(height: 12),
                const SectionHeader(title: 'Tags'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final kind in NestTagKind.values)
                      NestTag(label: kind.name, kind: kind),
                  ],
                ),
                const SizedBox(height: 12),
                const SectionHeader(title: 'Checks'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    NestCheckbox(
                      value: box,
                      onChanged: (v) => setState(() => box = v),
                      semanticLabel: 'Checkbox',
                    ),
                    RoundCheck(
                      value: round,
                      onChanged: (v) => setState(() => round = v),
                      semanticLabel: 'Round check',
                    ),
                    QtyStepper(
                      valueText: '$qty',
                      onMinus: qty > 0 ? () => setState(() => qty--) : null,
                      onPlus: () => setState(() => qty++),
                      semanticLabel: 'Quantity',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const SectionHeader(title: 'Bars'),
                const SizedBox(height: 8),
                const FreshnessBar(ratio: 0.9),
                const SizedBox(height: 8),
                const FreshnessBar(ratio: 0.3),
                const SizedBox(height: 8),
                const FreshnessBar(ratio: 0.1),
                const SizedBox(height: 8),
                const NestProgressBar(value: 0.6),
                const GalleryMoreSections(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
