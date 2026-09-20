/// What `AuthInterceptor` needs from the app's cached-user store on a 401.
///
/// The real cache (persisted returning-user identity, read by a login page to
/// greet the user without a network round-trip) is feature-layer, app-owned
/// state — a cross-cutting infra package has no business knowing its shape.
/// `AuthInterceptor` only ever needs to wipe it alongside the auth tokens, so
/// this is the one method it actually calls. The app's real cache implements
/// this interface; nothing about it changes.
abstract interface class SessionCache {
  Future<void> clear();
}

/// Default binding for an app with no cached-user store yet — `clear()` is
/// a no-op. `AuthInterceptor` still needs *something* bound to `SessionCache`
/// (it's a required constructor param, resolved from DI), so an app wires
/// this until a real cache exists. Same pattern as `ChameleonCrashReporter`'s
/// `NoopCrashReporter`.
final class NoopSessionCache implements SessionCache {
  const NoopSessionCache();

  @override
  Future<void> clear() async {}
}
