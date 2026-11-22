import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/recipes_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/ingredients.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/features/meals/add_missing_sheet.dart';
import 'package:nm_flat/features/meals/slot_picker_sheet.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class MenuSection extends ConsumerWidget {
  const MenuSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(todayDateProvider);
    final monday = Dates.addDays(today, 1 - Dates.weekdayIso(today));
    final slots = ref.watch(weekSlotsProvider(monday)).value ?? const <MealSlot>[];
    final recipes = ref.watch(recipesProvider).value ?? const <RecipeView>[];
    final openKeys = ref.watch(openGroceryKeysProvider).value ?? const <String>{};
    final pantryKeys = ref.watch(pantryKeysProvider).value ?? const <String>{};

    final recipesById = {for (final r in recipes) r.id: r};
    final todayBySlot = <String, MealSlot>{
      for (final s in slots)
        if (s.date == today && s.kind.isNotEmpty) s.slot: s,
    };

    const slotOrder = ['breakfast', 'lunch', 'dinner'];
    final todayPlanned = <PlannedRecipe>[];
    for (final s in slotOrder) {
      final row = todayBySlot[s];
      if (row != null && row.kind == 'recipe') {
        final r = recipesById[row.recipeId];
        if (r != null) todayPlanned.add(r.toPlanned());
      }
    }
    final missingLines = missingFor(todayPlanned, openKeys, pantryKeys);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        SectionHeader(
          title: l10n.todayMenuTitle,
          actionLabel: l10n.todayWeekPlan,
          onAction: () => context.go(Routes.meals),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < slotOrder.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: _TodayMenuTile(
                          today: today,
                          slot: slotOrder[i],
                          row: todayBySlot[slotOrder[i]],
                          recipesById: recipesById,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (missingLines.isNotEmpty) ...[
                const SizedBox(height: 10),
                AlertLine(
                  icon: Icons.shopping_cart_outlined,
                  text: l10n.todayMissingToday(missingLines.length),
                  actionLabel: l10n.todayAddToList,
                  onAction: () => showAddMissingSheet(
                    context,
                    ref,
                    [for (final m in missingLines) toGroceryLine(m)],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayMenuTile extends ConsumerWidget {
  const _TodayMenuTile({
    required this.today,
    required this.slot,
    required this.row,
    required this.recipesById,
  });

  final String today;
  final String slot;
  final MealSlot? row;
  final Map<String, RecipeView> recipesById;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final slotLabel = Text(
      l10n.mealsSlotTitle(slot).toUpperCase(),
      style: const TextStyle(
        fontFamily: NestText.sans,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        fontVariations: [FontVariation.weight(800)],
      ).copyWith(color: c.ink3),
    );

    final rRow = row;
    if (rRow == null || rRow.kind.isEmpty) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 92),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showSlotPicker(context, ref, date: today, slot: slot),
          child: DashedBox(
            radius: 16,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                slotLabel,
                const SizedBox(height: 6),
                Text(
                  l10n.todayPlan,
                  style: NestText.meta13.copyWith(color: c.ink2),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (rRow.kind == 'recipe') {
      final recipe = recipesById[rRow.recipeId];
      if (recipe == null) {
        return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 92),
          child: NestCard(
            padding: const EdgeInsets.all(12),
            onTap: () => showSlotPicker(context, ref, date: today, slot: slot),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                slotLabel,
                const SizedBox(height: 6),
                Text(
                  l10n.mealsRemoved(rRow.nameSnapshot ?? ''),
                  style: NestText.meta13.copyWith(color: c.ink2),
                ),
              ],
            ),
          ),
        );
      }

      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 92),
        child: NestCard(
          padding: const EdgeInsets.all(12),
          onTap: () => context.push(Routes.recipe(recipe.id)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  slotLabel,
                  const SizedBox(height: 6),
                  Text(
                    recipe.name,
                    style: TextStyle(
                      fontFamily: NestText.serif,
                      fontSize: 15,
                      color: c.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.mealsMinutes(recipe.timeMin),
                style: NestText.small12.copyWith(color: c.ink3),
              ),
            ],
          ),
        ),
      );
    }

    final text = switch (rRow.kind) {
      'eatingOut' => l10n.mealsEatingOut,
      'leftovers' => l10n.mealsLeftovers,
      _ => rRow.slotText ?? '',
    };

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 92),
      child: NestCard(
        padding: const EdgeInsets.all(12),
        onTap: () => showSlotPicker(context, ref, date: today, slot: slot),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            slotLabel,
            const SizedBox(height: 6),
            Text(
              text,
              style: NestText.meta13.copyWith(color: c.ink),
            ),
          ],
        ),
      ),
    );
  }
}
