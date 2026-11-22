import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

Future<String> deviceModel() async {
  if (kIsWeb) return 'Browser';
  try {
    final plugin = DeviceInfoPlugin();
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return (await plugin.androidInfo).model;
      case TargetPlatform.iOS:
        return (await plugin.iosInfo).utsname.machine;
      default:
        return 'Phone';
    }
  } catch (_) {
    return 'Phone';
  }
}
