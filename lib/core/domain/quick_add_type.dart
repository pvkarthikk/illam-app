enum QaType { grocery, shopping, todo, spend }

final _rupeeSymbolRe = RegExp(r'₹', caseSensitive: false);
final _rsRe = RegExp(r'\brs\.?\s*\d', caseSensitive: false);
final _paidSpentRe = RegExp(r'\b(paid|spent)\s+\d', caseSensitive: false);
final _leadingNumberNonUnitRe = RegExp(
  r'^\d+\s+(?!(kg|g|gm|l|ltr|ml|pcs|pc|dozen|bunch|packets?|x)\b)\D',
  caseSensitive: false,
);
final _todoRe = RegExp(
  r'\b(call|book|pay|renew|fix|meeting|return|schedule|remind|tomorrow|today|tonight|monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
  caseSensitive: false,
);
final _shoppingRe = RegExp(
  r'\b(shoe|shoes|cable|charger|shirt|kurta|bedsheet|bulb|bulbs|filter|battery|batteries|towel|towels|bag)\b',
  caseSensitive: false,
);

QaType detectQuickAddType(String text) {
  final t = text.trim();
  if (_rupeeSymbolRe.hasMatch(t) ||
      _rsRe.hasMatch(t) ||
      _paidSpentRe.hasMatch(t) ||
      _leadingNumberNonUnitRe.hasMatch(t)) {
    return QaType.spend;
  }
  if (_todoRe.hasMatch(t)) return QaType.todo;
  if (_shoppingRe.hasMatch(t)) return QaType.shopping;
  return QaType.grocery;
}
