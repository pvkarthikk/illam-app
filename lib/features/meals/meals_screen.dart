import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/recipes_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/ingredients.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/features/meals/add_missing_sheet.dart';
import 'package:nm_flat/features/meals/meals_controller.dart';
import 'package:nm_flat/features/meals/meals_parts.dart';
import 'package:nm_flat/features/meals/slot_picker_sheet.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class MealsScreen extends ConsumerWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final ui = ref.watch(mealsControllerProvider);
    final ctrl = ref.read(mealsControllerProvider.notifier);
    final isThisWeek = ctrl.isThisWeek;
    final today = ref.watch(todayDateProvider);

    final slotsAsync = ref.watch(weekSlotsProvider(ui.weekStart));
    final slots = slotsAsync.value ?? const <MealSlot>[];
    final recipes = ref.watch(recipesProvider).value ?? const <RecipeView>[];
    final openKeys = ref.watch(openGroceryKeysProvider).value ?? const <String>{};
    final pantryKeys = ref.watch(pantryKeysProvider).value ?? const <String>{};

    final recipesById = {for (final r in recipes) r.id: r};
    final slotByKey = <(String, String), MealSlot>{
      for (final s in slots) (s.date, s.slot): s,
    };

    final planned = <PlannedRecipe>[];
    for (var i = 0; i < 7; i++) {
      final d = Dates.addDays(ui.weekStart, i);
      if (d.compareTo(today) < 0) continue;
      for (final s in const ['breakfast', 'lunch', 'dinner']) {
        final row = slotByKey[(d, s)];
        if (row != null && row.kind == 'recipe') {
          final r = recipesById[row.recipeId];
          if (r != null) planned.add(r.toPlanned());
        }
      }
    }
    final weekMissing = missingFor(planned, openKeys, pantryKeys);

    final eyebrowDate = Formatters.safeDateFormat(
      'd MMM',
      l10n.localeName,
    ).format(Dates.parse(ui.weekStart));

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          controller:
              ref.watch(tabScrollControllersProvider)[NestTab.meals.index],
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            NestTopBar.tab(
              eyebrow: l10n.mealsWeekOf(eyebrowDate),
              title: l10n.mealsTitle,
              actions: [
                if (!isThisWeek)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: NestChip(
                      label: l10n.mealsThisWeek,
                      onTap: ctrl.thisWeek,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  tooltip: l10n.mealsPrevWeek,
                  onPressed: ctrl.prevWeek,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  tooltip: l10n.mealsNextWeek,
                  onPressed: ctrl.nextWeek,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (slotsAsync.hasError)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '${slotsAsync.error}',
                  style: NestText.meta13.copyWith(color: c.danger),
                ),
              ),
            WeekStrip(
              weekStart: ui.weekStart,
              selectedDay: ui.selectedDay,
              today: today,
              slots: slots,
              onSelect: ctrl.selectDay,
            ),
            if (weekMissing.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: AlertLine(
                  icon: Icons.shopping_cart_outlined,
                  text: '🛒 ${l10n.mealsMissingWeek(weekMissing.length)}',
                  actionLabel: l10n.mealsAddAll,
                  onAction: () => showAddMissingSheet(
                    context,
                    ref,
                    [for (final m in weekMissing) toGroceryLine(m)],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      Formatters.dayLabel(
                        ui.selectedDay,
                        today,
                        l10n,
                      ).toUpperCase(),
                      style: NestText.section13.copyWith(color: c.ink2),
                    ),
                  ),
                  if (ui.selectedDay.compareTo(today) < 0)
                    NestTag(label: l10n.mealsPastDay),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final s in const ['breakfast', 'lunch', 'dinner']) ...[
                    if (s != 'breakfast') const SizedBox(height: 10),
                    MealSlotTile(
                      date: ui.selectedDay,
                      slot: s,
                      slotRow: slotByKey[(ui.selectedDay, s)],
                      recipesById: recipesById,
                      openKeys: openKeys,
                      pantryKeys: pantryKeys,
                      onOpenPicker: (d, sl) =>
                          showSlotPicker(context, ref, date: d, slot: sl),
                    ),
                  ],
                ],
              ),
            ),
            const RecipeBookSection(),
            for (var i = 0; i < recipes.length; i += 2)
              Padding(
                padding: EdgeInsets.fromLTRB(16, i == 0 ? 4 : 12, 16, 0),
                child: RecipeGridRow(
                  left: recipes[i],
                  right: i + 1 < recipes.length ? recipes[i + 1] : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
