import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/data/repo/recipes_repo.dart';
import 'package:nm_flat/core/domain/recipe_validation.dart';

class RecipeEditState {
  const RecipeEditState({
    required this.draft,
    this.dirty = false,
    this.errors = const {},
    this.loaded = false,
  });

  final RecipeDraft draft;
  final bool dirty;
  final Map<String, String> errors;
  final bool loaded;

  RecipeEditState copyWith({
    RecipeDraft? draft,
    bool? dirty,
    Map<String, String>? errors,
    bool? loaded,
  }) => RecipeEditState(
    draft: draft ?? this.draft,
    dirty: dirty ?? this.dirty,
    errors: errors ?? this.errors,
    loaded: loaded ?? this.loaded,
  );
}

class RecipeEditController extends Notifier<RecipeEditState> {
  RecipeEditController(this.id);

  final String id;

  @override
  RecipeEditState build() {
    if (id == 'new') {
      return RecipeEditState(
        draft: RecipeDraft(
          serves: 4,
          ingredients: [IngredientDraft(unit: '')],
          steps: [''],
        ),
        loaded: true,
      );
    }
    return RecipeEditState(draft: RecipeDraft());
  }

  void load(RecipeView r) {
    if (state.loaded) return;
    state = RecipeEditState(
      draft: RecipeDraft(
        name: r.name,
        timeMin: r.timeMin,
        serves: r.serves,
        mealTypes: List<String>.from(r.mealTypes),
        tags: List<String>.from(r.tags),
        steps: r.steps.isEmpty ? [''] : List<String>.from(r.steps),
        ingredients: r.ingredients.isEmpty
            ? [IngredientDraft(unit: '')]
            : [
                for (final i in r.ingredients)
                  IngredientDraft(
                    name: i.name,
                    qtyText: i.qty
                        .toStringAsFixed(2)
                        .replaceFirst(RegExp(r'\.?0+$'), ''),
                    unit: i.unit,
                  ),
              ],
      ),
      dirty: false,
      errors: const {},
      loaded: true,
    );
  }

  void update(RecipeDraft d) {
    state = state.copyWith(draft: d, dirty: true);
  }

  void addIngredient() {
    final next = state.draft.copyWith(
      ingredients: [
        for (final i in state.draft.ingredients) i.copyWith(),
        IngredientDraft(unit: ''),
      ],
    );
    state = state.copyWith(draft: next, dirty: true);
  }

  void removeIngredient(int index) {
    final list = [for (final i in state.draft.ingredients) i.copyWith()];
    list.removeAt(index);
    state = state.copyWith(
      draft: state.draft.copyWith(ingredients: list),
      dirty: true,
    );
  }

  void moveIngredient(int from, int to) {
    final list = [for (final i in state.draft.ingredients) i.copyWith()];
    if (to < 0 || to >= list.length) return;
    final item = list.removeAt(from);
    list.insert(to, item);
    state = state.copyWith(
      draft: state.draft.copyWith(ingredients: list),
      dirty: true,
    );
  }

  void addStep() {
    final list = [...state.draft.steps, ''];
    state = state.copyWith(
      draft: state.draft.copyWith(steps: list),
      dirty: true,
    );
  }

  void removeStep(int index) {
    final list = [...state.draft.steps]..removeAt(index);
    state = state.copyWith(
      draft: state.draft.copyWith(steps: list),
      dirty: true,
    );
  }

  void moveStep(int from, int to) {
    final list = [...state.draft.steps];
    if (to < 0 || to >= list.length) return;
    final item = list.removeAt(from);
    list.insert(to, item);
    state = state.copyWith(
      draft: state.draft.copyWith(steps: list),
      dirty: true,
    );
  }

  void markClean() {
    state = state.copyWith(dirty: false);
  }

  Map<String, String> validate() {
    final errs = validateRecipe(state.draft);
    state = state.copyWith(errors: errs);
    return errs;
  }
}

final recipeEditControllerProvider =
    NotifierProvider.family<RecipeEditController, RecipeEditState, String>(
      RecipeEditController.new,
    );
