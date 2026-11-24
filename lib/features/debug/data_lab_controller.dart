import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/undo.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

const labHomeId = 'devlab';

final devNotesProvider = StreamProvider<List<DevNote>>((ref) {
  final db = ref.watch(dbProvider);
  final home = ref.watch(currentHomeIdProvider).value ?? labHomeId;
  return (db.select(db.devNotes)
        ..where((n) => n.homeId.equals(home) & n.deleted.equals(false))
        ..orderBy([
          (n) => OrderingTerm(expression: n.pinned, mode: OrderingMode.desc),
          (n) => OrderingTerm(expression: n.createdAt, mode: OrderingMode.desc),
        ]))
      .watch();
});

final opStatsProvider =
    StreamProvider.autoDispose<
      ({int total, Map<String, int> perTable, List<OpRow> last50})
    >((ref) {
      final db = ref.watch(dbProvider);
      return db
          .customSelect(
            'SELECT tbl, COUNT(*) AS cnt FROM ops GROUP BY tbl',
            readsFrom: {db.ops},
          )
          .watch()
          .asyncMap((countRows) async {
            final perTable = <String, int>{};
            var total = 0;
            for (final row in countRows) {
              final tbl = row.read<String>('tbl');
              final cnt = row.read<int>('cnt');
              perTable[tbl] = cnt;
              total += cnt;
            }
            final last50 =
                await (db.select(db.ops)
                      ..orderBy([(o) => OrderingTerm.desc(o.hlc)])
                      ..limit(50))
                    .get();
            return (total: total, perTable: perTable, last50: last50);
          });
    });

final dataLabControllerProvider =
    NotifierProvider<DataLabController, List<UndoToken>>(DataLabController.new);

class DataLabController extends Notifier<List<UndoToken>> {
  @override
  List<UndoToken> build() => const [];

  String get _home => ref.read(prefsProvider).currentHomeId ?? labHomeId;

  AppLocalizations get _l10n => lookupAppLocalizations(const Locale('en'));

  Future<void> _write(
    String label,
    String snack,
    void Function(ChangeBuilder c) build,
  ) async {
    final r = await ref
        .read(changesProvider)
        .write(label, build, homeId: _home);
    final undoToken = r.undo;
    ref.read(snackbarProvider).show(snack, undo: undoToken);
    if (undoToken != null) {
      state = [undoToken, ...state].take(5).toList();
    }
  }

  Future<void> addNote(String title) => _write(
    '${_l10n.labNoteAdded}: $title',
    _l10n.labNoteAdded,
    (c) => c.create('dev_notes', {'title': title}),
  );

  Future<void> rename(String id, String title) => _write(
    '${_l10n.labNoteRenamed}: $title',
    _l10n.labNoteRenamed,
    (c) => c.set('dev_notes', id, 'title', title),
  );

  Future<void> togglePin(DevNote note) {
    final nextPinned = !note.pinned;
    final label = nextPinned ? _l10n.labPinned : _l10n.labUnpinned;
    return _write(
      '$label: ${note.title ?? ''}',
      label,
      (c) => c.set('dev_notes', note.id, 'pinned', nextPinned),
    );
  }

  Future<void> tap(String id) async {
    await ref
        .read(changesProvider)
        .write(
          'Tap note',
          (c) => c.inc('dev_notes', id, 'taps', 1),
          homeId: _home,
        );
  }

  Future<void> delete(String id) => _write(
    _l10n.labNoteDeleted,
    _l10n.labNoteDeleted,
    (c) => c.delete('dev_notes', id),
  );

  Future<void> undo(UndoToken token) async {
    final r = await token.run();
    final text = switch (r) {
      UndoConflict(byMe: true) => _l10n.undoConflictYou,
      UndoConflict(name: final String n) => _l10n.undoConflict(n),
      UndoConflict() => _l10n.undoConflictSomeone,
      UndoDone() => null,
    };
    if (text != null) {
      ref.read(snackbarProvider).show(text);
    }
    state = [...state];
  }
}
