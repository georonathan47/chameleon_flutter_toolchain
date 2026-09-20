import 'package:chameleon_core/chameleon_core.dart';
import 'package:envied/envied.dart';

part 'env.g.dart';

/// Per-flavor API base URLs, loaded from the gitignored `.env` file (see
/// `.env.example`). Regenerate with `dart run build_runner build` after
/// editing `.env`.
///
/// Fields are `static final`, not `const`: `obfuscate: true` makes envied
/// decode each value at runtime (XOR against a generated key), which can't
/// be a compile-time constant.
@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'API_BASE_URL_DEV')
  static final String apiBaseUrlDev = _Env.apiBaseUrlDev;

  @EnviedField(varName: 'API_BASE_URL_STG')
  static final String apiBaseUrlStg = _Env.apiBaseUrlStg;

  @EnviedField(varName: 'API_BASE_URL_PROD')
  static final String apiBaseUrlProd = _Env.apiBaseUrlProd;

  /// The base URL for whichever flavor is currently running, so a feature's
  /// DI module can build its `ChopperClient` without re-switching on
  /// `FlavorConfig` itself. Asserts a flavor was initialized, the same as
  /// `FlavorConfig.instance` — a missing `FlavorConfig.initialize()` call is
  /// a boot-order bug, not something to silently default around here.
  static String get current => switch (FlavorConfig.instance.flavor) {
    Flavor.dev => apiBaseUrlDev,
    Flavor.stg => apiBaseUrlStg,
    Flavor.prod => apiBaseUrlProd,
  };
}
