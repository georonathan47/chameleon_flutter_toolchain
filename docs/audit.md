# `chameleon audit`

Reports whether an existing generated app has drifted from this toolchain's
current guardrails. Run it from the app's root (detected via
`.chameleon/template.yaml`). It only reports — it never changes the app —
and exits non-zero if any check fails, so it works as a CI gate.

Not to be confused with `chameleon doctor`, which checks the tools installed
on your machine, not an app.

```bash
chameleon audit
chameleon audit --repo-url https://github.com/<fork>/chameleon_flutter_toolchain
```

Each check reports `✓` (pass), `⚠` (warning, doesn't fail the audit) or `✗`
(fail).

## Checks

### `chameleon_core` / `chameleon_ui` / `chameleon_lints` pinned ref

Compares the `git: ref:` each package is pinned to in `pubspec.yaml` against
the highest `<package>-vX.Y.Z` tag on the toolchain repo.

- `✗` pinned to an older release than the latest. **Fix:** bump the `ref:`
  to the latest tag and run `flutter pub upgrade`. Read the package's
  `CHANGELOG.md` first — a bump can pull in new lint rules or components.
- `⚠` the ref isn't a release tag (a branch or commit), or no matching tags
  were found — nothing to compare against.
- `⚠` the remote couldn't be reached. The check is skipped rather than
  failed, so an outage doesn't turn CI red.
- `✗` not a dependency at all. **Fix:** restore it in `pubspec.yaml`.

### `chameleon_lints` in dev_dependencies

`chameleon_lints` must be a dev dependency, otherwise its rules never run.

### `custom_lint` enabled in analysis_options.yaml

`analyzer.plugins` must list `custom_lint`. **Fix:** add it:

```yaml
analyzer:
  plugins:
    - custom_lint
```

### Guardrails (`tool/checks.sh`)

Runs the app's own `tool/checks.sh` and reports each `✗` line it prints
(`setState`, `SnackBar`, `dartz`, raw hex colors, missing permission usage
descriptions, missing deep-link registration, ...). Each message says what
to use instead; `tasks/lessons.md` in the app has the reasoning.

The one exception: `no leftover TODOs` is a `⚠`, not a `✗`. Every freshly
generated app ships a `TODO(chameleon)` in `core_module.dart` on purpose,
until a real backend contract is wired, so treating it as a failure would
make a brand-new app fail its own audit.

A missing `tool/checks.sh` is a `✗` — restore it from a freshly generated
app.
