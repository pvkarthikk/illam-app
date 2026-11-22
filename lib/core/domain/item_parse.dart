import 'package:nm_flat/core/domain/merchant_key.dart';

class ParsedItem {
  const ParsedItem(this.name, this.qty, this.unit);

  final String name;
  final double qty;
  final String unit;

  int get qtyMilli => (qty * 1000).round();
}

String itemNameKey(String name) => merchantKey(name);

const _unit = r'(kg|g|gm|l|ltr|ml|pcs|pc|dozen|bunch|packets?)';
final _x = RegExp(r'^(.*?)\s*[x×]\s*(\d+)$', caseSensitive: false);
final _a = RegExp(
  r'^(.*?)[\s,]+(\d+(?:\.\d+)?)\s*' + _unit + r'?$',
  caseSensitive: false,
);
final _b = RegExp(
  r'^(\d+(?:\.\d+)?)\s*' + _unit + r'?\s+(.+)$',
  caseSensitive: false,
);

ParsedItem parseItem(String text) {
  final trimmed = text.trim();

  final mx = _x.firstMatch(trimmed);
  if (mx != null) {
    final name = _cleanName(mx.group(1) ?? '');
    if (name.isNotEmpty) {
      final rawQty = double.tryParse(mx.group(2) ?? '') ?? 1;
      return ParsedItem(name, rawQty <= 0 ? 1 : rawQty, '');
    }
  }

  final ma = _a.firstMatch(trimmed);
  if (ma != null) {
    final name = _cleanName(ma.group(1) ?? '');
    if (name.isNotEmpty) {
      final rawQty = double.tryParse(ma.group(2) ?? '') ?? 1;
      final unit = _mapUnit(ma.group(3));
      return ParsedItem(name, rawQty <= 0 ? 1 : rawQty, unit);
    }
  }

  final mb = _b.firstMatch(trimmed);
  if (mb != null) {
    final name = _cleanName(mb.group(3) ?? '');
    if (name.isNotEmpty) {
      final rawQty = double.tryParse(mb.group(1) ?? '') ?? 1;
      final unit = _mapUnit(mb.group(2));
      return ParsedItem(name, rawQty <= 0 ? 1 : rawQty, unit);
    }
  }

  return ParsedItem(_cleanName(trimmed), 1, '');
}

String _mapUnit(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  return switch (raw.toLowerCase()) {
    'l' || 'ltr' => 'L',
    'gm' => 'g',
    'pc' => 'pcs',
    'packet' || 'packets' => 'pkt',
    final u => u,
  };
}

String _cleanName(String raw) {
  var s = raw.trim();
  if (s.endsWith(',')) {
    s = s.substring(0, s.length - 1).trimRight();
  }
  if (s.isEmpty) return '';
  return s[0].toUpperCase() + s.substring(1);
}
