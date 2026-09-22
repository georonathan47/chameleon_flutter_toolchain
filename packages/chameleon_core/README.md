# chameleon_core

Vendor-agnostic, cross-cutting Flutter infrastructure for the Chameleon
toolchain: errors/failures, a chopper-based network layer (auth, retry,
idempotency, and logging interceptors), biometrics, secure storage,
dependency injection (an `injectable` micro-package), a connectivity bloc,
and a pluggable logging service.

## The Noop-adapter pattern

Every integration point that would otherwise force a specific third-party
vendor on every consumer ships with a safe **no-op default**, and a real
implementation is opt-in from the consuming app:

| Seam | Interface | Default | Real implementation |
| --- | --- | --- | --- |
| Crash reporting | `ChameleonCrashReporter` | `NoopCrashReporter` | e.g. Firebase Crashlytics, Sentry — wired via `ChameleonLogger.useCrashReporter` |
| Product analytics | `AnalyticsReporter` | `NoopAnalyticsReporter` | e.g. Firebase Analytics, Mixpanel — wired via `ChameleonLogger.useAnalyticsReporter` |
| Biometric auth | `BiometricAuthenticator` | `NoopBiometricAuthenticator` | e.g. `local_auth` — bound in the app's own DI setup |
| Feature flags | `FeatureFlags` | `NoopFeatureFlags` | e.g. Firebase Remote Config, LaunchDarkly — bound in the app's own DI setup |
| Home-screen widget | `HomeWidgetUpdater` | `NoopHomeWidgetUpdater` | e.g. `home_widget` — bound in the app's own DI setup |
| Push notifications | `PushNotificationService` | `NoopPushNotificationService` | e.g. `firebase_messaging` — bound in the app's own DI setup |

This is why `chameleon_core` has **zero** dependency on any specific crash
reporting, analytics, biometrics, or feature-flag vendor SDK — including
Firebase. The package stays dependency-light and fully testable without any
vendor app or credentials, and a consuming app decides which real backends
(if any) it wants, implementing the relevant interface itself.

Everything else in this package — the `Failure` hierarchy, the chopper
client factory and its interceptors, token/secure storage, the connectivity
bloc, `FlavorConfig`, and the isolate helpers — is "always-on" infra with no
vendor to abstract away, so those ship as concrete, ready-to-use
implementations.

## Feature flags

`FeatureFlags` is intentionally minimal (`getBool`/`getString`/`getInt`/
`getDouble`/`initialize`) and vendor-neutral. `NoopFeatureFlags` (the
default) always returns the type's zero value and does nothing on
`initialize`. To back it with a real provider, implement `FeatureFlags` in
your app and bind your implementation in your own DI setup — `chameleon_core`
does not ship or depend on `firebase_remote_config` or any other flag
vendor's SDK.

## Dependency injection

This package registers its `@lazySingleton`/`@injectable` classes as an
`injectable` "microPackage" via the generated
`lib/src/di/micropackage_init.module.dart`, exporting
`ChameleonCorePackageModule`. A consuming app's own `@InjectableInit()` picks
these up by passing:

```dart
@InjectableInit(externalPackageModulesBefore: [
  ExternalModule(ChameleonCorePackageModule),
])
void configureDependencies() => getIt.init();
```
