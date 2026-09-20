# Chameleon Flutter Toolchain

A melos-managed monorepo that scaffolds production-ready Flutter apps with zero
brand assets: a design-system package, cross-cutting infrastructure, a Mason
brick that overlays clean architecture onto a fresh `very_good create`
project, and a `chameleon` CLI that drives the whole pipeline end to end.

No logos, no custom fonts, no brand color palette. Flavor is signalled the
same way for every app this toolchain generates:

| Flavor      | Color                     |
| ----------- | ------------------------- |
| development | red                       |
| staging     | blue                      |
| production  | transparent (no banner)   |

## Layout

```
packages/
  chameleon_ui/     design tokens, theme, shared components
  chameleon_core/    failures, logging, network layer, feature flags, DI
bricks/
  chameleon_app/     Mason brick — the app skeleton
  chameleon_feature/  Mason brick — a feature slice
  chameleon_bloc/     Mason brick — a bloc/cubit slice
cli/
  chameleon_cli/      the `chameleon` executable
```

## Getting started

Every package pins Flutter 3.44.0 via `.fvmrc`. From this repo root:

```bash
fvm flutter --version   # confirm 3.44.0 resolves
fvm dart pub global activate mason_cli
fvm dart pub global activate melos
melos bootstrap
melos run analyze
melos run test
```

## Creating a Chameleon app

```bash
mason bundle bricks/chameleon_app -t dart -o cli/chameleon_cli/lib/src/bundles/
mason bundle bricks/chameleon_feature -t dart -o cli/chameleon_cli/lib/src/bundles/
mason bundle bricks/chameleon_bloc -t dart -o cli/chameleon_cli/lib/src/bundles/
dart pub global activate --source path cli/chameleon_cli
export PATH="$PATH":"$HOME/.pub-cache/bin"

chameleon doctor
chameleon flutter create my_app
```

Run this from wherever you want the app created. The generated project
depends on `chameleon_ui`/`chameleon_core` by pinned `git:` ref against this
public repo, so there's no sibling-directory requirement and no private-repo
authentication to set up.

`chameleon flutter create --help` lists every flag (state management,
biometrics, permissions, fvm override, and the install/codegen/verify/git
steps, each individually skippable). The command runs `very_good create` (or
plain `flutter create` if `very_good_cli` isn't installed), overlays the
brick, resolves dependencies, and — unless `--no-verify` is passed — refuses
to call the project done until `flutter analyze` and `flutter test` are
clean.

## Adding a feature to a Chameleon app

From that app's own root (detected via the `.chameleon/template.yaml` marker
`create` leaves behind):

```bash
chameleon flutter feature beneficiaries
```

Generates `lib/features/beneficiaries/` (entity, model, chopper api client,
isolate-wrapped datasource, repository, a bloc, a page) and matching tests,
then runs the same verification gate `create` does.

To add a second piece of state management inside a feature that already
exists (a filter, a form, a toggle — not a new repository call):

```bash
chameleon flutter bloc filters --feature beneficiaries
chameleon flutter bloc search --feature beneficiaries --cubit
```

## Status

This is v1, deliberately scoped lean: `chameleon_core`, `chameleon_ui`, the
three Mason bricks, and a CLI with `doctor` / `flutter create` /
`flutter feature` / `flutter bloc`. Deferred to a follow-up: a custom-lint
package, CLI self-update, a `firebase verify` command, the generate-and-verify
e2e matrix, and `auto_route` support (`go_router` only for now).

No Firebase (or any other vendor) dependency is required anywhere in this
toolchain by default — crash reporting, analytics, feature flags, and
biometrics all ship with safe no-op defaults in `chameleon_core`; wiring a
real vendor is an opt-in step for a consuming app, not something this
toolchain assumes.

Every generated app's launcher icon and in-app loading indicator use one
original, procedurally-drawn chameleon glyph (no binary brand assets checked
in anywhere in this repo) — colored per flavor using the same red/blue/none
convention as the debug banner.
