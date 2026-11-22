class IngredientDraft {
  IngredientDraft({this.name = '', this.qtyText = '', this.unit = ''});

  String name;
  String qtyText;
  String unit;

  IngredientDraft copyWith({String? name, String? qtyText, String? unit}) =>
      IngredientDraft(
        name: name ?? this.name,
        qtyText: qtyText ?? this.qtyText,
        unit: unit ?? this.unit,
      );
}

class RecipeDraft {
  RecipeDraft({
    this.name = '',
    this.timeMin,
    this.serves = 4,
    List<String>? mealTypes,
    List<String>? tags,
    List<String>? steps,
    List<IngredientDraft>? ingredients,
  }) : mealTypes = mealTypes ?? [],
       tags = tags ?? [],
       steps = steps ?? [],
       ingredients = ingredients ?? [];

  String name;
  int? timeMin;
  int? serves;
  List<String> mealTypes;
  List<String> tags;
  List<String> steps;
  List<IngredientDraft> ingredients;

  RecipeDraft copyWith({
    String? name,
    int? timeMin,
    bool clearTimeMin = false,
    int? serves,
    bool clearServes = false,
    List<String>? mealTypes,
    List<String>? tags,
    List<String>? steps,
    List<IngredientDraft>? ingredients,
  }) => RecipeDraft(
    name: name ?? this.name,
    timeMin: clearTimeMin ? null : (timeMin ?? this.timeMin),
    serves: clearServes ? null : (serves ?? this.serves),
    mealTypes: mealTypes ?? List<String>.from(this.mealTypes),
    tags: tags ?? List<String>.from(this.tags),
    steps: steps ?? List<String>.from(this.steps),
    ingredients:
        ingredients ?? [for (final i in this.ingredients) i.copyWith()],
  );
}

final _decimalRe = RegExp(r'^-?\d+(?:\.\d+)?$');
final _fractionRe = RegExp(r'^(\d+)/(\d+)$');

double? parseQty(String s) {
  final trimmed = s.trim();
  if (trimmed.isEmpty) return null;
  if (_decimalRe.hasMatch(trimmed)) {
    return double.tryParse(trimmed);
  }
  final m = _fractionRe.firstMatch(trimmed);
  if (m != null) {
    final num = int.tryParse(m.group(1)!);
    final den = int.tryParse(m.group(2)!);
    if (num == null || den == null || den == 0) return null;
    return num / den;
  }
  return null;
}

Map<String, String> validateRecipe(RecipeDraft d) {
  final errors = <String, String>{};
  final trimmedName = d.name.trim();
  if (trimmedName.isEmpty || trimmedName.length > 60) {
    errors['name'] = 'recipeErrName';
  }
  final time = d.timeMin;
  if (time == null || time < 1 || time > 600) {
    errors['time'] = 'recipeErrTime';
  }
  final serves = d.serves;
  if (serves == null || serves < 1 || serves > 20) {
    errors['serves'] = 'recipeErrServes';
  }
  if (d.ingredients.isEmpty) {
    errors['ingredients'] = 'recipeErrIngredients';
  } else {
    for (var i = 0; i < d.ingredients.length; i++) {
      final ing = d.ingredients[i];
      if (ing.name.trim().isEmpty) {
        errors['ingName.$i'] = 'recipeErrIngName';
      }
      final q = parseQty(ing.qtyText);
      if (q == null || q <= 0) {
        errors['ingQty.$i'] = 'recipeErrQty';
      }
    }
  }
  if (!d.steps.any((s) => s.trim().isNotEmpty)) {
    errors['steps'] = 'recipeErrSteps';
  }
  for (var i = 0; i < d.steps.length; i++) {
    if (d.steps[i].length > 500) {
      errors['step.$i'] = 'recipeErrStepLong';
    }
  }
  return errors;
}
