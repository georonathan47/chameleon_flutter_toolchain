# chameleon_lints

`custom_lint` rules that turn Chameleon's `tasks/lessons.md` and
`docs/architecture.md` into enforced static analysis instead of tribal
knowledge — the first three started as real bugs found once, each turned
into a rule so it can't recur; the rest codify style and architecture
conventions this project already expects.

Every app `chameleon create` generates wires this in as a
`custom_lint` plugin automatically, gated in `tool/verify.sh` alongside
`flutter analyze` and `flutter test`.

## Rules

| Rule | Flags | Why |
| --- | --- | --- |
| `chameleon_no_set_state` | Any bare `setState(...)` call | Widget-local state belongs in a Cubit/Bloc, driven by `BlocBuilder`/`BlocSelector`/`BlocConsumer` — no exceptions, not even for "small" UI state. |
| `chameleon_bloc_provider_value_for_di` | `BlocProvider(create: (_) => getIt<X>())` where `X` is `@lazySingleton`/`@Singleton` | `create:` closes the bloc on widget dispose. Fine for an `@injectable` factory (a fresh instance every call); wrong for a singleton — the DI container keeps holding that same, now-closed instance, and the next resolver gets a dead bloc. Use `BlocProvider.value(value: getIt<X>())` instead. Resolves the type argument's real DI annotation rather than pattern-matching syntax, so it doesn't flag `chameleon_feature`'s own correct factory-scoped `create:` usage. |
| `chameleon_no_print` | A bare `print(...)` or `debugPrint(...)` call (not `logger.print(...)`, and not a user-defined function that merely shares the name) | Output goes through the logging service (`ChameleonLogger` in `chameleon_core`): it writes user events to a capped log file, reports to crash reporting, and only prints to the console in non-prod flavors. A stray `print` bypasses all of that and ships to production consoles. A file named `logging_service.dart` is exempt. |
| `chameleon_datasource_requires_isolate` | A public, non-static, non-abstract method in a file under `data/datasources/` whose body doesn't invoke `runApiCall`, `runInIsolate`, `compute`, `Isolate.run`, or `Isolate.spawn` | Network I/O and JSON decoding must not run on the UI thread (120fps target). Matches `chameleon_feature`'s own generated datasource, whose method is `=> runApiCall(..., fetchX)`. The top-level/static `fetchX` worker and abstract interface methods aren't checked. A datasource that genuinely can't leave the root isolate (platform-channel/`shared_preferences`) suppresses with `// ignore: chameleon_datasource_requires_isolate`. |
| `chameleon_chopper_requires_error_check` | A `.body` read on a chopper `Response` where the same variable's `.isSuccessful` or `.error` is never read in that function | A failed HTTP call leaves `.body` null/unusable, so ignoring the status makes it look like a success further up the chain. Order-insensitive: `chameleon_feature`'s own datasource reads `.body` first and tests `.isSuccessful` right after, which is correct. A `.body` off a non-variable expression (`(await call).body`) is flagged. |
| `chameleon_no_function_type_in_injectable_ctor` | A function-typed constructor parameter on an `@injectable`/`@lazySingleton`/`@singleton` class's **unnamed** constructor | `injectable` resolves every constructor parameter from the DI container, optional ones included, and fails with "Can not resolve function type" the moment one is function-typed (a clock/test seam like `DateTime Function()? now`). Put the seam on a separate named constructor instead (`MyService.withClock(this._now)`) — named constructors are never auto-resolved, so the rule skips them. |
| `chameleon_prefer_dot_shorthands` | `Type.member` written where the target type is already known (an explicitly-typed variable, a typed argument, or a declared return position) | Dart's dot-shorthand syntax (`.member`) is shorter and just as clear once the target type is pinned down by context — scoped to those three positions to stay high-confidence rather than guess at inferred context elsewhere. |
| `chameleon_prefer_barrel_imports` | An import reaching past a feature's barrel file into `data/`/`domain/`/`presentation/`/`di/` from **outside** that feature | Reaching past the barrel defeats the point of having one. Same-feature imports are exempt — those are expected to reach each other directly. |
| `chameleon_prefer_sealed_class` | A non-sealed `abstract class`/`abstract base class`/`abstract interface class` whose subtypes are **all** declared in the same file | Nothing prevents sealing a genuinely closed hierarchy, and sealing it is what lets the analyzer check a `switch` over it is exhaustive. Suppress a deliberately open hierarchy (like `chameleon_core`'s own `Failure`, meant for external subclassing) with `// ignore: chameleon_prefer_sealed_class`. |
| `chameleon_task_either_requires_safe_construction` | A method/function returning `TaskEither<Failure, ...>` whose body isn't built from a safe `TaskEither` constructor (`tryCatch`/`of`/`right`/`left`/`fromEither`/`fromTask`/`fromOption`) | A `TaskEither<Failure, ...>` return type promises a `Success` or a `Failure`, never a thrown exception — a plain imperative `async`/`await` block can still throw straight past that contract. Doesn't flag the paired datasource layer for throwing; that's the other, correct half of the handoff this rule guards. |

## Installation

Tagged and consumed by generated apps as a `dev_dependency` git ref
against the
[toolchain repo](https://github.com/georonathan47/chameleon_flutter_toolchain):

```yaml
dev_dependencies:
  custom_lint: ^0.8.0
  chameleon_lints:
    git:
      url: https://github.com/georonathan47/chameleon_flutter_toolchain
      path: packages/chameleon_lints
      ref: chameleon_lints-v0.1.0
```

```yaml
# analysis_options.yaml
analyzer:
  plugins:
    - custom_lint
```

`chameleon create` writes both for you — see
[`bricks/chameleon_app/brick.yaml`](../../bricks/chameleon_app/brick.yaml)'s
`chameleon_lints_ref` var if you need to point an existing app at a newer
tag.

## Usage

```bash
dart run custom_lint
```

Runs as its own step in `tool/verify.sh` and in every generated app's CI
workflow, after `flutter analyze` and `flutter test`.

## Requirements

- `analyzer ^8.0.0`, `custom_lint_builder ^0.8.0` (this package's own
  dependency floor)
- A consuming app on `custom_lint ^0.8.0`

`freezed`/`json_annotation` versions matter here too: `freezed >=3.2.4`
needs `analyzer ^9.0.0`, past `custom_lint_builder`'s current `^8.0.0`
ceiling. Generated apps pin `freezed: ^3.2.3` / `json_annotation: ^4.9.0`
for exactly this reason — see the `TODO(chameleon)` comment in
[`bricks/chameleon_app/__brick__/pubspec.yaml`](../../bricks/chameleon_app/__brick__/pubspec.yaml).

## Contributing

Part of the
[chameleon_flutter_toolchain](https://github.com/georonathan47/chameleon_flutter_toolchain)
monorepo. Each rule has a fixture (`test/fixtures/`) and a test asserting
exactly which lines it flags — run `melos run test` from the repo root, or
`dart test` from this package. See the toolchain repo's `tasks/todo.md`
for build status.

## License

MIT — see [`LICENSE`](../../LICENSE).
