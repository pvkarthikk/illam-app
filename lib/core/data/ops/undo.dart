class UndoEntry {
  const UndoEntry({
    required this.tbl,
    required this.id,
    required this.field,
    required this.kind,
    this.value,
    this.delta,
    this.guarded = false,
    this.expected,
  });

  final String tbl;
  final String id;
  final String field;
  final String kind;
  final Object? value;
  final int? delta;
  final bool guarded;
  final Object? expected;
}

sealed class UndoOutcome {
  const UndoOutcome();
}

class UndoDone extends UndoOutcome {
  const UndoDone();
}

class UndoConflict extends UndoOutcome {
  const UndoConflict({required this.byMe, this.name});
  final bool byMe;
  final String? name;
}

class UndoToken {
  UndoToken({
    required this.label,
    required this.homeId,
    required this.entries,
    required this._runner,
  });

  final String label;
  final String homeId;
  final List<UndoEntry> entries;
  final Future<UndoOutcome> Function(UndoToken) _runner;
  bool used = false;

  Future<UndoOutcome> run() => _runner(this);
}

class ChangeResult {
  const ChangeResult(this.changeId, this.undo);
  final String changeId;
  final UndoToken? undo;
}
