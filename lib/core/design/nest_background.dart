import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/nest_colors.dart';

/// Deep green brand background with warm radial accents and a dotted grid.
class NestPatternBackground extends StatefulWidget {
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
  State<NestPatternBackground> createState() => _NestPatternBackgroundState();
}

class _NestPatternBackgroundState extends State<NestPatternBackground> {
  final _cache = _NestPatternCache();

  @override
  void dispose() {
    _cache.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.nest;
    final bg = Positioned.fill(
      child: RepaintBoundary(
        child: CustomPaint(
          isComplex: true,
          willChange: false,
          painter: _NestPatternPainter(
            cache: _cache,
            baseColor: NestPalette.immersiveBg,
            emeraldGlow: colors.primary,
            warmGlow: colors.accent,
            dotColor: NestPalette.immersiveText,
            dotSpacing: widget.dotSpacing,
            dotRadius: widget.dotRadius,
          ),
        ),
      ),
    );
    final stacked = Stack(
      fit: StackFit.passthrough,
      children: [bg, widget.child],
    );

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: stacked,
      );
    }
    return stacked;
  }
}

class _NestPatternCache {
  ui.Picture? _picture;
  Size? _size;
  Color? _baseColor;
  Color? _emeraldGlow;
  Color? _warmGlow;
  Color? _dotColor;
  double? _dotSpacing;
  double? _dotRadius;

  void draw(
    Canvas canvas,
    Size size, {
    required Color baseColor,
    required Color emeraldGlow,
    required Color warmGlow,
    required Color dotColor,
    required double dotSpacing,
    required double dotRadius,
  }) {
    if (size.isEmpty) return;
    if (_picture == null ||
        _size != size ||
        _baseColor != baseColor ||
        _emeraldGlow != emeraldGlow ||
        _warmGlow != warmGlow ||
        _dotColor != dotColor ||
        _dotSpacing != dotSpacing ||
        _dotRadius != dotRadius) {
      _picture?.dispose();
      _picture = _record(
        size,
        baseColor: baseColor,
        emeraldGlow: emeraldGlow,
        warmGlow: warmGlow,
        dotColor: dotColor,
        dotSpacing: dotSpacing,
        dotRadius: dotRadius,
      );
      _size = size;
      _baseColor = baseColor;
      _emeraldGlow = emeraldGlow;
      _warmGlow = warmGlow;
      _dotColor = dotColor;
      _dotSpacing = dotSpacing;
      _dotRadius = dotRadius;
    }
    canvas.drawPicture(_picture!);
  }

  static ui.Picture _record(
    Size size, {
    required Color baseColor,
    required Color emeraldGlow,
    required Color warmGlow,
    required Color dotColor,
    required double dotSpacing,
    required double dotRadius,
  }) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
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

    if (dotSpacing > 0 && dotRadius > 0) {
      final offset = dotSpacing / 2;
      if (size.width > offset && size.height > offset) {
        final cols = ((size.width - offset) / dotSpacing).ceil();
        final rows = ((size.height - offset) / dotSpacing).ceil();
        final coords = Float32List(cols * rows * 2);
        var idx = 0;
        for (var r = 0; r < rows; r++) {
          final y = offset + r * dotSpacing;
          for (var c = 0; c < cols; c++) {
            coords[idx++] = offset + c * dotSpacing;
            coords[idx++] = y;
          }
        }
        final dotPaint = Paint()
          ..color = dotColor.withValues(alpha: 0.11)
          ..isAntiAlias = true
          ..strokeWidth = dotRadius * 2
          ..strokeCap = StrokeCap.round;
        canvas.drawRawPoints(ui.PointMode.points, coords, dotPaint);
      }
    }

    return recorder.endRecording();
  }

  void dispose() {
    _picture?.dispose();
    _picture = null;
  }
}

class _NestPatternPainter extends CustomPainter {
  const _NestPatternPainter({
    required this.cache,
    required this.baseColor,
    required this.emeraldGlow,
    required this.warmGlow,
    required this.dotColor,
    required this.dotSpacing,
    required this.dotRadius,
  });

  final _NestPatternCache cache;
  final Color baseColor;
  final Color emeraldGlow;
  final Color warmGlow;
  final Color dotColor;
  final double dotSpacing;
  final double dotRadius;

  @override
  void paint(Canvas canvas, Size size) {
    cache.draw(
      canvas,
      size,
      baseColor: baseColor,
      emeraldGlow: emeraldGlow,
      warmGlow: warmGlow,
      dotColor: dotColor,
      dotSpacing: dotSpacing,
      dotRadius: dotRadius,
    );
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
