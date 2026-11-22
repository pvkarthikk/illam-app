import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workmanager/workmanager.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/router.dart';
import 'package:nm_flat/core/notify/background_tasks.dart';
import 'package:nm_flat/core/notify/notifications.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/sync_engine.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class NestApp extends ConsumerStatefulWidget {
  const NestApp({super.key});

  @override
  ConsumerState<NestApp> createState() => _NestAppState();
}

class _NestAppState extends ConsumerState<NestApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _schedulePlan);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _schedulePlan();
    });
  }

  void _schedulePlan() => unawaited(_runPlan());

  Future<void> _runPlan() async {
    try {
      await planAndEnqueue(ref.read);
    } catch (e) {
      debugPrint('planAndEnqueue skipped: $e');
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(startupProvider);
    final router = ref.watch(routerProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        NotificationRouter.instance.attach(router, ref.read);
      }
    });

    return MaterialApp.router(
      onGenerateTitle: (c) => AppLocalizations.of(c).appName,
      theme: NestTheme.light(),
      darkTheme: NestTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      routerConfig: router,
      scaffoldMessengerKey: ref.watch(snackbarProvider).messengerKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        return SyncLifecycle(
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value:
                (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
                    .copyWith(
                      statusBarColor: Colors.transparent,
                      systemNavigationBarColor: Colors.transparent,
                    ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

/// Manages foreground LAN sync, background WorkManager catch-up, and reconnect triggers.
class SyncLifecycle extends ConsumerStatefulWidget {
  const SyncLifecycle({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SyncLifecycle> createState() => _SyncLifecycleState();
}

class _SyncLifecycleState extends ConsumerState<SyncLifecycle> {
  late final AppLifecycleListener _lifecycle;
  StreamSubscription<void>? _changedSub;
  StreamSubscription<void>? _syncedSub;
  Timer? _stopTimer;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume, onPause: _onPause);
    final engine = ref.read(syncEngineProvider);
    unawaited(engine.startForeground());
    _syncedSub = engine.synced.listen((_) => _dirty = false);
    _changedSub = ref.read(changesProvider).changed.listen((_) {
      _dirty = true;
      ref.read(syncEngineProvider).onLocalChange();
    });
  }

  void _onResume() {
    _stopTimer?.cancel();
    _stopTimer = null;
    unawaited(ref.read(syncEngineProvider).startForeground());
  }

  void _onPause() {
    if (_dirty) {
      try {
        unawaited(
          Workmanager().registerOneOffTask(
            'nm.sync.once',
            'nm.sync',
            constraints: Constraints(networkType: NetworkType.connected),
            existingWorkPolicy: ExistingWorkPolicy.replace,
          ),
        );
      } on Object {
        // WorkManager plugin absent in widget tests.
      }
    }
    _stopTimer?.cancel();
    _stopTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        unawaited(ref.read(syncEngineProvider).stopForeground());
      }
    });
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    _changedSub?.cancel();
    _syncedSub?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SyncEngine>(syncEngineProvider, (prev, next) {
      _syncedSub?.cancel();
      _syncedSub = next.synced.listen((_) => _dirty = false);
      unawaited(next.startForeground());
    });
    ref.listen<AsyncValue<List<ConnectivityResult>>>(connectivityProvider, (
      prev,
      next,
    ) {
      if (prev != null && prev.hasValue && next.hasValue) {
        unawaited(ref.read(syncEngineProvider).syncNow());
      }
    });
    return widget.child;
  }
}
