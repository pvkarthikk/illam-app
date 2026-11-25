import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/crypto/home_key_ring.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/remote/firebase_rest_client.dart';
import 'package:nm_flat/core/sync/remote/remote_sync_config.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/features/remote_sync/remote_sync_screen.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

import '../../core/backup/cloud/fake_token_adapter.dart';

Future<(RemoteSyncConfigStore, MemorySecureStore, FakeAdapter)> _pumpScreen(
  WidgetTester tester, {
  RemoteSyncConfig? initial,
}) async {
  tester.view.physicalSize = const Size(412, 1900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final db = NestDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final prefs = await DevicePrefs.inMemory();
  await prefs.setCurrentHomeId('NM-UI1');
  final secure = MemorySecureStore();
  await HomeKeyRing(secure).add('NM-UI1', 'genesis', List.filled(32, 5));
  final store = RemoteSyncConfigStore(secure);
  addTearDown(store.dispose);
  if (initial != null) {
    await store.save('NM-UI1', initial);
  }

  final adapter = FakeAdapter();
  final dio = Dio(BaseOptions(validateStatus: (_) => true))
    ..httpClientAdapter = adapter;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(db),
        prefsProvider.overrideWithValue(prefs),
        secureStoreProvider.overrideWithValue(secure),
        clockProvider.overrideWithValue(
          FixedClock(DateTime.utc(2026, 11, 25, 10, 0)),
        ),
        remoteSyncConfigStoreProvider.overrideWithValue(store),
        firebaseRestClientProvider.overrideWithValue(
          FirebaseRestClient(dio: dio),
        ),
      ],
      child: MaterialApp(
        theme: NestTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const RemoteSyncScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (store, secure, adapter);
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  group('RemoteSyncScreen', () {
    testWidgets('hides Firebase fields when toggle is OFF and reveals on toggle ON', (tester) async {
      final (store, _, _) = await _pumpScreen(tester);

      expect(find.text('Remote sync (experimental)'), findsOneWidget);
      expect(find.text('Bring Your Own Firebase'), findsOneWidget);
      expect(find.text('Project ID'), findsNothing);
      expect(find.text('Web API key'), findsNothing);

      await tester.tap(find.text('Remote sync (experimental)'));
      await tester.pumpAndSettle();

      final savedAfterToggle = await store.load('NM-UI1');
      expect(savedAfterToggle.enabled, isTrue);
      expect(find.text('Project ID'), findsOneWidget);
      expect(find.text('Web API key'), findsOneWidget);
      expect(find.text('Copy security rules'), findsOneWidget);
      expect(find.text('Test connection'), findsOneWidget);
      expect(find.text('Save & connect'), findsOneWidget);
    });

    testWidgets('validates fields, tests connection, and saves credentials', (tester) async {
      final (store, _, adapter) = await _pumpScreen(
        tester,
        initial: RemoteSyncConfig(enabled: true),
      );

      // Save without inputs triggers inline field validation
      await tester.ensureVisible(find.text('Save & connect'));
      await tester.tap(find.text('Save & connect'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your Firebase Project ID'), findsOneWidget);
      expect(find.text('Enter your Firebase Web API key'), findsOneWidget);

      // Fill valid Firebase credentials
      await tester.enterText(
        find.widgetWithText(TextField, 'Project ID'),
        'illam-family-fb',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Web API key'),
        'AIzaSyTestWebApiKey12345',
      );

      adapter.replies
        ..add((
          200,
          jsonEncode({
            'idToken': 'id-1',
            'refreshToken': 'ref-1',
            'localId': 'uid-1',
            'expiresIn': '3600',
          }),
        ))
        ..add((200, '{}')) // probe PATCH
        ..add((200, '{}')) // probe GET
        ..add((200, '{}')) // probe DELETE
        ..add((200, jsonEncode([{'readTime': '2026-11-25T10:00:00Z'}])));

      await tester.ensureVisible(find.text('Test connection'));
      await tester.tap(find.text('Test connection'));
      await tester.pumpAndSettle();
      expect(
        find.text('Connection OK — Anonymous Auth and Firestore rules verified.'),
        findsOneWidget,
      );

      // Save & connect queues auth + initial pull/push queries
      adapter.replies
        ..add((
          200,
          jsonEncode({
            'idToken': 'id-1',
            'refreshToken': 'ref-1',
            'localId': 'uid-1',
            'expiresIn': '3600',
          }),
        ))
        ..add((200, jsonEncode([{'readTime': '2026-11-25T10:00:00Z'}])));

      await tester.ensureVisible(find.text('Save & connect'));
      await tester.tap(find.text('Save & connect'));
      await tester.pumpAndSettle();

      final saved = await store.load('NM-UI1');
      expect(saved.isActive, isTrue);
      expect(saved.projectId, 'illam-family-fb');
      expect(saved.apiKey, 'AIzaSyTestWebApiKey12345');
      expect(find.text('Connected · illam-family-fb'), findsOneWidget);
    });
  });
}
