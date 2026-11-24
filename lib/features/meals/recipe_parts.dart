import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/repo/recipes_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/features/meals/meals_parts.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class RecipeHeroCard extends StatelessWidget {
  const RecipeHeroCard({super.key, required this.recipe});

  final RecipeView recipe;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bg = recipeColor(recipe.color);
    final fg = glyphOn(bg);
    final muted = fg.withValues(alpha: 0.85);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(26),
      ),
      clipBehavior: Clip.antiAlias,
      child: KolamBackground(
        color: Colors.white.withValues(alpha: 0.20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.name,
                style: NestText.display34.copyWith(color: fg),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  Text(
                    '🕒 ${l10n.mealsMinutes(recipe.timeMin)}',
                    style: NestText.meta13.copyWith(color: muted),
                  ),
                  Text(
                    '👥 ${l10n.recipeServes(recipe.serves)}',
                    style: NestText.meta13.copyWith(color: muted),
                  ),
                  if (recipe.allTags.isNotEmpty)
                    Text(
                      recipe.allTags.join(' · '),
                      style: NestText.meta13.copyWith(color: muted),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showPlanRecipeSheet(
  BuildContext context,
  WidgetRef ref,
  RecipeView r,
) => showNestSheet<void>(context, (_) => _PlanRecipeSheet(recipe: r));

class _PlanRecipeSheet extends ConsumerStatefulWidget {
  const _PlanRecipeSheet({required this.recipe});

  final RecipeView recipe;

  @override
  ConsumerState<_PlanRecipeSheet> createState() => _PlanRecipeSheetState();
}

class _PlanRecipeSheetState extends ConsumerState<_PlanRecipeSheet> {
  late String _day;
  String _slot = 'dinner';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _day = ref.read(todayDateProvider);
  }

  Future<void> _save(AppLocalizations l10n, String today) async {
    if (_saving) return;
    setState(() => _saving = true);
    final repo = ref.read(mealsRepoProvider);
    final snack = ref.read(snackbarProvider);
    final day = _day;
    final slot = _slot;
    final recipe = widget.recipe;
    final msg = l10n.recipePlannedFor(
      Formatters.dayLabel(day, today, l10n),
      l10n.mealsSlotLower(slot),
    );
    Navigator.of(context).pop();
    try {
      final res = await repo.planRecipe(day, slot, recipe);
      if (res.undo != null) {
        snack.show(msg, undo: res.undo);
      }
    } on Object {
      // Ignore write error after closing the sheet.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final today = ref.watch(todayDateProvider);
    final remaining = 7 - Dates.weekdayIso(today);
    final days = [for (var i = 0; i <= remaining; i++) Dates.addDays(today, i)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(title: l10n.recipePlanTitle(widget.recipe.name)),
        Text(
          l10n.recipePlanDay,
          style: NestText.small12.copyWith(color: c.ink2),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final d in days)
              NestChip(
                label: Formatters.dayLabel(d, today, l10n),
                selected: _day == d,
                onTap: () => setState(() => _day = d),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          l10n.recipePlanMeal,
          style: NestText.small12.copyWith(color: c.ink2),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final s in const ['breakfast', 'lunch', 'dinner'])
              NestChip(
                label: l10n.mealsSlotTitle(s),
                selected: _slot == s,
                onTap: () => setState(() => _slot = s),
              ),
          ],
        ),
        const SizedBox(height: 20),
        NestButton(
          label: l10n.recipePlanAdd,
          kind: NestButtonKind.primary,
          size: NestButtonSize.block,
          onPressed: _saving ? null : () => _save(l10n, today),
        ),
      ],
    );
  }
}
