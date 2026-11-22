import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/nest_colors.dart';

class FreshnessBar extends StatelessWidget {
  const FreshnessBar({super.key, required this.ratio});

  final double ratio;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    final clamped = ratio.clamp(0.0, 1.0);
    final fillColor = ratio > 0.5
        ? c.primary
        : (ratio > 0.2 ? c.accent : c.danger);
    final fraction = math.max(clamped, 0.04);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 700);

    return Semantics(
      value: '${(ratio * 100).round()}%',
      child: Container(
        height: 6,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: c.paper2,
          shape: const StadiumBorder(),
        ),
        child: AnimatedFractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: fraction,
          duration: duration,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: fillColor,
              shape: const StadiumBorder(),
            ),
          ),
        ),
      ),
    );
  }
}

class NestProgressBar extends StatelessWidget {
  const NestProgressBar({
    super.key,
    required this.value,
    this.height = 10,
    this.color,
    this.track,
  });

  final double value;
  final double height;
  final Color? color;
  final Color? track;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    final clamped = value.clamp(0.0, 1.0);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 700);

    return Semantics(
      value: '${(clamped * 100).round()}%',
      child: Container(
        height: height,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: track ?? c.paper2,
          shape: const StadiumBorder(),
        ),
        child: AnimatedFractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: clamped,
          duration: duration,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: color ?? c.primary,
              shape: const StadiumBorder(),
            ),
          ),
        ),
      ),
    );
  }
}
