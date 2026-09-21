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

## Data flow

`Page` → `BlocBuilder`/`BlocSelector` reads a `Bloc`/`Cubit` → dispatches an
event/calls a method → `UseCase` → `Repository` (returns
`TaskEither<Failure, T>` from `fpdart`) → `DataSource` (runs the network call
on a worker isolate via `chameleon_core`'s `runApiCall`/`compute()`) →
`ChopperService` → `AuthInterceptor`/`IdempotencyInterceptor` (from
`chameleon_core`, configured in `core_module.dart`) → the backend.
