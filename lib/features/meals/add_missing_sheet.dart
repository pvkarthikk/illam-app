import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/fractions.dart';
import 'package:nm_flat/core/domain/ingredients.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

bool _addingMissing = false;

Future<void> showAddMissingSheet(
  BuildContext context,
  WidgetRef ref,
  List<GroceryLine> lines,
) {
  if (_addingMissing) return Future<void>.value();
  return showNestSheet<void>(context, (_) => _AddMissingSheet(lines: lines));
}

class _AddMissingSheet extends ConsumerStatefulWidget {
  const _AddMissingSheet({required this.lines});

  final List<GroceryLine> lines;

  @override
  ConsumerState<_AddMissingSheet> createState() => _AddMissingSheetState();
}

class _AddMissingSheetState extends ConsumerState<_AddMissingSheet> {
  late final Set<int> _ticked;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ticked = {for (var i = 0; i < widget.lines.length; i++) i};
  }

  String _lineLabel(AppLocalizations l10n, GroceryLine line) {
    final rawF = formatFraction(line.qty, line.unit);
    final f = rawF == 'a pinch' ? l10n.recipeAPinch : rawF;
    final qtyPart = line.unit.isEmpty ? ' ×$f' : ' $f ${line.unit}';
    final note = line.note;
    final notePart = (note != null && note.isNotEmpty) ? ' ($note)' : '';
    return '${line.name}$qtyPart$notePart';
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (_saving || _ticked.isEmpty) return;
    setState(() => _saving = true);
    final ticked = <GroceryLine>[];
    final unticked = <GroceryLine>[];
    for (var i = 0; i < widget.lines.length; i++) {
      if (_ticked.contains(i)) {
        ticked.add(widget.lines[i]);
      } else {
        unticked.add(widget.lines[i]);
      }
    }
    final repo = ref.read(mealsRepoProvider);
    final snack = ref.read(snackbarProvider);
    _addingMissing = true;
    try {
      Navigator.of(context).pop();
      final res = await repo.addMissing(ticked: ticked, unticked: unticked);
      if (res.undo != null) {
        snack.show(l10n.mealsAddedToGrocery(ticked.length), undo: res.undo);
      }
    } on Object {
      // Ignore write errors after closing the sheet.
    } finally {
      _addingMissing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final count = _ticked.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(
          title: l10n.mealsReviewTitle,
          lead: l10n.mealsReviewLead,
        ),
        for (var i = 0; i < widget.lines.length; i++) ...[
          Builder(
            builder: (ctx) {
              final label = _lineLabel(l10n, widget.lines[i]);
              final isChecked = _ticked.contains(i);
              void toggle() => setState(() {
                if (isChecked) {
                  _ticked.remove(i);
                } else {
                  _ticked.add(i);
                }
              });
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: toggle,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Row(
                    children: [
                      NestCheckbox(
                        value: isChecked,
                        semanticLabel: label,
                        onChanged: (_) => toggle(),
                      ),
                      Expanded(
                        child: Text(
                          label,
                          style: NestText.body15.copyWith(color: c.ink),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.mealsReviewAdd(count),
              kind: NestButtonKind.primary,
              size: NestButtonSize.block,
              onPressed: (count == 0 || _saving) ? null : () => _submit(l10n),
            ),
          ],
        ),
      ],
    );
  }
}
