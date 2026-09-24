<p align="center">
  <img src=".github/assets/icon.png" alt="Chameleon" width="160" />
</p>

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
| staging     | gold                      |
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
chameleon create my_app
```

Run this from wherever you want the app created. The generated project
depends on `chameleon_ui`/`chameleon_core` by pinned `git:` ref against this
public repo, so there's no sibling-directory requirement and no private-repo
authentication to set up.

`chameleon create --help` lists every flag (state management,
router (`go_router`/`auto_route`), biometrics, permissions, a home screen
widget, fvm override, and the install/codegen/verify/git steps, each
individually skippable). The
command runs `very_good create` (or plain `flutter create` if
`very_good_cli` isn't installed), overlays the brick, resolves dependencies,
and — unless `--no-verify` is passed — refuses to call the project done
until `flutter analyze`, `flutter test`, and `dart run custom_lint`
(`chameleon_lints`' rules) are all clean.

Generated apps resolve iOS/macOS dependencies via **Swift Package Manager**
(Flutter 3.44's default) with CocoaPods as an automatic fallback for any
plugin that hasn't adopted SPM yet — nothing to configure either way,
including for `--permissions`: `permission_handler`'s SPM package
auto-detects enabled permissions straight from `Info.plist`.

## Adding a feature to a Chameleon app

From that app's own root (detected via the `.chameleon/template.yaml` marker
`create` leaves behind):

```bash
chameleon feature beneficiaries
```

Generates `lib/features/beneficiaries/` (entity, model, chopper api client,
isolate-wrapped datasource, repository, a bloc, a page) and matching tests,
then runs the same verification gate `create` does.

To add a second piece of state management inside a feature that already
exists (a filter, a form, a toggle — not a new repository call):

```bash
chameleon bloc filters --feature beneficiaries
chameleon bloc search --feature beneficiaries --cubit
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
and a CLI with `doctor` / `create` / `feature` / `bloc` / `update` /
`firebase verify` all ship today. `chameleon create` supports both
`go_router` and `auto_route`, and three state-management choices via
`--state`: `bloc` (default — covers both Bloc and Cubit, one package
either way; pick the shape per feature later with `chameleon bloc
--cubit`), `provider`, and `riverpod` — each exposes `chameleon_core`'s
`ConnectivityBloc` through that paradigm's own idiom
(`context.read`/`context.watch`/`ref.watch`); `--home-widget` generates a
fully working
Android home-screen widget plus iOS Swift starter source (the Widget
Extension target itself needs one manual Xcode step — see
`ios/HomeWidgetExtension/README.md` in a generated app); `--push-notifications`
wires `PushNotificationService` to `firebase_messaging` (Dart-side wiring is
automatic, a real Firebase project via `flutterfire configure` and the iOS
capabilities are one-time manual steps). Every generated app also gets a
registered deep-link URL scheme and a placeholder App Link host
automatically, no flag required, and follows the system light/dark theme
setting out of the box (`ChameleonTheme.light`/`.dark`, both built from the
same semantic-token layer). Every generated app is verified with
`flutter analyze` + `flutter test` +
`dart run custom_lint` (`chameleon_lints`' seven rules — see
[`packages/chameleon_lints/README.md`](packages/chameleon_lints/README.md)
for the full list) before `create`/`feature`/`bloc` report success.

A generate-and-verify e2e matrix (`e2e/run_matrix.sh`, see `e2e/README.md`)
generates a real app for each of eight flag combinations (defaults,
auto_route, biometrics, with-permissions, home-widget,
push-notifications, provider, riverpod) and gates on `flutter analyze` +
`flutter test` + `dart run custom_lint` for each; it runs in CI as the
`e2e` job in `.github/workflows/ci.yml`.

No Firebase (or any other vendor) dependency is required anywhere in this
toolchain by default — crash reporting, analytics, feature flags,
biometrics, and push notifications all ship with safe no-op defaults in
`chameleon_core`; wiring a real vendor is an opt-in step for a consuming
app, not something this toolchain assumes.

Every generated app's launcher icon defaults to a chameleon mascot
illustration, baked into the CLI per flavor (`cli/chameleon_cli/lib/src/icons/flavor_icon_sources.dart`):
a red "DEV" corner ribbon, a gold "STG" ribbon, and a plain icon for
production. The in-app loading indicator (`ChameleonMark`/`ChameleonSpinner`
in `chameleon_ui`) is a separate, still fully procedural `CustomPainter` —
no brand asset, unaffected by the icon artwork above.
