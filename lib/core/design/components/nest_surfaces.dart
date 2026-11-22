import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/nest_colors.dart';
import 'package:nm_flat/core/design/nest_text.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class NestCard extends StatelessWidget {
  const NestCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = Padding(padding: padding, child: child);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.line),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0x40000000)
                : const Color(0x0F1D2A21),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: onTap == null
          ? content
          : Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap, child: content),
            ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 36),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title.toUpperCase(),
                  style: NestText.section13.copyWith(color: c.ink2),
                ),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                onPressed: onAction,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel!,
                      style: NestText.small12.copyWith(color: c.primary),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: c.primary,
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

class NestTopBar extends StatelessWidget implements PreferredSizeWidget {
  const NestTopBar.tab({
    super.key,
    required this.title,
    this.eyebrow,
    this.actions = const [],
    this.onTitleLongPress,
  }) : subtitle = null,
       _isSub = false;

  const NestTopBar.sub({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  }) : eyebrow = null,
       onTitleLongPress = null,
       _isSub = true;

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final List<Widget> actions;
  final VoidCallback? onTitleLongPress;
  final bool _isSub;

  @override
  Size get preferredSize => Size.fromHeight(_isSub && subtitle != null ? 72 : 64);

  @override
  Widget build(BuildContext context) {
    final c = context.nest;

    if (!_isSub) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (eyebrow != null)
                    Text(
                      eyebrow!.toUpperCase(),
                      style: NestText.eyebrow12.copyWith(color: c.ink3),
                    ),
                  GestureDetector(
                    onLongPress: onTitleLongPress,
                    child: Text(
                      title,
                      style: NestText.display34.copyWith(color: c.ink),
                    ),
                  ),
                ],
              ),
            ),
            ...actions,
          ],
        ),
      );
    }

    return AppBar(
      toolbarHeight: subtitle == null ? 64 : 72,
      leading: IconButton(
        tooltip: AppLocalizations.of(context).commonBack,
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: NestText.title22.copyWith(color: c.ink),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: NestText.meta13.copyWith(color: c.ink3),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: actions,
      backgroundColor: c.paper.withValues(alpha: 0.92),
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      foregroundColor: c.ink,
    );
  }
}

/// A rounded box with a dashed 1.5 dp border.
class DashedBox extends StatelessWidget {
  const DashedBox({
    super.key,
    required this.child,
    this.radius = 12,
    this.color,
    this.padding = const EdgeInsets.fromLTRB(14, 12, 14, 12),
  });

  final Widget child;
  final double radius;
  final Color? color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(color ?? context.nest.line2, radius),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter(this.color, this.radius);

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 1.5;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = color;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
}
