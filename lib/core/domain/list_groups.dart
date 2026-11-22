import 'package:nm_flat/core/domain/units.dart';

class ItemSnap {
  const ItemSnap({
    required this.id,
    required this.nameKey,
    required this.unit,
    required this.qtyMilli,
    required this.createdAt,
  });

  final String id;
  final String nameKey;
  final String unit;
  final int qtyMilli;
  final int createdAt;
}

class ItemGroup {
  const ItemGroup({
    required this.survivor,
    required this.ids,
    required this.totalMilli,
    required this.checkQty,
  });

  final ItemSnap survivor;
  final List<String> ids;
  final int totalMilli;
  final bool checkQty;
}

List<ItemGroup> groupOpenItems(List<ItemSnap> open) {
  final buckets = <(String, String), List<ItemSnap>>{};
  for (final item in open) {
    (buckets[(item.nameKey, compatKey(item.unit))] ??= []).add(item);
  }

  final groups = <ItemGroup>[];
  for (final members in buckets.values) {
    members.sort(_compareSnap);
    final survivor = members.first;
    var total = 0;
    for (final m in members) {
      total += convertMilli(m.qtyMilli, m.unit, survivor.unit) ?? 0;
    }
    groups.add(
      ItemGroup(
        survivor: survivor,
        ids: [for (final m in members) m.id],
        totalMilli: total,
        checkQty: total < stepMilli(survivor.unit),
      ),
    );
  }

  groups.sort((a, b) => _compareSnap(a.survivor, b.survivor));
  return groups;
}

int _compareSnap(ItemSnap a, ItemSnap b) {
  final c = a.createdAt.compareTo(b.createdAt);
  return c != 0 ? c : a.id.compareTo(b.id);
}

sealed class AddDecision {
  const AddDecision();
}

class AddNew extends AddDecision {
  const AddNew();
}

class MergeInto extends AddDecision {
  const MergeInto(this.group, this.incMilli);

  final ItemGroup group;
  final int incMilli;
}

class Incompatible extends AddDecision {
  const Incompatible(this.group);

  final ItemGroup group;
}

AddDecision decideAdd(
  List<ItemSnap> openInList,
  String nameKey,
  String unit,
  int qtyMilli,
) {
  final matching = [
    for (final g in groupOpenItems(openInList))
      if (g.survivor.nameKey == nameKey) g,
  ];
  if (matching.isEmpty) return const AddNew();

  final targetCompat = compatKey(unit);
  for (final g in matching) {
    if (compatKey(g.survivor.unit) == targetCompat) {
      final inc = convertMilli(qtyMilli, unit, g.survivor.unit) ?? qtyMilli;
      return MergeInto(g, inc);
    }
  }
  return Incompatible(matching.first);
}
