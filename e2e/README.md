# e2e — generate-and-verify matrix

`run_matrix.sh` generates a Chameleon app with each brick-flag combination
that matters (defaults, auto_route, biometrics, with-permissions,
home-widget, push-notifications, provider, riverpod) via the real
`chameleon` CLI, and gates on `flutter analyze` + `flutter test` +
`dart run custom_lint` against each. See the script's own header comment
for why `tool/checks.sh` is shown but not part of the pass/fail gate. The
home-widget variant gets one extra gate step — `flutter build apk
--debug` — since it's the only variant that generates native Kotlin
(`ChameleonHomeWidgetProvider.kt`), and `flutter analyze` never touches
non-Dart files.

```bash
bash e2e/run_matrix.sh
```

Requires `mason_cli`, `very_good_cli`, and Flutter/Dart (via `fvm` or on
PATH) already installed — same as `chameleon doctor` checks for. This repo
is public, and generated apps resolve `chameleon_ui`/`chameleon_core`/
`chameleon_lints` via real `git:` tag refs against it, so no git auth is
needed by anyone to run this — a plain `git clone`/`pub get` already has
everything it needs. Generated projects can go anywhere (created as
siblings of this toolchain repo by default, no sibling requirement) and
are deleted automatically on success; a failing variant is left in place
for inspection.

Runs in CI on every push/PR via `.github/workflows/ci.yml`'s `e2e` job.
