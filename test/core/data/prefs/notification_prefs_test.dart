import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/prefs/notification_prefs.dart';
import 'package:nm_flat/core/providers.dart';

void main() {
  test('initial state reflects DevicePrefs defaults and set persists updates', () async {
    final prefs = await DevicePrefs.inMemory();
    final container = ProviderContainer(
      overrides: [prefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    final initial = container.read(notificationPrefsProvider);
    expect(initial.evening, isFalse);
    expect(initial.arrival, isTrue);

    await container
        .read(notificationPrefsProvider.notifier)
        .set('notifEvening', true);

    expect(container.read(notificationPrefsProvider).evening, isTrue);
    expect(prefs.notifEvening, isTrue);
  });
}
