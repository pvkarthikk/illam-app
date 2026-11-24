import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/recipes_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/fractions.dart';
import 'package:nm_flat/core/domain/ingredients.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/features/meals/add_recipe_sheet.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Color recipeColor(String hex) {
  final clean = hex.replaceFirst('#', '');
  if (clean.length != 6) return const Color(0xFF5E8A2B);
  final parsed = int.tryParse('FF$clean', radix: 16);
  return parsed == null ? const Color(0xFF5E8A2B) : Color(parsed);
}

Color glyphOn(Color bg) {
  final contrast = 1.05 / (bg.computeLuminance() + 0.05);
  return contrast >= 3.0 ? Colors.white : const Color(0xFF1B140A);
}

String qtyLabel(AppLocalizations l10n, double qty, String unit) {
  final f = formatFraction(qty, unit);
  final numText = f == 'a pinch' ? l10n.recipeAPinch : f;
  return unit.isEmpty ? numText : '$numText $unit';
}

class RecipeArt extends StatelessWidget {
  const RecipeArt({
    super.key,
    required this.r,
    this.size = 64,
    this.glyphSize = 26,
    this.radius = 16,
  });

  final RecipeView r;
  final double size;
  final double glyphSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bg = recipeColor(r.color);
    final fg = glyphOn(bg);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: KolamBackground(
          color: Colors.white.withValues(alpha: 0.22),
          child: Center(
            child: Text(
              r.glyph,
              style: TextStyle(
                fontFamily: NestText.serif,
                fontSize: glyphSize,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.weekStart,
    required this.selectedDay,
    required this.today,
    required this.slots,
    required this.onSelect,
  });

  final String weekStart;
  final String selectedDay;
  final String today;
  final List<MealSlot> slots;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final byDay = <String, Set<String>>{};
    for (final s in slots) {
      if (s.kind.isNotEmpty) {
        (byDay[s.date] ??= {}).add(s.slot);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: Builder(
                builder: (ctx) {
                  final iso = Dates.addDays(weekStart, i);
                  final dt = Dates.parse(iso);
                  final selected = iso == selectedDay;
                  final isToday = iso == today;
                  final daySlots = byDay[iso] ?? const <String>{};
                  final shortDay = DateFormat('EE', 'en')
                      .format(dt)
                      .substring(0, 2)
                      .toUpperCase();
                  final fullDay = DateFormat('EEEE', 'en').format(dt);
                  final fg = selected ? c.paper : c.ink;

                  return Semantics(
                    button: true,
                    selected: selected,
                    label: l10n.mealsDaySemantics(
                      fullDay,
                      '${dt.day}',
                      daySlots.length,
                    ),
                    excludeSemantics: true,
                    child: Material(
                      color: selected ? c.ink : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: (!selected && isToday)
                            ? BorderSide(color: c.accent, width: 1.5)
                            : BorderSide.none,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => onSelect(iso),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 66),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  shortDay,
                                  style: TextStyle(
                                    fontFamily: NestText.sans,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    fontVariations: const [
                                      FontVariation.weight(700),
                                    ],
                                    color: selected ? c.paper : c.ink3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${dt.day}',
                                  style: TextStyle(
                                    fontFamily: NestText.sans,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    fontVariations: const [
                                      FontVariation.weight(800),
                                    ],
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                    color: fg,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (final s in const [
                                      'breakfast',
                                      'lunch',
                                      'dinner',
                                    ]) ...[
                                      if (s != 'breakfast')
                                        const SizedBox(width: 3),
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: daySlots.contains(s)
                                              ? c.accent
                                              : c.line2,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class MealSlotTile extends StatelessWidget {
  const MealSlotTile({
    super.key,
    required this.date,
    required this.slot,
    required this.slotRow,
    required this.recipesById,
    required this.openKeys,
    required this.pantryKeys,
    required this.onOpenPicker,
  });

  final String date;
  final String slot;
  final MealSlot? slotRow;
  final Map<String, RecipeView> recipesById;
  final Set<String> openKeys;
  final Set<String> pantryKeys;
  final void Function(String date, String slot) onOpenPicker;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final row = slotRow;
    final slotTitle = l10n.mealsSlotTitle(slot);
    final slotLower = l10n.mealsSlotLower(slot);

    if (row == null || row.kind.isEmpty) {
      return InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onOpenPicker(date, slot),
        child: DashedBox(
          radius: 18,
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: c.paper2,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.add_rounded, color: c.ink2),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        slotTitle.toUpperCase(),
                        style: NestText.eyebrow12.copyWith(color: c.ink3),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.mealsPlanSlot(slotLower),
                        style: NestText.itemTitle16.copyWith(color: c.ink),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.mealsPickFromBook,
                        style: NestText.meta13.copyWith(color: c.ink3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (row.kind == 'recipe') {
      final recipe = recipesById[row.recipeId];
      if (recipe == null) {
        return NestCard(
          padding: const EdgeInsets.all(14),
          onTap: () => onOpenPicker(date, slot),
          child: Row(
            children: [
              Icon(Icons.restaurant_menu_rounded, color: c.ink3),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slotTitle.toUpperCase(),
                      style: NestText.eyebrow12.copyWith(color: c.ink3),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.mealsRemoved(row.nameSnapshot ?? ''),
                      style: NestText.itemTitle16.copyWith(color: c.ink2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      final missingCount = recipeMissing(
        recipe.toPlanned(),
        recipe.serves,
        openKeys,
        pantryKeys,
      ).length;

      return NestCard(
        padding: const EdgeInsets.all(12),
        onTap: () => context.push(Routes.recipe(recipe.id)),
        child: Row(
          children: [
            RecipeArt(r: recipe),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    slotTitle.toUpperCase(),
                    style: NestText.eyebrow12.copyWith(color: c.ink3),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    recipe.name,
                    style: TextStyle(
                      fontFamily: NestText.serif,
                      fontSize: 19,
                      color: c.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 4,
                    children: [
                      Text(
                        l10n.mealsMinutes(recipe.timeMin),
                        style: NestText.meta13.copyWith(color: c.ink3),
                      ),
                      Text(
                        '·',
                        style: NestText.meta13.copyWith(color: c.ink3),
                      ),
                      if (missingCount > 0)
                        Text(
                          l10n.mealsMissingCount(missingCount),
                          style: NestText.meta13.copyWith(
                            color: c.danger,
                            fontWeight: FontWeight.w700,
                            fontVariations: const [FontVariation.weight(700)],
                          ),
                        )
                      else
                        Text(
                          l10n.mealsReadyToCook,
                          style: NestText.meta13.copyWith(color: c.ink3),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.swap_horiz_rounded),
              tooltip: l10n.mealsChangeSlot(slotLower),
              onPressed: () => onOpenPicker(date, slot),
            ),
          ],
        ),
      );
    }

    final (icon, label) = switch (row.kind) {
      'eatingOut' => (Icons.restaurant_rounded, l10n.mealsEatingOut),
      'leftovers' => (Icons.recycling_rounded, l10n.mealsLeftovers),
      _ => (Icons.edit_note_rounded, row.slotText ?? ''),
    };

    return NestCard(
      padding: const EdgeInsets.all(14),
      onTap: () => onOpenPicker(date, slot),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.paper2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: c.ink2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slotTitle.toUpperCase(),
                  style: NestText.eyebrow12.copyWith(color: c.ink3),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: NestText.itemTitle16.copyWith(color: c.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeBookSection extends ConsumerWidget {
  const RecipeBookSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final recipesAsync = ref.watch(recipesProvider);
    final recipes = recipesAsync.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        SectionHeader(
          title: l10n.mealsRecipeBook,
          actionLabel: '+ ${l10n.mealsAdd}',
          onAction: () => showAddRecipeSheet(context),
        ),
        Builder(
          builder: (_) {
            final Widget? stateChild;
            if (recipesAsync.isLoading && recipes == null) {
              stateChild = const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (recipesAsync.hasError && recipes == null) {
              stateChild = Text(
                '${recipesAsync.error}',
                style: NestText.meta13.copyWith(color: c.danger),
              );
            } else if ((recipes ?? const <RecipeView>[]).isEmpty) {
              stateChild = NestCard(
                child: EmptyState(
                  icon: Icons.menu_book_rounded,
                  title: l10n.mealsEmptyTitle,
                  body: l10n.mealsEmptyBody,
                  action: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      const _StarterPackButton(),
                      NestButton(
                        label: l10n.mealsTypeRecipe,
                        kind: NestButtonKind.ghost,
                        onPressed: () => context.push(Routes.recipeEdit('new')),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              stateChild = null;
            }
            if (stateChild == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: stateChild,
            );
          },
        ),
      ],
    );
  }
}

class _StarterPackButton extends ConsumerStatefulWidget {
  const _StarterPackButton();

  @override
  ConsumerState<_StarterPackButton> createState() => _StarterPackButtonState();
}

class _StarterPackButtonState extends ConsumerState<_StarterPackButton> {
  bool _busy = false;

  Future<void> _add(AppLocalizations l10n) async {
    if (_busy) return;
    setState(() => _busy = true);
    final snackbar = ref.read(snackbarProvider);
    try {
      final (added, res) = await ref.read(recipesRepoProvider).addStarterPack();
      if (added > 0) {
        snackbar.show(l10n.mealsStarterAdded(added), undo: res?.undo);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NestButton(
      label: l10n.mealsAddStarter,
      kind: NestButtonKind.tonal,
      onPressed: _busy ? null : () => _add(l10n),
    );
  }
}

class RecipeGridRow extends StatelessWidget {
  const RecipeGridRow({super.key, required this.left, this.right});

  final RecipeView left;
  final RecipeView? right;

  @override
  Widget build(BuildContext context) {
    final r = right;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _RecipeGridCard(r: left)),
        const SizedBox(width: 12),
        Expanded(
          child: r != null ? _RecipeGridCard(r: r) : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _RecipeGridCard extends StatelessWidget {
  const _RecipeGridCard({required this.r});

  final RecipeView r;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final bg = recipeColor(r.color);
    final fg = glyphOn(bg);
    final meta = r.allTags.isEmpty
        ? l10n.mealsMinutes(r.timeMin)
        : l10n.mealsCardMeta(r.timeMin, r.allTags.first);

    return Semantics(
      button: true,
      child: NestCard(
        onTap: () => context.push(Routes.recipe(r.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(
              child: Container(
                height: 84,
                color: bg,
                child: KolamBackground(
                  color: Colors.white.withValues(alpha: 0.22),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        r.glyph,
                        style: TextStyle(
                          fontFamily: NestText.serif,
                          fontSize: 30,
                          color: fg,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.name,
                    style: const TextStyle(
                      fontFamily: NestText.sans,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontVariations: [FontVariation.weight(700)],
                    ).copyWith(color: c.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    style: NestText.meta13.copyWith(color: c.ink3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
