import 'package:chameleon_core/chameleon_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:{{project_name.snakeCase()}}/app/app.dart';

/// Registering something in DI is not the same as registering it with
/// whatever actually constructs it — see tasks/lessons.md #10. This test
/// builds the real object graph via `configureDependencies()` (the same call
/// `bootstrap.dart` makes) rather than stubbing anything, so a wiring mistake
/// (a missing provider, a class the generator didn't see) fails here instead
/// of at first use in the running app.
///
/// TODO(chameleon): once `AuthInterceptor`/`ChopperClient` are wired (see the
/// TODO in `core/di/core_module.dart`), add `getIt<AuthApiClient>()` (or
/// your first real chopper service) to this test — that's the resolution
/// guardrail #10 actually protects: a chopper client that only knows the
/// services you remembered to list in `services: [...]`.
void main() {
  // SharedPreferences.getInstance() (resolved via CoreModule as part of
  // configureDependencies()) goes through a platform channel, which needs a
  // binding — a plain test() has none initialized by default.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // CoreModule.sharedPreferences resolves via a platform channel that has
    // no real implementation under `flutter test` — this seeds the
    // in-memory fake shared_preferences ships for exactly this case.
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });

  tearDownAll(getIt.reset);

  test('the DI container resolves every wired core dependency', () {
    expect(getIt<ConnectivityBloc>(), isNotNull);
    expect(getIt<TokenStorage>(), isNotNull);
    expect(getIt<NetworkInfo>(), isNotNull);
    expect(getIt<DeviceIdentity>(), isNotNull);
    expect(getIt<SessionEventBus>(), isNotNull);
    expect(getIt<ChameleonLogger>(), isNotNull);
    expect(getIt<FeatureFlags>(), isNotNull);
    expect(getIt<BiometricAuthenticator>(), isNotNull);
  });

  test('getIt<X> resolves the same singleton instance on repeat calls', () {
    expect(getIt<TokenStorage>(), same(getIt<TokenStorage>()));
    expect(getIt<ConnectivityBloc>(), same(getIt<ConnectivityBloc>()));
  });
}
