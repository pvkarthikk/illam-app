import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/time/hlc.dart';
import 'package:nm_flat/features/debug/data_lab_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class DataLabScreen extends ConsumerStatefulWidget {
  const DataLabScreen({super.key});

  @override
  ConsumerState<DataLabScreen> createState() => _DataLabScreenState();
}

class _DataLabScreenState extends ConsumerState<DataLabScreen> {
  final _addCtrl = TextEditingController();

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitAdd() async {
    final text = _addCtrl.text.trim();
    if (text.isEmpty) return;
    _addCtrl.clear();
    await ref.read(dataLabControllerProvider.notifier).addNote(text);
  }

  Future<void> _openEditSheet(BuildContext context, DevNote note) async {
    final l10n = AppLocalizations.of(context);
    final updated = await showNestSheet<String>(
      context,
      (_) => _EditNoteSheet(
        title: l10n.labEdit,
        hint: l10n.labNoteHint,
        saveLabel: l10n.commonSave,
        initialTitle: note.title ?? '',
      ),
    );
    if (updated == null) return;
    final trimmed = updated.trim();
    if (trimmed.isEmpty) return;
    await ref
        .read(dataLabControllerProvider.notifier)
        .rename(note.id, trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final ctrl = ref.read(dataLabControllerProvider.notifier);
    final notesAsync = ref.watch(devNotesProvider);
    final recent = ref.watch(dataLabControllerProvider);
    final opStatsAsync = ref.watch(opStatsProvider);

    return Scaffold(
      appBar: NestTopBar.sub(title: l10n.debugDataLab),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NestCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _addCtrl,
                  decoration: InputDecoration(hintText: l10n.labNoteHint),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submitAdd(),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: NestButton(
                    label: l10n.labAddNote,
                    onPressed: _submitAdd,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...notesAsync.when(
            loading: () => const [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (err, _) => [
              NestCard(
                padding: const EdgeInsets.all(14),
                child: Text(
                  '$err',
                  style: NestText.body15.copyWith(color: c.danger),
                ),
              ),
            ],
            data: (notes) => [
              for (final note in notes) ...[
                NestCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title ?? '',
                        style: NestText.itemTitle16.copyWith(color: c.ink),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.labTaps(note.taps),
                        style: NestText.meta13.copyWith(color: c.ink3),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          IconButton(
                            tooltip: l10n.labPin,
                            onPressed: () => ctrl.togglePin(note),
                            icon: Icon(
                              note.pinned
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined,
                              color: note.pinned ? c.primary : c.ink2,
                            ),
                          ),
                          NestButton(
                            label: '+1',
                            size: NestButtonSize.sm,
                            kind: NestButtonKind.tonal,
                            onPressed: () => ctrl.tap(note.id),
                          ),
                          IconButton(
                            tooltip: l10n.labEdit,
                            onPressed: () => _openEditSheet(context, note),
                            icon: Icon(Icons.edit_outlined, color: c.ink2),
                          ),
                          IconButton(
                            tooltip: l10n.labDelete,
                            onPressed: () => ctrl.delete(note.id),
                            icon: Icon(Icons.delete_outline, color: c.danger),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
          const SizedBox(height: 16),
          SectionHeader(title: l10n.labRecent),
          const SizedBox(height: 6),
          if (recent.isNotEmpty)
            NestCard(
              child: Column(
                children: [
                  for (var i = 0; i < recent.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: c.line),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              recent[i].label,
                              style: NestText.body15.copyWith(color: c.ink),
                            ),
                          ),
                          const SizedBox(width: 8),
                          NestButton(
                            label: l10n.commonUndo,
                            size: NestButtonSize.sm,
                            kind: NestButtonKind.ghost,
                            onPressed: recent[i].used
                                ? null
                                : () => ctrl.undo(recent[i]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 20),
          SectionHeader(title: l10n.labOpLog),
          const SizedBox(height: 6),
          opStatsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => NestCard(
              padding: const EdgeInsets.all(14),
              child: Text(
                '$err',
                style: NestText.body15.copyWith(color: c.danger),
              ),
            ),
            data: (stats) => NestCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.labOpsTotal(stats.total),
                    style: NestText.itemTitle16.copyWith(color: c.ink),
                  ),
                  for (final entry in stats.perTable.entries) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${entry.key}: ${entry.value}',
                      style: NestText.meta13.copyWith(color: c.ink2),
                    ),
                  ],
                  if (stats.last50.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Divider(height: 1, color: c.line),
                    const SizedBox(height: 10),
                    for (final o in stats.last50) ...[
                      Text(
                        '${o.opId} · ${o.field} = ${o.valueJson ?? '+${o.delta}'} · ${Hlc.parse(o.hlc).wall}',
                        style: NestText.small12.copyWith(color: c.ink3),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditNoteSheet extends StatefulWidget {
  const _EditNoteSheet({
    required this.title,
    required this.hint,
    required this.saveLabel,
    required this.initialTitle,
  });

  final String title;
  final String hint;
  final String saveLabel;
  final String initialTitle;

  @override
  State<_EditNoteSheet> createState() => _EditNoteSheetState();
}

class _EditNoteSheetState extends State<_EditNoteSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(title: widget.title),
        TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: widget.hint),
          textInputAction: TextInputAction.done,
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        NestSheetActions(
          children: [
            NestButton(
              label: widget.saveLabel,
              size: NestButtonSize.block,
              onPressed: () => Navigator.of(context).pop(_ctrl.text),
            ),
          ],
        ),
      ],
    );
  }
}
