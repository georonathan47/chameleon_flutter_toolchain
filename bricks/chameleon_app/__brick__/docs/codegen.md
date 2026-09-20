# Code generation

Run after touching anything annotated `@freezed`, `@JsonSerializable`,
`@injectable`/`@lazySingleton`/`@module`, `@ChopperApi`, or `@Envied`:

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

## Before you run it

- `.env` must exist (copied from `.env.example` by the brick's post-gen
  hook on first generation) — `envied` reads it to produce `env.g.dart`. No
  `.env`, no `env.g.dart`, and the failure surfaces as every other builder
  erroring too.

## When it fails with many errors at once

`freezed`, `json_serializable`, `injectable`, `chopper`, and `envied` all
analyze the whole library before generating anything. **One unparseable
file stops every builder.** The error list will look like several unrelated
failures spread across unrelated files — it is usually one syntax error.
Find that first; don't start "fixing" the rest until it's gone.

## Common mistakes this template already avoids — don't reintroduce them

- `@JsonSerializable()` stacked above `@freezed` fails with "Cannot
  populate the required constructor argument," because `json_serializable`
  sees the abstract class, not freezed's generated concrete one. A model is
  `@freezed` + a `fromJson` factory + `part '*.g.dart'`. Nothing else.
- A constructor parameter on an `@injectable`/`@lazySingleton` class that
  isn't a real registered dependency (a `Function` type, a config value)
  breaks the generator — injectable tries to resolve *every* parameter,
  optional ones included. Put config on a settable field/method instead
  (see `AuthInterceptor.configureNoAuthPaths` in `chameleon_core` for the
  pattern), and test-only seams on a separate named constructor.
