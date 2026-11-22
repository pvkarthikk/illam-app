import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/database.dart';

enum ColType { text, int, bool, real }

class CollectionSpec {
  CollectionSpec(this.table, this.columns);
  final TableInfo table;
  final Map<String, ColType> columns; // writable columns only ('deleted' included)
  static const meta = {
    'id',
    'home_id',
    'created_at',
    'created_by',
    'updated_at',
    'updated_by',
  };
}

class CollectionRegistry {
  CollectionRegistry._(this._specs);
  final Map<String, CollectionSpec> _specs;

  static CollectionRegistry build(NestDatabase db) => CollectionRegistry._({
    for (final t in <TableInfo>[
      db.devNotes,
      // P03: db.homes, db.members   P04: db.staff, db.visits, db.leaves   … one line per synced table
    ])
      t.actualTableName: _specOf(t),
  });

  static CollectionSpec _specOf(TableInfo t) => CollectionSpec(t, {
    for (final c in t.$columns)
      if (!CollectionSpec.meta.contains(c.name))
        c.name: switch (c.type) {
          DriftSqlType.bool => ColType.bool,
          DriftSqlType.int => ColType.int,
          DriftSqlType.double => ColType.real,
          _ => ColType.text,
        },
  });

  bool has(String tbl) => _specs.containsKey(tbl);

  CollectionSpec spec(String tbl) =>
      _specs[tbl] ?? (throw ArgumentError('Unknown table $tbl'));

  /// SQL raw value → Dart value (bool columns come back as 0/1).
  Object? fromSql(String tbl, String field, Object? raw) =>
      spec(tbl).columns[field] == ColType.bool && raw is int ? raw == 1 : raw;

  void check(String tbl, String field, String kind, Object? value) {
    final s = spec(tbl);
    final colType = s.columns[field];
    if (colType == null) {
      throw ArgumentError('Unknown field $tbl.$field');
    }
    if (kind == 'inc') {
      if (colType != ColType.int || value is! int) {
        throw ArgumentError(
          'inc requires int column and int delta on $tbl.$field',
        );
      }
      return;
    }
    if (kind != 'set') {
      throw ArgumentError('Unknown op kind $kind');
    }
    if (value == null) return;
    final ok = switch (colType) {
      ColType.text => value is String,
      ColType.int => value is int,
      ColType.bool => value is bool,
      ColType.real => value is num,
    };
    if (!ok) {
      throw ArgumentError(
        'Invalid value type ${value.runtimeType} for $tbl.$field ($colType)',
      );
    }
  }
}
