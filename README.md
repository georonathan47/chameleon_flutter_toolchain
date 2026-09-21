# Chameleon Flutter Toolchain

A melos-managed monorepo that scaffolds production-ready Flutter apps: a
design-system package, cross-cutting infrastructure, a Mason brick that
overlays clean architecture onto a fresh `very_good create` project, and a
`chameleon` CLI that drives the whole pipeline end to end.

No custom fonts, no brand color palette beyond the flavor accent below.
Flavor is signalled the same way for every app this toolchain generates:

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
  chameleon_lints/    custom_lint rules enforced in every generated app
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
router (`go_router`/`auto_route`), biometrics, permissions, fvm override, and
the install/codegen/verify/git steps, each individually skippable). The
command runs `very_good create` (or plain `flutter create` if
`very_good_cli` isn't installed), overlays the brick, resolves dependencies,
and — unless `--no-verify` is passed — refuses to call the project done
until `flutter analyze`, `flutter test`, and `dart run custom_lint`
(`chameleon_lints`' rules) are all clean.

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

## Keeping the CLI up to date

```bash
chameleon update
```

Checks this repo's git tags for a `chameleon_cli-vX.Y.Z` newer than the
running CLI and reactivates from it if one exists (`--dry-run` to just
report). Defaults to this repo — pass `--repo-url` for a fork.

## Verifying a Firebase project

```bash
chameleon firebase verify my-project-id [another-project-id ...]
```

This toolchain has no Firebase dependency of its own — wiring one into a
generated app is a manual, opt-in step. Before you do, this command confirms
a project ID is real and accessible under whoever is logged in
(`firebase login`), with no side effects (`firebase apps:list --project=<id>`
— read-only, registers nothing). Requires `firebase-tools`
(`npm install -g firebase-tools`), reported by `chameleon doctor`; not
auto-installed, since it's an npm package that needs `firebase login`
regardless of how it's installed.

## Status

`chameleon_core`, `chameleon_ui`, `chameleon_lints`, the three Mason bricks,
and a CLI with `doctor` / `flutter create` / `flutter feature` /
`flutter bloc` / `update` / `firebase verify` all ship today.
`chameleon flutter create` supports both `go_router` and `auto_route`, and
every generated app is verified with `flutter analyze` + `flutter test` +
`dart run custom_lint` (`chameleon_lints`' three rules: no `setState`,
`BlocProvider.value` for DI-registered singletons, no function-typed params
on `@injectable` constructors) before `create`/`feature`/`bloc` report
success.

Deferred to a follow-up: the generate-and-verify e2e matrix.

No Firebase (or any other vendor) dependency is required anywhere in this
toolchain by default — crash reporting, analytics, feature flags, and
biometrics all ship with safe no-op defaults in `chameleon_core`; wiring a
real vendor is an opt-in step for a consuming app, not something this
toolchain assumes.

Every generated app's launcher icon defaults to a chameleon mascot
illustration, baked into the CLI per flavor (`cli/chameleon_cli/lib/src/icons/flavor_icon_sources.dart`):
a red "DEV" corner ribbon, a gold "STG" ribbon, and a plain icon for
production. The in-app loading indicator (`ChameleonMark`/`ChameleonSpinner`
in `chameleon_ui`) is a separate, still fully procedural `CustomPainter` —
no brand asset, unaffected by the icon artwork above.
