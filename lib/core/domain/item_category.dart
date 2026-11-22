const _rules = <(String category, List<String> keywords)>[
  ('Dairy', ['milk', 'curd', 'paneer', 'butter', 'cheese', 'ghee', 'cream']),
  (
    'Vegetables',
    [
      'tomato',
      'onion',
      'potato',
      'chilli',
      'coriander',
      'carrot',
      'beans',
      'veg',
    ],
  ),
  ('Fruits', ['apple', 'banana', 'mango', 'orange', 'grape', 'fruit']),
  ('Staples', ['rice', 'dal', 'atta', 'flour', 'rava', 'sugar', 'salt', 'oil']),
  ('Cleaning', ['soap', 'detergent', 'dishwash', 'cleaner', 'phenyl']),
  ('Breakfast', ['egg', 'bread']),
  ('Electronics', ['cable', 'charger', 'battery', 'batteries', 'bulb']),
];

String guessCategory(String name) {
  final lower = name.toLowerCase();
  for (final (category, keywords) in _rules) {
    for (final k in keywords) {
      if (lower.contains(k)) return category;
    }
  }
  return 'Other';
}

const groceryCategories = [
  'Dairy',
  'Vegetables',
  'Fruits',
  'Staples',
  'Cleaning',
  'Breakfast',
  'Electronics',
  'Other',
];

const shoppingCategories = [
  ...groceryCategories,
  'Kids',
  'Home',
  'Hardware',
];

List<String> categoriesFor(String list) =>
    list == 'shopping' ? shoppingCategories : groceryCategories;
