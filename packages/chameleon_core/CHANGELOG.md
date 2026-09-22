## 0.3.0

- Added `PushNotificationService`: a vendor-neutral interface for push
  token retrieval, permission requests, and foreground message receipt,
  with a `NoopPushNotificationService` default — same no-hard-dependency
  shape as `BiometricAuthenticator`/`HomeWidgetUpdater`. No
  `firebase_messaging` dependency here; a consuming app supplies the real
  implementation only when it opts in.

## 0.2.0

- Added `HomeWidgetUpdater`: a vendor-neutral interface for pushing data to
  a home-screen widget, with a `NoopHomeWidgetUpdater` default — same
  no-hard-dependency shape as `BiometricAuthenticator`/`FeatureFlags`. No
  `home_widget` dependency here; a consuming app supplies the real
  implementation only when it opts in.

## 0.1.0

- Initial release, forked from a private `calbank_core` package.
- Errors/failures, chopper-based networking (auth, retry, idempotency,
  logging interceptors), biometrics, secure storage, DI (injectable
  micro-package), connectivity bloc, and a pluggable logging service with
  Noop-by-default crash/analytics reporters.
- Feature flags: vendor-neutral `FeatureFlags` interface with a
  `NoopFeatureFlags` default. No Firebase dependency — see the README for
  how to wire a real backend from a consuming app.
