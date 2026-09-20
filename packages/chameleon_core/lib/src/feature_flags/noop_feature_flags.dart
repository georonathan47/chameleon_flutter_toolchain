import 'feature_flags.dart';

/// The default [FeatureFlags] implementation: every flag reads back its
/// type's sensible zero value, and [initialize] does nothing.
///
/// Mirrors `NoopBiometricAuthenticator`: a cross-cutting infra package
/// cannot hang a hard dependency on any one feature-flag vendor, and this
/// package's own tests must not need a real flag backend to run. Left
/// unregistered here for the same reason `NoopBiometricAuthenticator` is —
/// a consuming app's own DI setup binds this (or a real, vendor-backed
/// `FeatureFlags` implementation) explicitly, since `chameleon_core` cannot
/// know which one an app wants by default.
class NoopFeatureFlags implements FeatureFlags {
  const NoopFeatureFlags();

  @override
  Future<void> initialize({Map<String, Object> defaults = const {}}) async {}

  @override
  bool getBool(String key) => false;

  @override
  String getString(String key) => '';

  @override
  int getInt(String key) => 0;

  @override
  double getDouble(String key) => 0;
}
