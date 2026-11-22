import 'package:package_info_plus/package_info_plus.dart';

/// Public OAuth client IDs (not secrets). Filled in by the human from the P20 console setup.
class CloudIds {
  CloudIds._();

  static const String googleServerClientId = '';
  static const String dropboxAppKey = '';
  static const String microsoftClientId = '';
  static const String pcloudClientId = '';

  static bool has(String id) => id.trim().isNotEmpty;
}

Future<String> appPackageName() async =>
    (await PackageInfo.fromPlatform()).packageName;

Future<String> appAuthRedirect() async =>
    '${await appPackageName()}://oauth2redirect';

Future<String> pcloudRedirect() async =>
    '${await appPackageName()}.pcloud://callback/oauth-pcloud';
