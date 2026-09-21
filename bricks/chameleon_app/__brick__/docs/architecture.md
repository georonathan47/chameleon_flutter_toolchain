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

## Data flow

`Page` → `BlocBuilder`/`BlocSelector` reads a `Bloc`/`Cubit` → dispatches an
event/calls a method → `UseCase` → `Repository` (returns
`TaskEither<Failure, T>` from `fpdart`) → `DataSource` (runs the network call
on a worker isolate via `chameleon_core`'s `runApiCall`/`compute()`) →
`ChopperService` → `AuthInterceptor`/`IdempotencyInterceptor` (from
`chameleon_core`, configured in `core_module.dart`) → the backend.
