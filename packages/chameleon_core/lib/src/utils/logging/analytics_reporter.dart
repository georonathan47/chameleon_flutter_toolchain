/// Where `ChameleonLogger.trackEvent` sends product-analytics events.
///
/// Kept vendor-agnostic for the same reason `ChameleonCrashReporter` is:
/// this package must not force every consumer to ship a specific analytics
/// SDK (Firebase Analytics, Mixpanel, ...) or make its own tests depend on
/// one. A consuming app wires a real reporter in once at boot via
/// `ChameleonLogger.useAnalyticsReporter`; tests and apps that haven't wired
/// one get the no-op default.
abstract interface class AnalyticsReporter {
  void trackEvent(String name, {Map<String, Object?>? properties});
}

/// The default reporter: does nothing. Keeps this package's tests — and any
/// app that hasn't wired a real reporter yet — free of an analytics vendor
/// dependency.
class NoopAnalyticsReporter implements AnalyticsReporter {
  const NoopAnalyticsReporter();

  @override
  void trackEvent(String name, {Map<String, Object?>? properties}) {}
}
