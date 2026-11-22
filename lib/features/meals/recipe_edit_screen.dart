import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/recipe_validation.dart';
import 'package:nm_flat/core/domain/units.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/meals/recipe_edit_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class _IngRowCtrls {
  _IngRowCtrls({String name = '', String qty = ''})
    : nameCtrl = TextEditingController(text: name),
      qtyCtrl = TextEditingController(text: qty),
      nameFocus = FocusNode(),
      qtyFocus = FocusNode();

  final TextEditingController nameCtrl;
  final TextEditingController qtyCtrl;
  final FocusNode nameFocus;
  final FocusNode qtyFocus;

  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    nameFocus.dispose();
    qtyFocus.dispose();
  }
}

class _StepRowCtrls {
  _StepRowCtrls({String text = ''})
    : textCtrl = TextEditingController(text: text),
      focus = FocusNode();

  final TextEditingController textCtrl;
  final FocusNode focus;

  void dispose() {
    textCtrl.dispose();
    focus.dispose();
  }
}

class RecipeEditScreen extends ConsumerStatefulWidget {
  const RecipeEditScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<RecipeEditScreen> createState() => _RecipeEditScreenState();
}

class _RecipeEditScreenState extends ConsumerState<RecipeEditScreen> {
  final _nameCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _servesCtrl = TextEditingController(text: '4');
  final _tagsCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _timeFocus = FocusNode();
  final _servesFocus = FocusNode();

  final _ingRows = <_IngRowCtrls>[];
  final _stepRows = <_StepRowCtrls>[];
  bool _controllersLoaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.id == 'new') {
      _ingRows.add(_IngRowCtrls());
      _stepRows.add(_StepRowCtrls());
      _controllersLoaded = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _timeCtrl.dispose();
    _servesCtrl.dispose();
    _tagsCtrl.dispose();
    _nameFocus.dispose();
    _timeFocus.dispose();
    _servesFocus.dispose();
    for (final r in _ingRows) {
      r.dispose();
    }
    for (final s in _stepRows) {
      s.dispose();
    }
    super.dispose();
  }

  void _syncFromDraft(RecipeDraft d) {
    _nameCtrl.text = d.name;
    _timeCtrl.text = d.timeMin == null ? '' : '${d.timeMin}';
    _servesCtrl.text = d.serves == null ? '' : '${d.serves}';
    _tagsCtrl.text = d.tags.join(', ');

    for (final r in _ingRows) {
      r.dispose();
    }
    _ingRows
      ..clear()
      ..addAll([
        for (final i in d.ingredients)
          _IngRowCtrls(name: i.name, qty: i.qtyText),
      ]);

    for (final s in _stepRows) {
      s.dispose();
    }
    _stepRows
      ..clear()
      ..addAll([for (final step in d.steps) _StepRowCtrls(text: step)]);

    _controllersLoaded = true;
  }

  String? _errText(AppLocalizations l10n, String? key) => switch (key) {
    'recipeErrName' => l10n.recipeErrName,
    'recipeErrIngredients' => l10n.recipeErrIngredients,
    'recipeErrSteps' => l10n.recipeErrSteps,
    'recipeErrQty' => l10n.recipeErrQty,
    'recipeErrIngName' => l10n.recipeErrIngName,
    'recipeErrTime' => l10n.recipeErrTime,
    'recipeErrServes' => l10n.recipeErrServes,
    'recipeErrStepLong' => l10n.recipeErrStepLong,
    _ => null,
  };

  void _focusFirstError(Map<String, String> errors) {
    if (errors.containsKey('name')) {
      _nameFocus.requestFocus();
      return;
    }
    if (errors.containsKey('time')) {
      _timeFocus.requestFocus();
      return;
    }
    if (errors.containsKey('serves')) {
      _servesFocus.requestFocus();
      return;
    }
    for (var i = 0; i < _ingRows.length; i++) {
      if (errors.containsKey('ingName.$i')) {
        _ingRows[i].nameFocus.requestFocus();
        return;
      }
      if (errors.containsKey('ingQty.$i')) {
        _ingRows[i].qtyFocus.requestFocus();
        return;
      }
    }
    if (errors.containsKey('steps') && _stepRows.isNotEmpty) {
      _stepRows.first.focus.requestFocus();
      return;
    }
    for (var i = 0; i < _stepRows.length; i++) {
      if (errors.containsKey('step.$i')) {
        _stepRows[i].focus.requestFocus();
        return;
      }
    }
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (_saving) return;
    final ctrl = ref.read(recipeEditControllerProvider(widget.id).notifier);
    final errors = ctrl.validate();
    if (errors.isNotEmpty) {
      _focusFirstError(errors);
      return;
    }

    setState(() => _saving = true);
    try {
      final draft = ref.read(recipeEditControllerProvider(widget.id)).draft;
      final isNew = widget.id == 'new';
      final newId = await ref
          .read(recipesRepoProvider)
          .save(draft, id: isNew ? null : widget.id);
      if (!mounted) return;
      ctrl.markClean();
      ref.read(snackbarProvider).show(l10n.recipeSaved);
      if (isNew) {
        context.pushReplacement(Routes.recipe(newId));
      } else {
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showDiscardDialog(AppLocalizations l10n) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Text(l10n.recipeDiscardTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(false),
            child: Text(l10n.recipeKeepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(true),
            child: Text(l10n.recipeDiscard),
          ),
        ],
      ),
    );
    if (discard != true || !mounted) return;
    ref.read(recipeEditControllerProvider(widget.id).notifier).markClean();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final isNew = widget.id == 'new';

    if (!isNew) {
      final recipeAsync = ref.watch(recipeProvider(widget.id));
      final loadedRecipe = recipeAsync.value;
      if (loadedRecipe != null && !_controllersLoaded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _controllersLoaded) return;
          final ctrl = ref.read(
            recipeEditControllerProvider(widget.id).notifier,
          );
          ctrl.load(loadedRecipe);
          _syncFromDraft(
            ref.read(recipeEditControllerProvider(widget.id)).draft,
          );
          setState(() {});
        });
      }
    }

    final state = ref.watch(recipeEditControllerProvider(widget.id));
    final ctrl = ref.read(recipeEditControllerProvider(widget.id).notifier);
    final draft = state.draft;
    final errors = state.errors;

    while (_ingRows.length < draft.ingredients.length) {
      final idx = _ingRows.length;
      _ingRows.add(
        _IngRowCtrls(
          name: draft.ingredients[idx].name,
          qty: draft.ingredients[idx].qtyText,
        ),
      );
    }
    while (_stepRows.length < draft.steps.length) {
      final idx = _stepRows.length;
      _stepRows.add(_StepRowCtrls(text: draft.steps[idx]));
    }

    return PopScope(
      canPop: !state.dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showDiscardDialog(l10n);
      },
      child: Scaffold(
        appBar: NestTopBar.sub(
          title: isNew ? l10n.recipeFormNew : l10n.recipeFormEdit,
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              TextField(
                controller: _nameCtrl,
                focusNode: _nameFocus,
                maxLength: 60,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (v) => ctrl.update(draft.copyWith(name: v)),
                decoration: InputDecoration(
                  labelText: l10n.recipeFieldName,
                  counterText: '',
                  errorText: _errText(l10n, errors['name']),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _timeCtrl,
                      focusNode: _timeFocus,
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        final parsed = int.tryParse(v.trim());
                        ctrl.update(
                          draft.copyWith(
                            timeMin: parsed,
                            clearTimeMin: parsed == null,
                          ),
                        );
                      },
                      decoration: InputDecoration(
                        labelText: l10n.recipeFieldTime,
                        errorText: _errText(l10n, errors['time']),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _servesCtrl,
                      focusNode: _servesFocus,
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        final parsed = int.tryParse(v.trim());
                        ctrl.update(
                          draft.copyWith(
                            serves: parsed,
                            clearServes: parsed == null,
                          ),
                        );
                      },
                      decoration: InputDecoration(
                        labelText: l10n.recipeFieldServes,
                        errorText: _errText(l10n, errors['serves']),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tagsCtrl,
                onChanged: (v) {
                  final list = [
                    for (final part in v.split(','))
                      if (part.trim().isNotEmpty) part.trim(),
                  ];
                  ctrl.update(draft.copyWith(tags: list));
                },
                decoration: InputDecoration(
                  labelText: l10n.recipeFieldTags,
                  hintText: l10n.recipeTagsHint,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.recipeFieldMealType,
                style: NestText.small12.copyWith(color: c.ink2),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final (value, slotKey) in const [
                    ('Breakfast', 'breakfast'),
                    ('Lunch', 'lunch'),
                    ('Dinner', 'dinner'),
                  ])
                    NestChip(
                      label: l10n.mealsSlotTitle(slotKey),
                      selected: draft.mealTypes.contains(value),
                      onTap: () {
                        final next = List<String>.from(draft.mealTypes);
                        if (next.contains(value)) {
                          next.remove(value);
                        } else {
                          next.add(value);
                        }
                        ctrl.update(draft.copyWith(mealTypes: next));
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                l10n.recipeFieldIngredients,
                style: NestText.section13.copyWith(color: c.ink2),
              ),
              if (errors['ingredients'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  _errText(l10n, errors['ingredients']) ?? '',
                  style: NestText.meta13.copyWith(color: c.danger),
                ),
              ],
              const SizedBox(height: 8),
              for (var i = 0; i < draft.ingredients.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _buildIngredientEditor(context, l10n, ctrl, draft, errors, i),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: NestButton(
                  label: l10n.recipeAddIngredient,
                  kind: NestButtonKind.ghost,
                  onPressed: () {
                    _ingRows.add(_IngRowCtrls());
                    ctrl.addIngredient();
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.recipeFieldSteps,
                style: NestText.section13.copyWith(color: c.ink2),
              ),
              if (errors['steps'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  _errText(l10n, errors['steps']) ?? '',
                  style: NestText.meta13.copyWith(color: c.danger),
                ),
              ],
              const SizedBox(height: 8),
              for (var i = 0; i < draft.steps.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _buildStepEditor(context, l10n, ctrl, draft, errors, i),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: NestButton(
                  label: l10n.recipeAddStep,
                  kind: NestButtonKind.ghost,
                  onPressed: () {
                    _stepRows.add(_StepRowCtrls());
                    ctrl.addStep();
                  },
                ),
              ),
              const SizedBox(height: 24),
              NestButton(
                label: l10n.recipeSave,
                kind: NestButtonKind.primary,
                size: NestButtonSize.block,
                onPressed: _saving ? null : () => _save(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientEditor(
    BuildContext context,
    AppLocalizations l10n,
    RecipeEditController ctrl,
    RecipeDraft draft,
    Map<String, String> errors,
    int i,
  ) {
    final rowCtrls = _ingRows[i];
    final ing = draft.ingredients[i];
    final unitVal = allUnits.contains(ing.unit) ? ing.unit : '';

    return NestCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 180,
                child: TextField(
                  controller: rowCtrls.nameCtrl,
                  focusNode: rowCtrls.nameFocus,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (v) {
                    final list = [
                      for (final x in draft.ingredients) x.copyWith(),
                    ];
                    list[i].name = v;
                    ctrl.update(draft.copyWith(ingredients: list));
                  },
                  decoration: InputDecoration(
                    labelText: l10n.recipeIngName,
                    errorText: _errText(l10n, errors['ingName.$i']),
                  ),
                ),
              ),
              SizedBox(
                width: 72,
                child: TextField(
                  controller: rowCtrls.qtyCtrl,
                  focusNode: rowCtrls.qtyFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (v) {
                    final list = [
                      for (final x in draft.ingredients) x.copyWith(),
                    ];
                    list[i].qtyText = v;
                    ctrl.update(draft.copyWith(ingredients: list));
                  },
                  decoration: InputDecoration(
                    labelText: l10n.recipeIngQty,
                    errorText: _errText(l10n, errors['ingQty.$i']),
                  ),
                ),
              ),
              Semantics(
                label: l10n.recipeIngUnit,
                child: DropdownButton<String>(
                  value: unitVal,
                  items: [
                    for (final u in allUnits)
                      DropdownMenuItem(
                        value: u,
                        child: Text(u.isEmpty ? l10n.recipeUnitNone : u),
                      ),
                  ],
                  onChanged: (u) {
                    if (u == null) return;
                    final list = [
                      for (final x in draft.ingredients) x.copyWith(),
                    ];
                    list[i].unit = u;
                    ctrl.update(draft.copyWith(ingredients: list));
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward_rounded),
                tooltip: l10n.recipeMoveUp,
                onPressed: i == 0
                    ? null
                    : () {
                        final moved = _ingRows.removeAt(i);
                        _ingRows.insert(i - 1, moved);
                        ctrl.moveIngredient(i, i - 1);
                      },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward_rounded),
                tooltip: l10n.recipeMoveDown,
                onPressed: i == draft.ingredients.length - 1
                    ? null
                    : () {
                        final moved = _ingRows.removeAt(i);
                        _ingRows.insert(i + 1, moved);
                        ctrl.moveIngredient(i, i + 1);
                      },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: l10n.recipeRemoveRow,
                onPressed: () {
                  final removed = _ingRows.removeAt(i);
                  removed.dispose();
                  ctrl.removeIngredient(i);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepEditor(
    BuildContext context,
    AppLocalizations l10n,
    RecipeEditController ctrl,
    RecipeDraft draft,
    Map<String, String> errors,
    int i,
  ) {
    final rowCtrl = _stepRows[i];
    return NestCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: rowCtrl.textCtrl,
            focusNode: rowCtrl.focus,
            minLines: 2,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (v) {
              final list = [...draft.steps];
              list[i] = v;
              ctrl.update(draft.copyWith(steps: list));
            },
            decoration: InputDecoration(
              labelText: l10n.recipeStepLabel(i + 1),
              errorText: _errText(l10n, errors['step.$i']),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward_rounded),
                tooltip: l10n.recipeMoveUp,
                onPressed: i == 0
                    ? null
                    : () {
                        final moved = _stepRows.removeAt(i);
                        _stepRows.insert(i - 1, moved);
                        ctrl.moveStep(i, i - 1);
                      },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward_rounded),
                tooltip: l10n.recipeMoveDown,
                onPressed: i == draft.steps.length - 1
                    ? null
                    : () {
                        final moved = _stepRows.removeAt(i);
                        _stepRows.insert(i + 1, moved);
                        ctrl.moveStep(i, i + 1);
                      },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: l10n.recipeRemoveRow,
                onPressed: () {
                  final removed = _stepRows.removeAt(i);
                  removed.dispose();
                  ctrl.removeStep(i);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
