import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/domain/order_handoff.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/store/back_from_store_sheet.dart';
import 'package:nm_flat/features/store/order_handoff_controller.dart';

class HandoffWatcher extends ConsumerStatefulWidget {
  const HandoffWatcher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<HandoffWatcher> createState() => _HandoffWatcherState();
}

class _HandoffWatcherState extends ConsumerState<HandoffWatcher> {
  late final AppLifecycleListener _listener;
  bool _wasAway = false;
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onHide: () => _wasAway = true,
      onResume: () {
        if (!_wasAway) return;
        _wasAway = false;
        _check();
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    if (_showing || !mounted) return;
    final ctrl = ref.read(orderHandoffControllerProvider.notifier);
    final p = ctrl.readPending();
    if (p == null) return;
    final nowMs = ref.read(clockProvider).nowMs;
    if (!isHandoffFresh(p, nowMs)) {
      await ctrl.clear();
      return;
    }
    _showing = true;
    try {
      await showBackFromStoreSheet(context, p);
    } finally {
      _showing = false;
    }
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
