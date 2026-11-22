import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/nest_colors.dart';

class KolamPainter extends CustomPainter {
  const KolamPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (double y = 7; y < size.height; y += 14) {
      for (double x = 7; x < size.width; x += 14) {
        canvas.drawCircle(Offset(x, y), 1.4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant KolamPainter oldDelegate) =>
      color != oldDelegate.color;
}

class KolamBackground extends StatelessWidget {
  const KolamBackground({
    super.key,
    required this.child,
    this.color,
  });

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: KolamPainter(color ?? context.nest.dot),
      child: child,
    );
  }
}
