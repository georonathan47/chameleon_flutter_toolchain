# Architecture

Feature-first, clean architecture (Reso Coder-style), on top of a
`very_good create` VGV bootstrap.

```
lib/
  app/                 App widget, MaterialApp.router wiring
  bootstrap.dart        Shared entrypoint (DI, BlocObserver, error handling)
  main_development.dart  Per-flavor entrypoints — set FlavorConfig, run bootstrap
  main_staging.dart
  main_production.dart
  core/
    config/             Env (envied), app-specific config
    di/                 injection_container.dart (getIt), core_module.dart (@module)
    errors/              app_failures.dart — app-specific Failure subclasses
    network/             envelope factories for chopper
    router/              app_router.dart ({{#use_go_router}}go_router{{/use_go_router}}{{^use_go_router}}auto_route{{/use_go_router}}), route_guard.dart (tri-state auth)
    auth/                 local_auth-backed BiometricAuthenticator (only when use_biometrics is on)
  features/
    <feature>/
      data/{datasources,models,repositories,services}
      domain/{entities,repositories,usecases}
      presentation/{bloc|cubit,pages,widgets}
```

## Where things live: package vs. brick

- **`chameleon_ui`** (design tokens, theme, toast/loader/glass-surface
  components): change here when the change should apply to every Chameleon
  app at once.
- **`chameleon_core`** (failures, logging, network layer, isolate helpers,
  flavor config, feature flags): same rule — cross-cutting infrastructure
  with no app-specific endpoint list or feature-model knowledge baked in.
- **This app** (`lib/`): app wiring, feature code, the specific `Failure`
  subclasses and endpoint lists that only make sense for this backend
  contract.

## Swift Package Manager

This app's iOS/macOS native dependencies resolve via **Swift Package
Manager**, Flutter's default dependency manager as of 3.44 (this app's
pinned version — see the repo root's `.fvmrc`). You don't do anything to
get this; it's automatic. `ios/Podfile` still exists and CocoaPods still
runs — Flutter falls back to it automatically for any plugin that hasn't
adopted SPM yet — but for a plugin that has (including `permission_handler`,
the one this template's own `--permissions` flag depends on), SPM is what
actually resolves it. Concretely: `permission_handler`'s SPM package finds
this app's `Info.plist` on its own and enables each permission whose
`NS*UsageDescription` key is present — no Podfile macro required, unlike
the CocoaPods-only path `tasks/lessons.md` #15 and `docs/guardrails.md`
still describe as a fallback safety net.

If you ever need to force pure CocoaPods (e.g. a legacy CI image), Flutter's
own opt-out is a `pubspec.yaml` setting, not anything this brick generates:

```yaml
flutter:
  config:
    enable-swift-package-manager: false
```

## Home screen widgets

`use_home_widget` wires `HomeWidgetUpdater` (`chameleon_core`) to the
`home_widget` plugin. Turning it on also raises this app's iOS deployment
target from 13.0 to 14.0 (`project.pbxproj` and `ios/Podfile`, both) —
`home_widget`'s SPM package won't resolve below iOS 14, confirmed by
actually building. The two platforms aren't symmetric otherwise:

- **Android** is fully generated and works immediately:
  `ChameleonHomeWidgetProvider.kt`, its layout, its `appwidget-provider`
  XML, and the `AndroidManifest.xml` `<receiver>` entry are all written for
  you.
- **iOS** ships Swift starter source under `ios/HomeWidgetExtension/`, but
  the Widget Extension target itself has to be created by hand in Xcode —
  Apple gives no scriptable path for this, confirmed against Flutter's own
  docs. See `ios/HomeWidgetExtension/README.md` for the exact steps
  (target creation, App Group registration).

Push data to the widget from anywhere in the app via DI:

```dart
final updater = getIt<HomeWidgetUpdater>();
await updater.saveData('title', 'Balance');
await updater.saveData('value', '\$1,234.56');
await updater.updateWidget();
```

When `use_home_widget` is off, `HomeWidgetUpdater` resolves to
`NoopHomeWidgetUpdater` — the call site above compiles and runs either way,
it just does nothing until the flag is on.

## Deep linking

Unconditional — every generated app gets this, no flag required, because
`tool/checks.sh` already has a standing check for it (see
`docs/guardrails.md`) and every real Chameleon app eventually needs at
least a password-reset/magic-link deep link. Nothing here needs
`chameleon_core`-level handling: this app already uses `MaterialApp.router`
(see `lib/app/view/app.dart`), so Flutter's own
`PlatformRouteInformationProvider` hands GoRouter/auto_route both the
cold-start link and every subsequent one automatically — declare the real
route (`GoRoute`/`AutoRoute`) and that's the whole app-side job. What
`post_gen.dart` generates is the *native registration* that lets the OS
hand the app a link in the first place:

- **A custom URL scheme** (`{{project_name.snakeCase()}}` with underscores
  stripped, e.g. `myapp://reset-password`) — `CFBundleURLTypes` in
  `ios/Runner/Info.plist` and a plain intent-filter in
  `AndroidManifest.xml`. Works immediately, no server required — this is
  what a password-reset email can use right away.
- **An HTTPS App Link / Universal Link** intent-filter
  (`android:autoVerify="true"`) pointed at a **placeholder** host derived
  by reversing `org_name` (e.g. `com.example` → `example.com`). This
  satisfies `tool/checks.sh`'s check, but it's a placeholder: it will not
  actually verify until you own that domain, replace the placeholder in
  `AndroidManifest.xml`, and host `/.well-known/assetlinks.json` there
  (Android) and `/.well-known/apple-app-site-association` there (iOS).
  Completing the iOS half of Universal Links additionally needs the
  Associated Domains capability added in Xcode (Signing & Capabilities > +
  Capability > Associated Domains > `applinks:<your-real-host>`) — a
  one-time manual step, same "can't be scripted" reasoning as the Widget
  Extension target in "Home screen widgets" below, just a capability
  toggle rather than a whole new target.

## Push notifications

`use_push_notifications` wires `PushNotificationService` (`chameleon_core`)
to `firebase_messaging`. Unlike the flags above, this one needs manual
setup on **both** platforms before it does anything at all — none of it is
optional, and none of it can be scripted:

1. Give the app a real Firebase project: run `flutterfire configure` from
   the project root (recommended — it also places
   `google-services.json`/`GoogleService-Info.plist` and matches bundle/
   application IDs for you), or add those two files manually. This
   toolchain deliberately does not script the Android Gradle wiring
   Firebase needs (the Google Services Gradle plugin) — `flutterfire
   configure` is Firebase's own, safer tool for that exact job, and this
   toolchain has never hand-patched `build.gradle.kts` for the same reason
   documented in the home-widget work (avoiding Glance/Compose wiring).
2. **iOS**: add the Push Notifications and Background Modes (Remote
   notifications) capabilities in Xcode (Signing & Capabilities), and
   upload an APNs authentication key in the Firebase console.
3. **Android**: nothing further — `firebase_messaging` needs no manifest
   wiring beyond the `POST_NOTIFICATIONS` permission, which
   `post_gen.dart` already declared for you.

Until step 1 is done, the generated `Firebase.initializeApp()` call in
`bootstrap.dart` compiles and analyzes cleanly (it passes no
`FirebaseOptions`, reading native config files directly) but fails at
runtime — same "compiles now, needs a manual step to actually work" bar as
every other opt-in flag in this brick.

Use it from anywhere in the app via DI:

```dart
final pushNotifications = getIt<PushNotificationService>();
final granted = await pushNotifications.requestPermission();
final token = await pushNotifications.getToken();
pushNotifications.onMessage.listen((message) {
  // message['title'], message['body'], message['data']
});
```

When `use_push_notifications` is off, `PushNotificationService` resolves to
`NoopPushNotificationService` — the call site above compiles and runs
either way, it just never grants permission or emits a message until the
flag is on.

## Responsive breakpoints

`chameleon_ui` ships `ChameleonBreakpoints`/`ChameleonWindowSizeClass` — a
three-tier responsive system: `phone` (`<600dp`), `tablet`
(`600–839dp`), `foldable` (`≥840dp`, uncapped). A window size class comes
purely from measured width, not device type, so a foldable isn't a fourth
tier of its own: a folded cover screen is narrow enough to land in `phone`
like any phone, and an unfolded inner display lands in `tablet` (portrait)
or `foldable` (landscape) from its real width alone.

```dart
switch (ChameleonBreakpoints.of(context)) {
  ChameleonWindowSizeClass.phone => const SingleColumnLayout(),
  ChameleonWindowSizeClass.tablet => const TwoColumnLayout(),
  ChameleonWindowSizeClass.foldable => const ThreeColumnLayout(),
}
```

## Dark mode

Unconditional, no flag required: `app.dart` wires `darkTheme:
ChameleonTheme.dark` and `themeMode: ThemeMode.system` alongside `theme:
ChameleonTheme.light`, so this app follows the device's system setting out
of the box. `chameleon_ui`'s own components (dialogs, the bottom sheet, the
empty state, the skeleton) resolve their colors through a
`ChameleonSemanticColorsExtension` that flips with the active theme, not a
fixed light value, so they render correctly in both modes — not just
Material's own buttons/inputs/app bar. A feature's own screens should
reach for `Theme.of(context).colorScheme` (or `ChameleonSemanticColors`/
`ChameleonSemanticColorsDark` directly, branching on
`Theme.of(context).brightness`, for a role `ColorScheme` doesn't cover)
rather than assuming light.

## Data flow

`Page` → `BlocBuilder`/`BlocSelector` reads a `Bloc`/`Cubit` → dispatches an
event/calls a method → `UseCase` → `Repository` (returns
`TaskEither<Failure, T>` from `fpdart`) → `DataSource` (runs the network call
on a worker isolate via `chameleon_core`'s `runApiCall`/`compute()`) →
`ChopperService` → `AuthInterceptor`/`IdempotencyInterceptor` (from
`chameleon_core`, configured in `core_module.dart`) → the backend.
