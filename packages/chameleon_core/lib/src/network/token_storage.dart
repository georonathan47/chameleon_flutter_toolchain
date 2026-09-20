import 'package:shared_preferences/shared_preferences.dart';

import '../storage/secure_storage.dart';

/// Stores the auth tokens in OS-level secure storage (Keychain on iOS,
/// EncryptedSharedPreferences/Keystore on Android), via [SecureStorage].
///
/// All reads go straight to secure storage — there is **no in-memory cache**.
/// An in-memory cache would drift across isolates because `compute()` ships
/// a copy of TokenStorage to each worker; refreshes/wipes on a worker would
/// not propagate back to the root, so the next root-isolate request would
/// still attach the stale token and 401 forever. Secure-storage reads are
/// fast (~1ms on warm cache) and the safety win is worth the per-call cost.
/// Routing through [SecureStorage] instead of `FlutterSecureStorage`
/// directly doesn't touch this invariant — every call still reaches real
/// secure storage, nothing is cached in between.
///
/// The access token is also mirrored into `SharedPreferences` on every
/// `saveTokens`/`clearTokens` so a background isolate that can't reach
/// platform-channel secure storage still has a readable copy. Secure storage
/// remains the authority for the root-isolate auth flow.
class TokenStorage {
  TokenStorage(this._secure, this._prefs);

  final SecureStorage _secure;
  final SharedPreferences _prefs;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<String?> getAccessToken() => _secure.read(_accessKey);

  Future<String?> getRefreshToken() => _secure.read(_refreshKey);

  Future<void> saveTokens(String accessToken, [String? refreshToken]) async {
    await _secure.write(_accessKey, accessToken);
    if (refreshToken != null) {
      await _secure.write(_refreshKey, refreshToken);
    }
    // Mirror for background/sync isolates — see class doc.
    await _prefs.setString(_accessKey, accessToken);
  }

  Future<void> clearTokens() async {
    await _secure.delete(_accessKey);
    await _secure.delete(_refreshKey);
    await _prefs.remove(_accessKey);
  }
}
