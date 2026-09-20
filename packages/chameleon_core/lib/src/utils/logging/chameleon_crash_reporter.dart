/// Where `ChameleonLogger` reports errors.
///
/// A cross-cutting infra package must not hang a hard dependency on Firebase
/// (or any other specific crash-reporting vendor) — that would force every
/// consumer to ship `firebase_crashlytics`, and make this package untestable
/// without a Firebase app. A consuming app supplies a real implementation
/// (backed by `firebase_crashlytics`, Sentry, or anything else) and wires it
/// in once at boot via `ChameleonLogger.useCrashReporter`; tests and apps
/// that haven't opted in get the no-op default.
abstract interface class ChameleonCrashReporter {
  void recordError(Object error, StackTrace stackTrace, {String? reason});
}

/// The default reporter: does nothing. Keeps this package's tests — and any
/// app that hasn't wired a real reporter yet — free of a crash-reporting
/// vendor dependency.
class NoopCrashReporter implements ChameleonCrashReporter {
  const NoopCrashReporter();

  @override
  void recordError(Object error, StackTrace stackTrace, {String? reason}) {}
}
