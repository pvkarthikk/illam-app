import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Breakdown mode for [SpendPieChartCard].
enum SpendChartMode { item, category, people }

/// One slice displayed inside [SpendPieChartCard].
class SpendPieSlice {
  const SpendPieSlice({
    required this.label,
    required this.amountPaise,
    required this.color,
  });

  final String label;
  final int amountPaise;
  final Color color;
}

/// Compact donut pie chart card with By item / By category / By people toggle.
class SpendPieChartCard extends StatelessWidget {
  const SpendPieChartCard({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.slices,
    required this.totalPaise,
  });

  final SpendChartMode mode;
  final ValueChanged<SpendChartMode> onModeChanged;
  final List<SpendPieSlice> slices;
  final int totalPaise;

  @override
  Widget build(BuildContext context) {
    if (slices.isEmpty || totalPaise <= 0) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    final chartWidget = SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RepaintBoundary(
            child: ExcludeSemantics(
              child: CustomPaint(
                size: const Size.square(120),
                painter: _DonutPiePainter(
                  slices: slices,
                  totalPaise: totalPaise,
                  separatorColor: c.card,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 64,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                Money.format(totalPaise),
                style: NestText.figures16.copyWith(color: c.ink),
              ),
            ),
          ),
        ],
      ),
    );

    final legendWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < slices.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          _LegendRow(slice: slices[i], totalPaise: totalPaise),
        ],
      ],
    );

    return NestCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              NestChip(
                label: l10n.moneyChartByItem,
                selected: mode == SpendChartMode.item,
                onTap: () => onModeChanged(SpendChartMode.item),
              ),
              NestChip(
                label: l10n.moneyChartByCategory,
                selected: mode == SpendChartMode.category,
                onTap: () => onModeChanged(SpendChartMode.category),
              ),
              NestChip(
                label: l10n.moneyChartByPeople,
                selected: mode == SpendChartMode.people,
                onTap: () => onModeChanged(SpendChartMode.people),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final sideBySide =
                  constraints.maxWidth >= 300 && textScale < 1.5;
              if (sideBySide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    chartWidget,
                    const SizedBox(width: 14),
                    Expanded(child: legendWidget),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: chartWidget),
                  const SizedBox(height: 12),
                  legendWidget,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.slice, required this.totalPaise});

  final SpendPieSlice slice;
  final int totalPaise;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    final pct = totalPaise > 0
        ? ((slice.amountPaise * 100) / totalPaise).round()
        : 0;
    final formatted = Money.format(slice.amountPaise);

    return Semantics(
      label: '${slice.label}: $formatted, $pct%',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: ExcludeSemantics(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: slice.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              slice.label,
              style: NestText.small12.copyWith(color: c.ink),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$formatted · $pct%',
            style: NestText.small12.copyWith(color: c.ink2),
          ),
        ],
      ),
    );
  }
}

class _DonutPiePainter extends CustomPainter {
  const _DonutPiePainter({
    required this.slices,
    required this.totalPaise,
    required this.separatorColor,
  });

  final List<SpendPieSlice> slices;
  final int totalPaise;
  final Color separatorColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (totalPaise <= 0 || slices.isEmpty) return;

    const strokeWidth = 24.0;
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (math.min(size.width, size.height) / 2) - 2;
    final ringRadius = outerRadius - (strokeWidth / 2);
    if (ringRadius <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: ringRadius);
    var startAngle = -math.pi / 2;

    if (slices.length == 1) {
      final paint = Paint()
        ..color = slices.first.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, math.pi * 2, false, paint);
      return;
    }

    final boundaries = <double>[];
    for (final slice in slices) {
      final sweep = (slice.amountPaise / totalPaise) * math.pi * 2;
      if (sweep <= 0) continue;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      boundaries.add(startAngle);
      startAngle += sweep;
    }

    final sepPaint = Paint()
      ..color = separatorColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final innerR = ringRadius - (strokeWidth / 2) - 0.5;
    final outerR = ringRadius + (strokeWidth / 2) + 0.5;
    for (final angle in boundaries) {
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);
      canvas.drawLine(
        Offset(center.dx + cosA * innerR, center.dy + sinA * innerR),
        Offset(center.dx + cosA * outerR, center.dy + sinA * outerR),
        sepPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPiePainter oldDelegate) =>
      oldDelegate.totalPaise != totalPaise ||
      oldDelegate.separatorColor != separatorColor ||
      !_sameSlices(oldDelegate.slices, slices);

  static bool _sameSlices(List<SpendPieSlice> a, List<SpendPieSlice> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].label != b[i].label ||
          a[i].amountPaise != b[i].amountPaise ||
          a[i].color != b[i].color) {
        return false;
      }
    }
    return true;
  }
}
