import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/nest_colors.dart';
import 'package:nm_flat/core/design/nest_text.dart';

class NestChip extends StatelessWidget {
  const NestChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.dotColor,
    this.leading,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color? dotColor;
  final Widget? leading;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    final fg = selected ? c.paper : c.ink2;
    const textStyle = TextStyle(
      fontFamily: NestText.sans,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontVariations: [FontVariation.weight(600)],
    );

    final pill = Material(
      color: selected ? c.ink : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? c.ink : c.line2, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 38),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dotColor != null) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(label, style: textStyle.copyWith(color: fg)),
                ),
                if (count != null) ...[
                  const SizedBox(width: 6),
                  Text('$count', style: textStyle.copyWith(color: fg)),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return Semantics(
      selected: selected,
      button: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(widthFactor: 1.0, child: pill),
        ),
      ),
    );
  }
}

class SegmentedTabs<T> extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<(T value, String label, int? count)> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;

    return Container(
      decoration: ShapeDecoration(
        color: c.paper2,
        shape: const StadiumBorder(),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: _SegmentedItem(
                label: segments[i].$2,
                count: segments[i].$3,
                selected: segments[i].$1 == selected,
                onTap: () => onChanged(segments[i].$1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SegmentedItem extends StatelessWidget {
  const _SegmentedItem({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    final fg = selected ? c.ink : c.ink2;

    return Semantics(
      selected: selected,
      button: true,
      child: Container(
        decoration: selected
            ? ShapeDecoration(
                color: c.card,
                shape: const StadiumBorder(),
                shadows: const [
                  BoxShadow(
                    color: Color(0x0F1D2A21),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              )
            : null,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: NestText.button15.copyWith(color: fg),
                      ),
                    ),
                    if (count != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: ShapeDecoration(
                          color: c.line,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontFamily: NestText.sans,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontVariations: const [FontVariation.weight(700)],
                            color: fg,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum NestTagKind { neutral, ok, accent, danger, info }

class NestTag extends StatelessWidget {
  const NestTag({
    super.key,
    required this.label,
    this.kind = NestTagKind.neutral,
    this.icon,
    this.onTap,
  });

  final String label;
  final NestTagKind kind;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    final (Color bg, Color fg) = switch (kind) {
      NestTagKind.neutral => (c.paper2, c.ink2),
      NestTagKind.ok => (c.primarySoft, c.primary),
      NestTagKind.accent => (c.accentSoft, c.accentInk),
      NestTagKind.danger => (c.dangerSoft, c.danger),
      NestTagKind.info => (c.infoSoft, c.info),
    };

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label, style: NestText.tag12.copyWith(color: fg)),
        ],
      ),
    );

    return Material(
      color: bg,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(
              customBorder: const StadiumBorder(),
              onTap: onTap,
              child: content,
            ),
    );
  }
}
