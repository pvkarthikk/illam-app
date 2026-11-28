import 'dart:math';

/// Positioned OCR line fragment returned by on-device text recognition.
class OcrTextBox {
  const OcrTextBox({
    required this.text,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final String text;
  final double left;
  final double top;
  final double right;
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;
  double get centerY => (top + bottom) / 2.0;
  bool get hasValidBounds => right > left && bottom > top;
}

class _LayoutRow {
  _LayoutRow(OcrTextBox first)
    : boxes = [first],
      _sumCenterY = first.centerY,
      _sumHeight = first.height;

  final List<OcrTextBox> boxes;
  double _sumCenterY;
  double _sumHeight;

  double get avgCenterY => _sumCenterY / boxes.length;
  double get avgHeight => _sumHeight / boxes.length;

  void add(OcrTextBox box) {
    boxes.add(box);
    _sumCenterY += box.centerY;
    _sumHeight += box.height;
  }

  bool overlapsHorizontally(OcrTextBox candidate) {
    for (final existing in boxes) {
      final overlap =
          min(candidate.right, existing.right) -
          max(candidate.left, existing.left);
      final minW = min(candidate.width, existing.width);
      if (overlap >= 0.5 * minW) return true;
    }
    return false;
  }
}

/// Reconstructs logical left-to-right receipt rows from positioned OCR boxes.
///
/// ML Kit groups text into visual blocks, which frequently places a receipt's
/// item names and right-aligned prices into separate blocks. Clustering boxes
/// by vertical band preserves column alignment even under slight camera tilt.
String reconstructReceiptLines(List<OcrTextBox> boxes) {
  final valid = <OcrTextBox>[];
  final unboxed = <String>[];

  for (final b in boxes) {
    if (b.text.trim().isEmpty) continue;
    if (b.hasValidBounds) {
      valid.add(b);
    } else {
      unboxed.add(b.text.trim());
    }
  }

  valid.sort((a, b) {
    final cy = a.centerY.compareTo(b.centerY);
    if (cy != 0) return cy;
    return a.left.compareTo(b.left);
  });

  final rows = <_LayoutRow>[];
  for (final box in valid) {
    _LayoutRow? bestRow;
    var bestDy = double.infinity;

    for (final row in rows) {
      final dy = (box.centerY - row.avgCenterY).abs();
      final threshold = 0.55 * max(box.height, row.avgHeight);
      if (dy <= threshold &&
          dy < bestDy &&
          !row.overlapsHorizontally(box)) {
        bestDy = dy;
        bestRow = row;
      }
    }

    if (bestRow != null) {
      bestRow.add(box);
    } else {
      rows.add(_LayoutRow(box));
    }
  }

  rows.sort((a, b) => a.avgCenterY.compareTo(b.avgCenterY));

  final lines = <String>[];
  for (final row in rows) {
    row.boxes.sort((a, b) => a.left.compareTo(b.left));
    final buf = StringBuffer(row.boxes.first.text.trim());
    for (var i = 1; i < row.boxes.length; i++) {
      final prev = row.boxes[i - 1];
      final next = row.boxes[i];
      final gap = next.left - prev.right;
      buf.write(gap > 0.8 * row.avgHeight ? '  ' : ' ');
      buf.write(next.text.trim());
    }
    lines.add(buf.toString());
  }
  lines.addAll(unboxed);
  return lines.join('\n');
}
