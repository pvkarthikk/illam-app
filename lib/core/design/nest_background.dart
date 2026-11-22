import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/nest_colors.dart';

/// Deep green brand background with warm radial accents and a dotted grid.
class NestPatternBackground extends StatelessWidget {
  const NestPatternBackground({
    super.key,
    required this.child,
    this.borderRadius,
    this.dotSpacing = 20,
    this.dotRadius = 1.1,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final double dotSpacing;
  final double dotRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.nest;
    final painted = CustomPaint(
      painter: _NestPatternPainter(
        baseColor: NestPalette.immersiveBg,
        emeraldGlow: colors.primary,
        warmGlow: colors.accent,
        dotColor: NestPalette.immersiveText,
        dotSpacing: dotSpacing,
        dotRadius: dotRadius,
      ),
      child: child,
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: painted,
      );
    }
    return painted;
  }
}

class _NestPatternPainter extends CustomPainter {
  const _NestPatternPainter({
    required this.baseColor,
    required this.emeraldGlow,
    required this.warmGlow,
    required this.dotColor,
    required this.dotSpacing,
    required this.dotRadius,
  });

  final Color baseColor;
  final Color emeraldGlow;
  final Color warmGlow;
  final Color dotColor;
  final double dotSpacing;
  final double dotRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;

    canvas.drawRect(bounds, Paint()..color = baseColor);

    final emeraldPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.75, -0.75),
        radius: 1.15,
        colors: <Color>[
          emeraldGlow.withValues(alpha: 0.48),
          emeraldGlow.withValues(alpha: 0),
        ],
      ).createShader(bounds);
    canvas.drawRect(bounds, emeraldPaint);

    final topWarmPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.85, -0.8),
        radius: 0.95,
        colors: <Color>[
          warmGlow.withValues(alpha: 0.18),
          warmGlow.withValues(alpha: 0),
        ],
      ).createShader(bounds);
    canvas.drawRect(bounds, topWarmPaint);

    final bottomWarmPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.8, 0.95),
        radius: 0.9,
        colors: <Color>[
          warmGlow.withValues(alpha: 0.14),
          warmGlow.withValues(alpha: 0),
        ],
      ).createShader(bounds);
    canvas.drawRect(bounds, bottomWarmPaint);

    final dotPaint = Paint()
      ..color = dotColor.withValues(alpha: 0.11)
      ..isAntiAlias = true;

    final offset = dotSpacing / 2;
    for (double y = offset; y < size.height; y += dotSpacing) {
      for (double x = offset; x < size.width; x += dotSpacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_NestPatternPainter oldDelegate) {
    return baseColor != oldDelegate.baseColor ||
        emeraldGlow != oldDelegate.emeraldGlow ||
        warmGlow != oldDelegate.warmGlow ||
        dotColor != oldDelegate.dotColor ||
        dotSpacing != oldDelegate.dotSpacing ||
        dotRadius != oldDelegate.dotRadius;
  }
}
