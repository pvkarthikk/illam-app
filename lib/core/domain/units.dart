const groceryUnits = [
  '',
  'pcs',
  'dozen',
  'bunch',
  'pkt',
  'g',
  'kg',
  'ml',
  'L',
];

const kitchenUnits = [
  'tsp',
  'tbsp',
  'cup',
  'inch',
  'clove',
  'sprig',
  'pinch',
  'small',
  'lemon size',
];

enum UnitFamily { mass, volume, kitchen, count }

UnitFamily familyOf(String u) => switch (u) {
  'g' || 'kg' => UnitFamily.mass,
  'ml' || 'L' => UnitFamily.volume,
  _ when kitchenUnits.contains(u) => UnitFamily.kitchen,
  _ => UnitFamily.count,
};

String compatKey(String u) => switch (familyOf(u)) {
  UnitFamily.mass => 'mass',
  UnitFamily.volume => 'volume',
  _ => 'u:$u',
};

int? convertMilli(int milli, String from, String to) {
  if (from == to) return milli;
  return switch ((from, to)) {
    ('g', 'kg') || ('ml', 'L') => (milli / 1000).round(),
    ('kg', 'g') || ('L', 'ml') => milli * 1000,
    _ => null,
  };
}

int stepMilli(String u) => switch (u) {
  'g' || 'ml' => 100000,
  'kg' || 'L' => 500,
  _ => 1000,
};

String formatQty(int milli, String u) {
  final numText = (milli / 1000)
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'\.?0+$'), '');
  return u.isEmpty ? '×$numText' : '$numText $u';
}

const allUnits = <String>[...groceryUnits, ...kitchenUnits];

double toBaseQty(double qty, String unit) =>
    (unit == 'kg' || unit == 'L') ? qty * 1000 : qty;

String baseUnit(String unit) => switch (unit) {
  'kg' || 'g' => 'g',
  'L' || 'ml' => 'ml',
  _ => unit,
};
