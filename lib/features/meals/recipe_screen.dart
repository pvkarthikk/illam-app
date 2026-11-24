import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/repo/recipes_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/ingredients.dart';
import 'package:nm_flat/core/domain/recipe_scaling.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/meals/add_missing_sheet.dart';
import 'package:nm_flat/features/meals/meals_parts.dart';
import 'package:nm_flat/features/meals/recipe_parts.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class RecipeScreen extends ConsumerStatefulWidget {
  const RecipeScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends ConsumerState<RecipeScreen> {
  int? _servings;
  final Map<String, bool> _pantryOverride = {};

  Future<void> _deleteRecipe(AppLocalizations l10n, RecipeView recipe) async {
    final today = ref.read(todayDateProvider);
    final slots = await ref
        .read(mealsRepoProvider)
        .futureSlotsFor(widget.id, today);
    if (!mounted) return;

    final distinctDates = {for (final s in slots) s.date}.length;
    List<String> clearIds = const [];
    if (distinctDates > 0) {
      final removeToo = await showNestSheet<bool>(
        context,
        (sheetCtx) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            NestSheetHeader(
              title: l10n.recipeDeletePlanned(recipe.name, distinctDates),
            ),
            NestSheetActions(
              children: [
                NestButton(
                  label: l10n.recipeKeepPlans,
                  kind: NestButtonKind.ghost,
                  onPressed: () => Navigator.of(sheetCtx).pop(false),
                ),
                NestButton(
                  label: l10n.recipeRemoveToo,
                  kind: NestButtonKind.danger,
                  onPressed: () => Navigator.of(sheetCtx).pop(true),
                ),
              ],
            ),
          ],
        ),
      );
      if (removeToo == null || !mounted) return;
      clearIds = removeToo ? [for (final s in slots) s.id] : const <String>[];
    }

    final res = await ref
        .read(recipesRepoProvider)
        .softDelete(widget.id, clearSlotIds: clearIds);
    if (!mounted) return;
    context.pop();
    ref.read(snackbarProvider).show(l10n.recipeDeleted, undo: res.undo);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final recipeAsync = ref.watch(recipeProvider(widget.id));
    final openKeys = ref.watch(openGroceryKeysProvider).value ?? const <String>{};
    final pantryKeys = ref.watch(pantryKeysProvider).value ?? const <String>{};
    _pantryOverride.removeWhere((k, v) => pantryKeys.contains(k) == v);
    final shownPantry = <String>{
      ...pantryKeys,
      for (final e in _pantryOverride.entries)
        if (e.value) e.key,
    };
    for (final e in _pantryOverride.entries) {
      if (!e.value) shownPantry.remove(e.key);
    }

    final recipe = recipeAsync.value;
    if (recipeAsync.isLoading && recipe == null) {
      return Scaffold(
        appBar: NestTopBar.sub(title: l10n.recipeTitle),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (recipe == null) {
      return Scaffold(
        appBar: NestTopBar.sub(title: l10n.recipeTitle),
        body: Center(
          child: EmptyState(
            icon: Icons.menu_book_rounded,
            title: l10n.recipeTitle,
            body: '',
            action: NestButton(
              label: l10n.commonBack,
              onPressed: () => context.pop(),
            ),
          ),
        ),
      );
    }

    final baseServes = recipe.serves < 1 ? 1 : recipe.serves;
    final servings = (_servings ??= baseServes.clamp(1, 20));
    final missingLines = recipeMissing(
      recipe.toPlanned(),
      servings,
      openKeys,
      shownPantry,
    );

    return Scaffold(
      appBar: NestTopBar.sub(
        title: l10n.recipeTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: l10n.recipeAddToPlan,
            onPressed: () => showPlanRecipeSheet(context, ref, recipe),
          ),
          PopupMenuButton<String>(
            tooltip: l10n.recipeMoreOptions,
            onSelected: (choice) {
              if (choice == 'edit') {
                context.push(Routes.recipeEdit(widget.id));
              } else if (choice == 'delete') {
                _deleteRecipe(l10n, recipe);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Text(l10n.recipeEdit),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(l10n.recipeDelete),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            RecipeHeroCard(recipe: recipe),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.recipeIngredients.toUpperCase(),
                    style: NestText.section13.copyWith(color: c.ink2),
                  ),
                ),
                QtyStepper(
                  valueText: l10n.recipePpl(servings),
                  semanticLabel: l10n.recipeServings,
                  minusTooltip: l10n.recipeFewer,
                  plusTooltip: l10n.recipeMoreServings,
                  onMinus: servings > 1
                      ? () => setState(() => _servings = servings - 1)
                      : null,
                  onPlus: servings < 20
                      ? () => setState(() => _servings = servings + 1)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            NestCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var idx = 0; idx < recipe.ingredients.length; idx++) ...[
                    if (idx > 0) Container(height: 1, color: c.line),
                    _IngredientRow(
                      ingredient: recipe.ingredients[idx],
                      qtyLabelText: qtyLabel(
                        l10n,
                        scaleQty(
                          recipe.ingredients[idx].qty,
                          baseServes,
                          servings,
                        ),
                        recipe.ingredients[idx].unit,
                      ),
                      state: ingredientState(
                        recipe.ingredients[idx].nameKey,
                        openKeys,
                        shownPantry,
                      ),
                      onTap: () async {
                        final ing = recipe.ingredients[idx];
                        final st = ingredientState(
                          ing.nameKey,
                          openKeys,
                          shownPantry,
                        );
                        final newHave = st != IngredientState.have;
                        final repo = ref.read(mealsRepoProvider);
                        final snack = ref.read(snackbarProvider);
                        final msg = newHave
                            ? l10n.recipeMarkedHave(ing.name)
                            : l10n.recipeMarkedMissing(ing.name);
                        setState(() => _pantryOverride[ing.nameKey] = newHave);
                        try {
                          final res = await repo.setPantry(
                            ing.name,
                            ing.nameKey,
                            newHave,
                          );
                          if (res.undo != null) {
                            snack.show(msg, undo: res.undo);
                          } else if (mounted &&
                              _pantryOverride[ing.nameKey] == newHave) {
                            setState(
                              () => _pantryOverride.remove(ing.nameKey),
                            );
                          }
                        } on Object {
                          if (mounted &&
                              _pantryOverride[ing.nameKey] == newHave) {
                            setState(
                              () => _pantryOverride.remove(ing.nameKey),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _LegendItem(
                  icon: Icons.check_rounded,
                  bg: c.primarySoft,
                  fg: c.primary,
                  label: l10n.recipeInKitchen,
                ),
                _LegendItem(
                  icon: Icons.shopping_cart_outlined,
                  bg: c.accentSoft,
                  fg: c.accentInk,
                  label: l10n.recipeOnList,
                ),
                _LegendItem(
                  icon: Icons.remove_rounded,
                  bg: c.dangerSoft,
                  fg: c.danger,
                  label: l10n.recipeMissing,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (missingLines.isNotEmpty)
              NestButton(
                label: l10n.recipeAddMissing(missingLines.length),
                kind: NestButtonKind.primary,
                size: NestButtonSize.block,
                onPressed: () => showAddMissingSheet(
                  context,
                  ref,
                  [for (final m in missingLines) toGroceryLine(m)],
                ),
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: NestTag(
                  label: l10n.recipeAllThere,
                  kind: NestTagKind.ok,
                ),
              ),
            const SizedBox(height: 24),
            Semantics(
              header: true,
              child: Text(
                l10n.recipeMethod.toUpperCase(),
                style: NestText.section13.copyWith(color: c.ink2),
              ),
            ),
            const SizedBox(height: 8),
            NestCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var s = 0; s < recipe.steps.length; s++) ...[
                    if (s > 0) const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            '${s + 1}',
                            style: NestText.cardTitle20.copyWith(
                              color: c.accent,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            recipe.steps[s],
                            style: NestText.body15.copyWith(color: c.ink),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            NestButton(
              label: l10n.recipeStartCook,
              kind: NestButtonKind.accent,
              size: NestButtonSize.block,
              onPressed: () => context.push(Routes.cook(widget.id)),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.ingredient,
    required this.qtyLabelText,
    required this.state,
    required this.onTap,
  });

  final Ingredient ingredient;
  final String qtyLabelText;
  final IngredientState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final (icon, bg, fg, srState) = switch (state) {
      IngredientState.have => (
        Icons.check_rounded,
        c.primarySoft,
        c.primary,
        l10n.recipeSrHave,
      ),
      IngredientState.onList => (
        Icons.shopping_cart_outlined,
        c.accentSoft,
        c.accentInk,
        l10n.recipeSrOnList,
      ),
      IngredientState.missing => (
        Icons.remove_rounded,
        c.dangerSoft,
        c.danger,
        l10n.recipeSrMissing,
      ),
    };

    return MergeSemantics(
      child: Semantics(
        button: true,
        label: '${ingredient.name}, $qtyLabelText, $srState',
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                    child: Icon(icon, size: 15, color: fg),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ingredient.name,
                      style: NestText.body15.copyWith(color: c.ink),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    qtyLabelText,
                    style: NestText.figures16.copyWith(color: c.ink2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.label,
  });

  final IconData icon;
  final Color bg;
  final Color fg;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, size: 11, color: fg),
        ),
        const SizedBox(width: 4),
        Text(label, style: NestText.small12.copyWith(color: c.ink3)),
      ],
    );
  }
}
