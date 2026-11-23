import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/nest_colors.dart';

class KolamPainter extends CustomPainter {
  const KolamPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || size.width <= 7 || size.height <= 7) return;
    final cols = ((size.width - 7) / 14).ceil();
    final rows = ((size.height - 7) / 14).ceil();
    final coords = Float32List(cols * rows * 2);
    var idx = 0;
    for (var r = 0; r < rows; r++) {
      final y = 7.0 + r * 14.0;
      for (var c = 0; c < cols; c++) {
        coords[idx++] = 7.0 + c * 14.0;
        coords[idx++] = y;
      }
    }
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    canvas.drawRawPoints(ui.PointMode.points, coords, paint);
  }

  @override
  bool shouldRepaint(covariant KolamPainter oldDelegate) =>
      color != oldDelegate.color;
}

class KolamBackground extends StatefulWidget {
  const KolamBackground({
    super.key,
    required this.child,
    this.color,
  });

  final Widget child;
  final Color? color;

  @override
  State<KolamBackground> createState() => _KolamBackgroundState();
}

class _KolamBackgroundState extends State<KolamBackground> {
  final _cache = _KolamPictureCache();

  @override
  void dispose() {
    _cache.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedColor = widget.color ?? context.nest.dot;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              isComplex: true,
              willChange: false,
              painter: _CachedKolamPainter(_cache, resolvedColor),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _KolamPictureCache {
  ui.Picture? _picture;
  Size? _size;
  Color? _color;

  void draw(Canvas canvas, Size size, Color color) {
    if (size.isEmpty) return;
    if (_picture == null || _size != size || _color != color) {
      _picture?.dispose();
      final recorder = ui.PictureRecorder();
      KolamPainter(color).paint(Canvas(recorder), size);
      _picture = recorder.endRecording();
      _size = size;
      _color = color;
    }
    canvas.drawPicture(_picture!);
  }

  void dispose() {
    _picture?.dispose();
    _picture = null;
  }
}

class _CachedKolamPainter extends CustomPainter {
  const _CachedKolamPainter(this.cache, this.color);

  final _KolamPictureCache cache;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) => cache.draw(canvas, size, color);

  @override
  bool shouldRepaint(covariant _CachedKolamPainter oldDelegate) =>
      color != oldDelegate.color;
}
