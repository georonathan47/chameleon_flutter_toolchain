/// Remote/local feature flags.
///
/// Vendor-neutral by design: `chameleon_core` ships zero feature-flag
/// backends, only this interface plus `NoopFeatureFlags` (see
/// `noop_feature_flags.dart`) as the safe default. A consuming app wires in
/// a real backend — Firebase Remote Config, LaunchDarkly, a home-grown
/// config service, whatever it already uses — by implementing this
/// interface and binding it in its own DI setup. That keeps this package
/// free of any specific flag vendor's SDK as a hard dependency.
abstract class FeatureFlags {
  /// Configures fetch behavior, seeds [defaults] (an app supplies its own —
  /// a cross-cutting infra package can't know one app's specific flags),
  /// then fetches and activates the latest values. Call once at boot.
  Future<void> initialize({Map<String, Object> defaults = const {}});

  bool getBool(String key);
  String getString(String key);
  int getInt(String key);
  double getDouble(String key);
}
