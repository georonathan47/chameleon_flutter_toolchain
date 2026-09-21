import 'package:chameleon_core/chameleon_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
{{#use_biometrics}}
import 'package:local_auth/local_auth.dart';
{{/use_biometrics}}
import 'package:shared_preferences/shared_preferences.dart';

{{#use_biometrics}}
import '../auth/local_auth_biometric_authenticator.dart';
{{/use_biometrics}}

/// Provides the platform-level dependencies `chameleon_core`'s
/// `@lazySingleton`/`@injectable` classes need but cannot construct
/// themselves (plugin instances, and anything requiring async setup).
///
/// `chameleon_core` ships as an injectable "microPackage" — its own
/// `AuthInterceptor`, `IdempotencyInterceptor`, `NetworkInfoImpl`,
/// `ConnectivityBloc`, `DeviceIdentity`, `SessionEventBus`, and
/// `ChameleonLogger` are already registered automatically by
/// `configureDependencies()`. This module only supplies what's left:
/// `Connectivity`, `SharedPreferences`, `FlutterSecureStorage` (which
/// `SecureStorageImpl` itself needs), `TokenStorage` (built from
/// `SecureStorage` + `SharedPreferences`), `SessionCache`, `FeatureFlags`,
/// and `BiometricAuthenticator`.
///
/// TODO(chameleon): `AuthInterceptor.configureNoAuthPaths` and
/// `IdempotencyInterceptor.configureRequiredPaths` still need calling with
/// this app's actual unauthenticated/idempotent endpoints once a real
/// backend contract exists (tasks/lessons.md #4 and #11) — both default to
/// empty, so nothing is exempted or tagged until you do. The `ChopperClient`
/// each feature needs is NOT provided here: `chameleon feature`
/// generates one per feature (see `lib/features/<name>/di/`), deliberately
/// not a single shared client — see that generator's own module doc comment
/// for why.
@module
abstract class CoreModule {
  /// `AuthInterceptor` (auto-registered by `chameleon_core`'s microPackage)
  /// requires a `SessionCache` — this app has no real "returning user"
  /// cache yet, so bind a no-op default (same pattern as `ChameleonLogger`'s
  /// `NoopCrashReporter`). Replace this binding once a feature adds a real
  /// cached-user store.
  @lazySingleton
  SessionCache get sessionCache => const NoopSessionCache();

  /// `chameleon_core` ships zero feature-flag backends by design — bind a
  /// real singleton either way (same pattern as `biometricAuthenticator`
  /// below) so a future feature's constructor-injected `FeatureFlags`
  /// dependency doesn't change shape later. Swap this binding for a real,
  /// vendor-backed `FeatureFlags` implementation once one exists.
  @lazySingleton
  FeatureFlags get featureFlags => const NoopFeatureFlags();

  @lazySingleton
  Connectivity get connectivity => Connectivity();

  @preResolve
  @lazySingleton
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @lazySingleton
  FlutterSecureStorage get flutterSecureStorage => const FlutterSecureStorage();

  @lazySingleton
  TokenStorage tokenStorage(SecureStorage secure, SharedPreferences prefs) =>
      TokenStorage(secure, prefs);

  {{#use_biometrics}}
  @lazySingleton
  LocalAuthentication get localAuthentication => LocalAuthentication();

  @lazySingleton
  BiometricAuthenticator biometricAuthenticator(LocalAuthentication auth) =>
      LocalAuthBiometricAuthenticator(auth);
  {{/use_biometrics}}
  {{^use_biometrics}}
  /// `use_biometrics` is off — no biometric UI calls this, but binding a
  /// real singleton either way (same pattern as `sessionCache` above) keeps
  /// a feature's constructor-injected dependency the same shape regardless
  /// of the flag.
  @lazySingleton
  BiometricAuthenticator get biometricAuthenticator =>
      const NoopBiometricAuthenticator();
  {{/use_biometrics}}
}
