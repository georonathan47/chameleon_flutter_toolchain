# chameleon_lints

`custom_lint` rules that turn Chameleon's `tasks/lessons.md` into enforced
static analysis instead of tribal knowledge — three real bugs found once,
each turned into a rule so it can't recur.

Every app `chameleon flutter create` generates wires this in as a
`custom_lint` plugin automatically, gated in `tool/verify.sh` alongside
`flutter analyze` and `flutter test`.

## Rules

| Rule | Flags | Why |
| --- | --- | --- |
| `chameleon_no_set_state` | Any bare `setState(...)` call | Widget-local state belongs in a Cubit/Bloc, driven by `BlocBuilder`/`BlocSelector`/`BlocConsumer` — no exceptions, not even for "small" UI state. |
| `chameleon_bloc_provider_value_for_di` | `BlocProvider(create: (_) => getIt<X>())` where `X` is `@lazySingleton`/`@Singleton` | `create:` closes the bloc on widget dispose. Fine for an `@injectable` factory (a fresh instance every call); wrong for a singleton — the DI container keeps holding that same, now-closed instance, and the next resolver gets a dead bloc. Use `BlocProvider.value(value: getIt<X>())` instead. Resolves the type argument's real DI annotation rather than pattern-matching syntax, so it doesn't flag `chameleon_feature`'s own correct factory-scoped `create:` usage. |
| `chameleon_no_function_type_in_injectable_ctor` | A function-typed constructor parameter on an `@injectable`/`@lazySingleton`/`@singleton` class's **unnamed** constructor | `injectable` resolves every constructor parameter from the DI container, optional ones included, and fails with "Can not resolve function type" the moment one is function-typed (a clock/test seam like `DateTime Function()? now`). Put the seam on a separate named constructor instead (`MyService.withClock(this._now)`) — named constructors are never auto-resolved, so the rule skips them. |

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

`chameleon flutter create` writes both for you — see
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
