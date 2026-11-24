import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/recipes_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/ingredients.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/features/meals/meals_parts.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showSlotPicker(
  BuildContext context,
  WidgetRef ref, {
  required String date,
  required String slot,
}) => showNestSheet<void>(
  context,
  (_) => _SlotPickerSheet(date: date, slot: slot),
);

class _SlotPickerSheet extends ConsumerStatefulWidget {
  const _SlotPickerSheet({required this.date, required this.slot});

  final String date;
  final String slot;

  @override
  ConsumerState<_SlotPickerSheet> createState() => _SlotPickerSheetState();
}

class _SlotPickerSheetState extends ConsumerState<_SlotPickerSheet> {
  final _noteCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  bool _showNote = false;
  String _query = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final monday = Dates.addDays(
      widget.date,
      1 - Dates.weekdayIso(widget.date),
    );
    final slots = ref.read(weekSlotsProvider(monday)).value ?? const [];
    for (final s in slots) {
      if (s.date == widget.date && s.slot == widget.slot && s.kind == 'note') {
        _noteCtrl.text = s.slotText ?? '';
        _showNote = true;
        break;
      }
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  String get _mealTypeTag => switch (widget.slot) {
    'breakfast' => 'Breakfast',
    'lunch' => 'Lunch',
    _ => 'Dinner',
  };

  Future<void> _planKind(
    AppLocalizations l10n,
    String kind, {
    String? text,
  }) async {
    if (_saving) return;
    setState(() => _saving = true);
    final repo = ref.read(mealsRepoProvider);
    final snack = ref.read(snackbarProvider);
    final date = widget.date;
    final slot = widget.slot;
    final what = switch (kind) {
      'eatingOut' => l10n.mealsEatingOut,
      'leftovers' => l10n.mealsLeftovers,
      _ => text ?? '',
    };
    final msg = l10n.mealsPlannedKind(l10n.mealsSlotTitle(slot), what);
    Navigator.of(context).pop();
    try {
      final res = await repo.planKind(date, slot, kind, text: text);
      if (res.undo != null) {
        snack.show(msg, undo: res.undo);
      }
    } on Object {
      // Ignore write error after closing the sheet.
    }
  }

  Future<void> _pickRecipe(AppLocalizations l10n, RecipeView r) async {
    if (_saving) return;
    setState(() => _saving = true);
    final repo = ref.read(mealsRepoProvider);
    final snack = ref.read(snackbarProvider);
    final openKeys =
        ref.read(openGroceryKeysProvider).value ?? const <String>{};
    final pantryKeys = ref.read(pantryKeysProvider).value ?? const <String>{};
    final n = recipeMissing(
      r.toPlanned(),
      r.serves,
      openKeys,
      pantryKeys,
    ).length;
    final date = widget.date;
    final slot = widget.slot;
    final msg = n > 0
        ? l10n.mealsPlannedMissing(r.name, n)
        : l10n.mealsPlanned(r.name);
    Navigator.of(context).pop();
    try {
      final res = await repo.planRecipe(date, slot, r);
      if (res.undo != null) {
        snack.show(msg, undo: res.undo);
      }
    } on Object {
      // Ignore write error after closing the sheet.
    }
  }

  Future<void> _clearSlot(AppLocalizations l10n) async {
    if (_saving) return;
    setState(() => _saving = true);
    final repo = ref.read(mealsRepoProvider);
    final snack = ref.read(snackbarProvider);
    final date = widget.date;
    final slot = widget.slot;
    Navigator.of(context).pop();
    try {
      final res = await repo.clearSlot(date, slot);
      if (res.undo != null) {
        snack.show(l10n.mealsSlotCleared, undo: res.undo);
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
    final recipes = ref.watch(recipesProvider).value ?? const <RecipeView>[];
    final monday = Dates.addDays(
      widget.date,
      1 - Dates.weekdayIso(widget.date),
    );
    final weekSlots =
        ref.watch(weekSlotsProvider(monday)).value ?? const <MealSlot>[];

    MealSlot? currentSlot;
    for (final s in weekSlots) {
      if (s.date == widget.date && s.slot == widget.slot) {
        currentSlot = s;
        break;
      }
    }

    final q = _query.trim().toLowerCase();
    final filtered = [
      for (final r in recipes)
        if (q.isEmpty || r.name.toLowerCase().contains(q)) r,
    ]..sort((a, b) {
        final aMatch = a.mealTypes.contains(_mealTypeTag);
        final bMatch = b.mealTypes.contains(_mealTypeTag);
        if (aMatch != bMatch) return aMatch ? -1 : 1;
        return a.name.compareTo(b.name);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(
          title: l10n.mealsPickerTitle(
            l10n.mealsSlotTitle(widget.slot),
            Formatters.dayLabel(widget.date, today, l10n),
          ),
          lead: l10n.mealsPickerLead(l10n.mealsSlotLower(widget.slot)),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            NestChip(
              label: l10n.mealsOptEatingOut,
              selected: currentSlot?.kind == 'eatingOut',
              onTap: _saving ? null : () => _planKind(l10n, 'eatingOut'),
            ),
            NestChip(
              label: l10n.mealsOptLeftovers,
              selected: currentSlot?.kind == 'leftovers',
              onTap: _saving ? null : () => _planKind(l10n, 'leftovers'),
            ),
            NestChip(
              label: l10n.mealsOptNote,
              selected: _showNote,
              onTap: () => setState(() => _showNote = !_showNote),
            ),
          ],
        ),
        if (_showNote) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            maxLength: 60,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: l10n.mealsNoteHint,
              counterText: '',
            ),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _noteCtrl,
            builder: (context, value, _) {
              final trimmedNote = value.text.trim();
              return NestButton(
                label: l10n.mealsNoteSave,
                kind: NestButtonKind.primary,
                onPressed: (trimmedNote.isEmpty || _saving)
                    ? null
                    : () => _planKind(l10n, 'note', text: trimmedNote),
              );
            },
          ),
        ],
        if (recipes.length > 10) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: l10n.mealsSearchRecipes,
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
        ],
        const SizedBox(height: 12),
        for (var i = 0; i < filtered.length; i++) ...[
          if (i > 0) Container(height: 1, color: c.line),
          _PickerRecipeRow(
            recipe: filtered[i],
            selected:
                currentSlot?.kind == 'recipe' &&
                currentSlot?.recipeId == filtered[i].id,
            onTap: _saving ? null : () => _pickRecipe(l10n, filtered[i]),
          ),
        ],
        if (currentSlot != null && currentSlot.kind.isNotEmpty) ...[
          const SizedBox(height: 16),
          NestButton(
            label: l10n.mealsClearSlot(l10n.mealsSlotLower(widget.slot)),
            kind: NestButtonKind.ghost,
            size: NestButtonSize.block,
            onPressed: _saving ? null : () => _clearSlot(l10n),
          ),
        ],
      ],
    );
  }
}

class _PickerRecipeRow extends StatelessWidget {
  const _PickerRecipeRow({
    required this.recipe,
    required this.selected,
    required this.onTap,
  });

  final RecipeView recipe;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final tagsPart = recipe.allTags.isEmpty
        ? ''
        : ' · ${recipe.allTags.join(' · ')}';
    final sub = '${l10n.mealsMinutes(recipe.timeMin)}$tagsPart';

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              RecipeArt(
                r: recipe,
                size: 44,
                glyphSize: 18,
                radius: 12,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      recipe.name,
                      style: NestText.itemTitle16.copyWith(color: c.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: NestText.meta13.copyWith(color: c.ink3),
                    ),
                  ],
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 8),
                Icon(Icons.check_rounded, color: c.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
