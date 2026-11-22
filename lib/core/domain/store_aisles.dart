const aisleOrder = [
  'Vegetables',
  'Fruits',
  'Dairy',
  'Breakfast',
  'Staples',
  'Cleaning',
  'Electronics',
  'Home',
  'Kids',
  'Hardware',
  'Other',
];

List<String> sortAisles(Iterable<String> categories) {
  final distinct = categories.toSet();
  final known = [
    for (final a in aisleOrder)
      if (distinct.contains(a)) a,
  ];
  final unknown = [
    for (final c in distinct)
      if (!aisleOrder.contains(c)) c,
  ]..sort();
  return [...known, ...unknown];
}
