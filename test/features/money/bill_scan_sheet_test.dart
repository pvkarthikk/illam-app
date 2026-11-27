import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/receipt/receipt_ocr_bridge.dart';
import 'package:nm_flat/core/sms/sms_import_config.dart';
import 'package:nm_flat/core/sms/sms_platform_bridge.dart';
import 'package:nm_flat/core/sync/validator.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';
import 'package:nm_flat/features/money/money_screen.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class _FakeReceiptOcrBridge implements ReceiptOcrBridge {
  _FakeReceiptOcrBridge({
    required this.onRecognize,
  });

  static const _pickedPath = '/cache/receipt_scans/scan_1.jpg';
  final ReceiptOcrResult Function(String path, int rotationDegrees) onRecognize;

  final List<ReceiptImageSource> pickCalls = [];
  final List<(String path, int rotationDegrees)> recognizeCalls = [];
  final List<String> deletedPaths = [];

  @override
  Future<bool> isSupported() async => true;

  @override
  Future<String?> pickOrCaptureImage(ReceiptImageSource source) async {
    pickCalls.add(source);
    return _pickedPath;
  }

  @override
  Future<ReceiptOcrResult> recognizeImage(
    String path, {
    int rotationDegrees = 0,
  }) async {
    recognizeCalls.add((path, rotationDegrees));
    return onRecognize(path, rotationDegrees);
  }

  @override
  Future<void> deleteTempImage(String path) async {
    deletedPaths.add(path);
  }
}

Future<({
  NestDatabase db,
  DevicePrefs prefs,
  MemorySecureStore secure,
  ChangeWriter changes,
  SmsImportStore smsStore,
  FixedClock clock,
})> _seedEnv(WidgetTester tester) async {
  tester.view.physicalSize = const Size(412, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final db = NestDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final prefs = await DevicePrefs.inMemory();
  await prefs.setCurrentHomeId('NM-SCAN1');
  await prefs.setMemberId('mem-1');
  final clock = FixedClock(DateTime(2026, 11, 26, 11, 0));
  final changes = ChangeWriter(
    db,
    CollectionRegistry.build(db),
    HlcClock(clock, prefs),
    prefs,
    validator: const Validator(),
    clock: clock,
  );
  await changes.write('Seed home', (c) {
    c.create('homes', {'name': 'Home'}, id: 'NM-SCAN1');
    c.create('members', {
      'full_name': 'Karthik',
      'first_name': 'Karthik',
      'role': 'admin',
      'status': 'active',
      'color': '#23503A',
    }, id: 'mem-1');
  }, homeId: 'NM-SCAN1');

  final secure = MemorySecureStore();
  final smsStore = SmsImportStore(secure);
  addTearDown(smsStore.dispose);
  return (
    db: db,
    prefs: prefs,
    secure: secure,
    changes: changes,
    smsStore: smsStore,
    clock: clock,
  );
}

Future<void> _pumpMoneyApp(
  WidgetTester tester, {
  required ({
    NestDatabase db,
    DevicePrefs prefs,
    MemorySecureStore secure,
    ChangeWriter changes,
    SmsImportStore smsStore,
    FixedClock clock,
  }) env,
  required ReceiptOcrBridge bridge,
}) async {
  final container = ProviderContainer(
    overrides: [
      dbProvider.overrideWithValue(env.db),
      prefsProvider.overrideWithValue(env.prefs),
      secureStoreProvider.overrideWithValue(env.secure),
      clockProvider.overrideWithValue(env.clock),
      changesProvider.overrideWithValue(env.changes),
      smsImportStoreProvider.overrideWithValue(env.smsStore),
      smsPlatformBridgeProvider.overrideWithValue(
        const UnsupportedSmsPlatformBridge(),
      ),
      receiptOcrBridgeProvider.overrideWithValue(bridge),
    ],
  );
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: Routes.money,
    routes: [
      GoRoute(
        path: Routes.money,
        builder: (_, _) => const MoneyScreen(),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: NestTheme.light(),
        scaffoldMessengerKey: container.read(snackbarProvider).messengerKey,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  testWidgets(
    'Scan bill captures photo, allows edit/uncheck/add item, saves atomically and undoes all',
    (tester) async {
      final env = await _seedEnv(tester);
      final bridge = _FakeReceiptOcrBridge(
        onRecognize: (_, _) => const ReceiptOcrResult(
          confidence: 88,
          text: '''
GREEN GROCERS
Date: 26/11/2026
Amul Milk        60.00
Fresh Tomatoes   40.00
Carry Bag        10.00
Grand Total     110.00
''',
        ),
      );

      await _pumpMoneyApp(tester, env: env, bridge: bridge);

      await tester.tap(find.text('Scan bill'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Take photo'));
      await tester.pumpAndSettle();

      expect(bridge.pickCalls, [ReceiptImageSource.camera]);
      expect(find.text('Review scanned bill'), findsOneWidget);
      expect(find.text('Save 3 expenses'), findsOneWidget);

      // Uncheck "Carry Bag" so only 2 items remain active.
      final carryCheckbox = find.byWidgetPredicate(
        (w) => w is NestCheckbox && w.semanticLabel == 'Carry Bag',
      );
      await tester.ensureVisible(carryCheckbox);
      await tester.tap(carryCheckbox);
      await tester.pumpAndSettle();
      expect(find.text('Save 2 expenses'), findsOneWidget);

      // Add one extra manual item.
      await tester.ensureVisible(find.text('+ Add item'));
      await tester.tap(find.text('+ Add item'));
      await tester.pumpAndSettle();

      final nameFields = find.widgetWithText(TextField, 'Item name');
      await tester.enterText(nameFields.last, 'Coriander');
      final amountFields = find.widgetWithText(TextField, 'Amount');
      await tester.enterText(amountFields.last, '25');
      await tester.pumpAndSettle();

      expect(find.text('Save 3 expenses'), findsOneWidget);

      await tester.ensureVisible(find.text('Save 3 expenses'));
      await tester.tap(find.text('Save 3 expenses'));
      await tester.pumpAndSettle();

      final rows = await (env.db.select(
        env.db.expenses,
      )..where((e) => e.deleted.equals(false))).get();
      expect(rows.length, 3);
      expect(rows.every((e) => e.source == 'manual'), isTrue);
      expect(rows.fold<int>(0, (sum, e) => sum + e.amountPaise), 12500);
      expect(bridge.deletedPaths, ['/cache/receipt_scans/scan_1.jpg']);

      // Atomic Undo reverts all 3 scanned items at once.
      expect(find.text('Undo'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      final afterUndo = await (env.db.select(
        env.db.expenses,
      )..where((e) => e.deleted.equals(false))).get();
      expect(afterUndo, isEmpty);
    },
  );

  testWidgets(
    'Rotate 90 & rescan re-runs OCR with incremented rotation and cleans cache on dismiss',
    (tester) async {
      final env = await _seedEnv(tester);
      final bridge = _FakeReceiptOcrBridge(
        onRecognize: (_, rot) {
          if (rot == 0) {
            return const ReceiptOcrResult(text: '', confidence: 0);
          }
          return const ReceiptOcrResult(
            confidence: 84,
            text: '''
UDUPI UPCHAR
Date: 26/11/2026
Masala Dosa   90.00
Grand Total   90.00
''',
          );
        },
      );

      await _pumpMoneyApp(tester, env: env, bridge: bridge);

      await tester.tap(find.text('Scan bill'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();

      expect(find.textContaining('No readable text found'), findsOneWidget);
      await tester.tap(find.text('Rotate 90° & rescan'));
      await tester.pumpAndSettle();

      expect(bridge.recognizeCalls, [
        ('/cache/receipt_scans/scan_1.jpg', 0),
        ('/cache/receipt_scans/scan_1.jpg', 90),
      ]);
      expect(find.text('Save 1 expense'), findsOneWidget);

      // Dismiss without saving still cleans up the temp image.
      Navigator.of(tester.element(find.text('Review scanned bill'))).pop();
      await tester.pumpAndSettle();
      expect(bridge.deletedPaths, ['/cache/receipt_scans/scan_1.jpg']);
    },
  );

  testWidgets(
    'Paste bill text works offline without camera and handles total-only bills',
    (tester) async {
      final env = await _seedEnv(tester);
      final bridge = _FakeReceiptOcrBridge(
        onRecognize: (_, _) => const ReceiptOcrResult(text: ''),
      );

      await _pumpMoneyApp(tester, env: env, bridge: bridge);

      await tester.tap(find.text('Scan bill'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Paste bill text'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).last,
        '''
INDIAN OIL PUMP
Date: 26/11/2026
Bill Amount Rs. 500.00
''',
      );
      await tester.tap(find.text('Extract items'));
      await tester.pumpAndSettle();

      expect(bridge.pickCalls, isEmpty);
      expect(find.text('Save expense'), findsOneWidget);

      await tester.ensureVisible(find.text('Save expense'));
      await tester.tap(find.text('Save expense'));
      await tester.pumpAndSettle();

      final rows = await (env.db.select(
        env.db.expenses,
      )..where((e) => e.deleted.equals(false))).get();
      expect(rows.length, 1);
      expect(rows.single.merchant, 'Indian Oil Pump');
      expect(rows.single.amountPaise, 50000);
      expect(rows.single.source, 'manual');
    },
  );
}
