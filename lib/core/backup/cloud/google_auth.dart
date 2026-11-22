import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:nm_flat/core/backup/cloud/cloud_ids.dart';

/// Google Sign-In and Drive `drive.appdata` scope helpers.
class GoogleAuth {
  GoogleAuth._();

  static const List<String> scopes = [drive.DriveApi.driveAppdataScope];

  static Future<void>? _init;

  static Future<void> ensureInitialized() =>
      _init ??= GoogleSignIn.instance.initialize(
        serverClientId: CloudIds.googleServerClientId,
      );

  static Future<({String email, GoogleSignInClientAuthorization authz})>
  signIn() async {
    await ensureInitialized();
    final account = await GoogleSignIn.instance.authenticate(
      scopeHint: scopes,
    );
    final authz =
        await account.authorizationClient.authorizationForScopes(scopes) ??
        await account.authorizationClient.authorizeScopes(scopes);
    return (email: account.email, authz: authz);
  }

  static Future<GoogleSignInClientAuthorization?> silent() async {
    await ensureInitialized();
    return GoogleSignIn.instance.authorizationClient.authorizationForScopes(
      scopes,
    );
  }
}
