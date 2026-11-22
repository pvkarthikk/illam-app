import 'package:nm_flat/core/domain/units.dart';

class HandoffLine {
  const HandoffLine({
    required this.itemId,
    required this.name,
    required this.qtyMilli,
    required this.unit,
  });

  factory HandoffLine.fromJson(Map<String, Object?> j) => HandoffLine(
    itemId: j['itemId'] as String? ?? '',
    name: j['name'] as String? ?? '',
    qtyMilli: (j['qtyMilli'] as num?)?.toInt() ?? 0,
    unit: j['unit'] as String? ?? '',
  );

  final String itemId;
  final String name;
  final int qtyMilli;
  final String unit;

  Map<String, Object?> toJson() => {
    'itemId': itemId,
    'name': name,
    'qtyMilli': qtyMilli,
    'unit': unit,
  };
}

class PendingHandoff {
  const PendingHandoff({
    required this.channel,
    required this.list,
    required this.startedAtMs,
    required this.lines,
  });

  factory PendingHandoff.fromJson(Map<String, Object?> j) {
    final rawLines = j['lines'] as List? ?? const <Object?>[];
    return PendingHandoff(
      channel: j['channel'] as String? ?? '',
      list: j['list'] as String? ?? '',
      startedAtMs: (j['startedAt'] as num?)?.toInt() ?? 0,
      lines: [
        for (final el in rawLines)
          HandoffLine.fromJson(Map<String, Object?>.from(el as Map)),
      ],
    );
  }

  final String channel;
  final String list;
  final int startedAtMs;
  final List<HandoffLine> lines;

  Map<String, Object?> toJson() => {
    'channel': channel,
    'list': list,
    'startedAt': startedAtMs,
    'lines': [for (final line in lines) line.toJson()],
  };
}

class CurrentItem {
  const CurrentItem({
    required this.qtyMilli,
    required this.unit,
    required this.done,
    required this.deleted,
  });

  final int qtyMilli;
  final String unit;
  final bool done;
  final bool deleted;
}

enum HandoffKind { markDone, keepRemainder, unitChanged }

class HandoffRow {
  const HandoffRow(
    this.line,
    this.kind, {
    this.currentMilli = 0,
    this.currentUnit = '',
  });

  final HandoffLine line;
  final HandoffKind kind;
  final int currentMilli;
  final String currentUnit;
}

const handoffMaxAge = Duration(hours: 2);

bool isHandoffFresh(PendingHandoff p, int nowMs) =>
    nowMs - p.startedAtMs <= handoffMaxAge.inMilliseconds;

String buildOrderText(List<({String name, int qtyMilli, String unit})> rows) => [
  for (final r in rows) '${r.name} ${formatQty(r.qtyMilli, r.unit)}',
].join('\n');

List<HandoffRow> reviewHandoff(
  PendingHandoff p,
  Map<String, CurrentItem> current,
) {
  final rows = <HandoffRow>[];
  for (final line in p.lines) {
    final cur = current[line.itemId];
    if (cur == null || cur.deleted || cur.done) continue;
    final HandoffKind kind;
    if (cur.unit != line.unit) {
      kind = HandoffKind.unitChanged;
    } else if (cur.qtyMilli > line.qtyMilli) {
      kind = HandoffKind.keepRemainder;
    } else {
      kind = HandoffKind.markDone;
    }
    rows.add(
      HandoffRow(
        line,
        kind,
        currentMilli: cur.qtyMilli,
        currentUnit: cur.unit,
      ),
    );
  }
  return rows;
}
