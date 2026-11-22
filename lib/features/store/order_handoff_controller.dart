import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/domain/order_handoff.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/store/store_launcher.dart';

class OrderGroupView {
  const OrderGroupView({
    required this.name,
    required this.totalMilli,
    required this.unit,
    required this.items,
  });

  final String name;
  final int totalMilli;
  final String unit;
  final List<ItemRow> items;
}

class OrderHandoffController extends Notifier<void> {
  @override
  void build() {}

  Future<StoreOpened> start(
    String list,
    String channel,
    List<OrderGroupView> groups,
  ) async {
    final text = buildOrderText([
      for (final g in groups)
        (name: g.name, qtyMilli: g.totalMilli, unit: g.unit),
    ]);
    await Clipboard.setData(ClipboardData(text: text));

    final handoff = PendingHandoff(
      channel: channel,
      list: list,
      startedAtMs: ref.read(clockProvider).nowMs,
      lines: [
        for (final g in groups)
          for (final item in g.items)
            HandoffLine(
              itemId: item.id,
              name: item.name,
              qtyMilli: item.qtyMilli,
              unit: item.unit,
            ),
      ],
    );
    await ref
        .read(prefsProvider)
        .setPendingHandoffJson(jsonEncode(handoff.toJson()));

    final opened = await ref.read(storeLauncherProvider).open(channel);
    if (opened == StoreOpened.none) {
      await clear();
    }
    return opened;
  }

  PendingHandoff? readPending() {
    final raw = ref.read(prefsProvider).pendingHandoffJson;
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return PendingHandoff.fromJson(Map<String, Object?>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() => ref.read(prefsProvider).setPendingHandoffJson(null);
}

final orderHandoffControllerProvider =
    NotifierProvider<OrderHandoffController, void>(
      OrderHandoffController.new,
    );
