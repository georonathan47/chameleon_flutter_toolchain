# Chameleon Flutter Toolchain — v1 Build Plan

Full design rationale: see the approved plan (`dazzling-wiggling-tower.md` in this session's Claude plan history). Summary here for in-repo tracking.

## Phase 9 — v1.5: README logo + staging color reconciled to gold
- [x] Added the production icon (`.github/assets/icon.png`) to the top of README.md, per user request.
- [x] While pushing, found the user had pushed a direct commit (`147895f`) editing README's flavor table from "staging: blue" to "staging: gold" — doc-only, not a code change. Merged that commit, then closed the resulting doc/behavior gap: the *actual* runtime staging banner color (`bricks/chameleon_app/__brick__/lib/main_staging.dart`) was still `0xFF1E88E5` (blue), disagreeing with both the README and the STG icon artwork's gold ribbon.
- [x] Sampled the STG icon's actual ribbon color directly from the source PNG (`rgb(239,191,4)` = `0xFFEFBF04`) rather than guessing a "gold", and set `main_staging.dart`'s `bannerColor` to that exact value — the in-app banner and the launcher icon ribbon now use the identical color.
- [x] Re-bundled `chameleon_app`, verified with a real `chameleon flutter create` against the live repo: `flutter analyze`/`flutter test`/`dart run custom_lint` all clean, confirmed the generated `main_staging.dart` carries the new color.

## Phase 0 — Repo scaffolding
- [x] Pre-flight: confirm flutter/dart/mason/melos/gh available (Flutter 3.44.0, Dart 3.12.0 — matches reference repo)
- [x] Create root directory structure (packages/, bricks/, cli/, tasks/, .github/workflows/)
- [x] melos.yaml, mason.yaml, .fvmrc, .gitignore, LICENSE (MIT), root README.md
- [x] git init + initial commit
- [x] gh repo create --public + push (https://github.com/georonathan47/chameleon_flutter_toolchain)

## Phase 1 — `packages/chameleon_ui`
- [x] Port tokens (colors, typography, spacing, motion) from calbank_ui, renamed Cal*→Chameleon*
- [x] Drop per-flavor CalTypeface font-swap; single consistent type ramp
- [x] Port theme (ChameleonTheme.light)
- [x] Port components (glass surface, loading dialog, toast, FlavorBanner unchanged)
- [x] New ChameleonMark/ChameleonSpinner: procedural CustomPainter chameleon glyph (no image asset)
- [x] Port golden tests (alchemist) + token-integrity test, renamed
- [x] pubspec.yaml (chameleon_ui)

## Phase 2 — `packages/chameleon_core`
- [x] Port errors/, network/, auth/, storage/, di/, blocs/, utils/ (structure unchanged, vendor-agnostic already)
- [x] Rename CalbankCorePackageModule→ChameleonCorePackageModule, CalBankAppLogger→ChameleonLogger, CalCrashReporter→ChameleonCrashReporter, CalBankAppJsonConverter→ChameleonAppJsonConverter
- [x] Feature flags: FeatureFlags interface + NoopFeatureFlags default in core; FirebaseFeatureFlags skipped entirely for v1 (not ported — see review note), firebase_remote_config NOT a core dependency
- [x] pubspec.yaml (chameleon_core, no Firebase dep)
- [x] Port tests (42 tests passing; feature_flags_test.dart replaced with noop_feature_flags_test.dart since it tested FirebaseFeatureFlags directly)

## Phase 3 — Mason bricks
- [x] `bricks/chameleon_app`: brick.yaml (trimmed vars), pre_gen/post_gen hooks, __brick__ app skeleton
- [x] Flavor wiring: dev=red (0xFFD32F2F), stg=blue (0xFF1E88E5), prod=transparent (0x00000000); drop per-flavor typeface calls
- [x] Procedural icon generator (shared chameleon glyph geometry) + flavor accent, wired into AndroidIconGenerator/IosIconInstaller inputs (built in Phase 4 — CLI owns the icon subsystem, see its Review section)
- [x] `bricks/chameleon_feature`: port of calbank_feature, import paths updated
- [x] `bricks/chameleon_bloc`: port of calbank_bloc, import paths updated

## Phase 4 — `cli/chameleon_cli`
- [x] Commands: doctor, flutter create, flutter feature, flutter bloc (drop update, firebase verify)
- [x] Icon subsystem wired to procedural generator + flavor accent param
- [x] pubspec.yaml (chameleon_cli, executable `chameleon`)
- [x] Bundle all 3 bricks into lib/src/bundles/

## Verification
- [x] melos bootstrap && melos run analyze && melos run test (had to migrate melos.yaml → melos 8's pubspec.yaml-based workspace config — see Review)
- [x] chameleon doctor
- [x] chameleon flutter create demo_app (scratch dir) — analyze/test clean, verify flavor colors + icon
- [x] chameleon flutter feature sample / chameleon flutter bloc filters --feature sample (done during Phase 4's own verification)
- [ ] Visual check via iOS Simulator (not done — no simulator session requested; the generated app's `flutter analyze`/`flutter test` pass is the verification on record)

## Phase 6 — v1.2: `chameleon firebase verify`
- [x] `doctor.dart`: added `hasFirebaseTools` + warning-only `firebase-tools` check (not `hasFlutterfire` — that was only for the `--firebase-project-*` `flutter create` flow, which this toolchain doesn't have)
- [x] `firebase_command.dart`/`firebase_verify_command.dart`: ported verbatim in logic, renamed, registered in `command_runner.dart`
- [x] `firebase_verify_command_test.dart` ported (5 tests); `doctor_test.dart` updated for the new check
- [x] Real (unmocked) smoke test on this machine: `chameleon doctor` correctly detects real `firebase-tools 15.14.0`; `chameleon firebase verify some-test-project` correctly runs the real `firebase apps:list` command and correctly fails on a nonexistent project — no real Firebase project touched
- [x] README updated (new "Verifying a Firebase project" section, Status list)

## Phase 7 — v1.3: baked default app icons (user-supplied artwork)
- [x] User supplied three 512x512 PNGs (chameleon mascot + colored corner ribbon: red "DEV", gold "STG", plain for production) and asked for them to replace the procedural icon generator as the default app icon — a deliberate reversal of the earlier "no baked binary assets" design principle for icons specifically (the in-app `ChameleonMark`/`ChameleonSpinner` loading indicator is untouched and stays procedural).
- [x] New `lib/src/icons/flavor_icon_sources.dart` (generated via a one-off script, not hand-written): the three PNGs embedded as base64 constants, `// ignore_for_file: lines_longer_than_80_chars` since this is data not code. `FlavorIconInstaller.installAll` now sources from this instead of the deleted `ChameleonIconPainter`; added a `_upscaledForIos` step (512→1024, cubic) since iOS's Icon Composer layer wants 1024 and the source art is 512 — Android's legacy/adaptive/Play Store outputs already only ever downscale, so they take the raw 512 source unchanged.
- [x] Deleted `chameleon_icon_painter.dart` + its test (dead code); `flavor_icon_installer_test.dart` updated to assert against `FlavorIconSources` (512x512 sources, 1024x1024 installed iOS icon).
- [x] Verified: `dart analyze` clean (38/38 tests, matches `test(` count), plus a real `chameleon flutter create` generating the actual artwork into `android/`/`ios/` (confirmed by viewing an installed icon file directly, not just checking dimensions/file size).
- [x] README updated: dropped the now-false "no logos"/"zero brand assets" claims, documented the real icon source location and the STG ribbon being gold in the icon art (a cosmetic mismatch with the blue in-app banner color — noted, not treated as a bug, since it's the artwork as supplied).

## Phase 5 — v1.1: chameleon_lints, chameleon update, auto_route support
- [x] `packages/chameleon_lints`: port 3 rules (no_set_state, bloc_provider_value_for_di, no_function_type_in_injectable_ctor), lint codes renamed `chameleon_*`, standalone (not in melos/pub workspace — real `cli_util` version conflict with melos)
- [x] `chameleon update` CLI command: ported `Updater`/`UpdateCommand`, retargeted to the real public repo/ref-prefix/git-path, registered in `command_runner.dart`
- [x] `auto_route` support in `chameleon_app` brick: restored `router` var, whole-file mustache branch in `core/router/app_router.dart`, `auto_route: ^11.0.0`/`auto_route_generator: ^10.4.0` (pinned for analyzer-constraint compatibility with `chameleon_lints`)
- [x] `chameleon_lints` re-wired into the brick (`chameleon_lints_ref` var, pubspec dev dependency, `analysis_options.yaml` plugin, `tool/verify.sh`) and into the CLI's `verify()` gate (`dart run custom_lint`)
- [x] Re-bundled `chameleon_app`, verified both `go_router` (regression) and `auto_route` (new) paths end-to-end including the new custom_lint gate
- [x] README/CI updated: `chameleon_lints` gets its own CI step (not covered by `melos run` — see above), CLI test step uses `dart test -j 1` (a `dart test` default-concurrency quirk in this sandbox was found to silently drop suites)
- [x] Tagged `chameleon_lints-v0.1.0`, repinned the ref from `main`, re-bundled, re-verified, pushed

## Phase 8 — v1.4: generate-and-verify e2e matrix
- [x] `e2e/run_matrix.sh`: bundles `chameleon_app`, activates `chameleon_cli` from source, runs `chameleon flutter create` across 4 named flag combinations (defaults, cubit+auto_route, biometrics, with-permissions), shows `tool/checks.sh` informationally, gates on `flutter analyze && flutter test && dart run custom_lint`, deletes scratch dir on pass / leaves it on fail
- [x] `e2e/README.md`: usage + why `tool/checks.sh` isn't part of the gate; no private-repo/GITHUB_TOKEN language since this repo is public
- [x] `.github/workflows/ci.yml`: new `e2e` job, `needs: packages`, `runs-on: macos-latest` (so the biometrics/with-permissions variants' real `pod install` actually runs), no git-auth step
- [x] README Status section reworded — nothing left listed as deferred
- [x] Ran the real matrix end-to-end (see Review) — all 4 variants passed

## Review

### Phase 8 — v1.4: generate-and-verify e2e matrix (complete)

- Ported `run_matrix.sh`/`README.md` structure from the private reference
  toolchain's `e2e/`, retargeted to this toolchain's real flag surface
  (`--state bloc|cubit`, `--router go_router|auto_route`, `--biometrics`,
  `--permissions <list>` — confirmed by reading
  `cli/chameleon_cli/lib/src/commands/flutter_create_command.dart` directly
  rather than trusting the task's summary). No Firebase/crashlytics/
  security/inactivity concept exists in this toolchain, so none of the
  reference's flags for those carried over.
- **4 variants, matching the suggested shape exactly** (no deviation):
  `e2e_defaults` (no flags), `e2e_cubit_auto_route` (`--state cubit --router
  auto_route`, both non-default choices at once), `e2e_biometrics`
  (`--biometrics`), `e2e_with_permissions` (`--permissions
  camera,notification`).
- Header comment rewritten: dropped the reference's Firebase/security
  rationale for why `tool/checks.sh` isn't part of the gate, replaced with
  the real reason here — `core_module.dart`'s own
  `TODO(chameleon): AuthInterceptor.configureNoAuthPaths...` placeholder,
  documented in `docs/guardrails.md`/`tasks/lessons.md` as intentional
  until a real backend exists.
- `e2e/README.md`: dropped the reference's "private repo, needs read
  access" paragraph and its CI `GITHUB_TOKEN` git-auth mention entirely
  (this repo is public) — replaced with a short note that generated apps
  resolve `chameleon_ui`/`chameleon_core`/`chameleon_lints` via real public
  `git:` tag refs, no auth needed by anyone.
- `.github/workflows/ci.yml`: new `e2e` job, `needs: packages`, `runs-on:
  macos-latest` (free for a public repo, and lets the with-permissions
  variant's real `pod install` — guarded on `Platform.isMacOS` in
  `flutter_create_command.dart` — actually run instead of silently
  skipping). Same `subosito/flutter-action@v2` + `flutter-version-file:
  .fvmrc` pattern as the existing `packages` job. No git-auth step added —
  unlike the reference, this repo needs none.
- **Real matrix run** (not simulated): `bash e2e/run_matrix.sh` against the
  actual public, already-tagged repo (`chameleon_ui-v0.1.0`/
  `chameleon_core-v0.1.0`/`chameleon_lints-v0.1.0`), no local path
  overrides. All 4 variants generated cleanly, and all 4 passed the real
  gate (`flutter analyze`: 0 issues each; `flutter test`: 9/9 each; `dart
  run custom_lint`: 0 issues each). Final line: `All 4 e2e variants
  passed.`, exit code 0. `tool/checks.sh`'s informational output matched
  the documented, non-gating expectations exactly for every variant: the
  `TODO(chameleon)` leftover-TODO failure (present in all 4, since it's
  unconditional), the unconditional deep-link checks (`CFBundleURLTypes`/
  `autoVerify` — no app wires these until it actually needs a URL scheme),
  and, for `e2e_biometrics` only, the two biometrics-conditional failures
  (`NSFaceIDUsageDescription`/`USE_BIOMETRIC`) — both explicitly documented
  as manual developer follow-up steps in the `--biometrics` flag's own
  help text in `flutter_create_command.dart`, not something the CLI
  auto-wires. **No real regression surfaced and no bug was found in the
  brick or CLI** — nothing under `packages/`, `bricks/`, or
  `cli/chameleon_cli/lib/` needed touching.
- Confirmed the real `pod install` step ran (not skipped) for
  `e2e_with_permissions` by grepping the run's own output for it, proving
  the `macos-latest` CI runner choice is actually exercising that code
  path rather than the `Platform.isMacOS` guard silently no-op'ing.
- Confirmed no scratch directories were left behind in
  `/Users/gosafo-osei/Desktop/builds/` (the script's own
  `SCRATCH_ROOT="$(dirname "$TOOLCHAIN_ROOT")"`) after the run — all 4
  passed, so the script's own delete-on-pass path deleted each one; `ls`
  confirmed directly rather than assumed.
- `git status` after the run showed the `mason bundle` step in
  `run_matrix.sh` (which re-bundles `chameleon_app` into
  `cli/chameleon_cli/lib/src/bundles/` before activating the CLI) produced
  byte-identical output to what's already committed — no incidental diff
  under `cli/chameleon_cli/lib/`.

### Publishing (complete)

- Fixed a melos-version mismatch: `melos.yaml` (the format the private
  reference repo uses) is silently ignored by melos 8.7.0, the version
  `dart pub global activate melos` installs today — melos 8 moved to
  Dart-native pub workspaces, config lives in the root `pubspec.yaml`
  under `workspace:`/`resolution: workspace` per member package, and
  scripts live under a `melos:` key in that same root `pubspec.yaml`.
  Added a root `pubspec.yaml` with both, deleted the now-dead
  `melos.yaml`. `melos bootstrap`, `melos run analyze` (0 issues, both
  packages), and `melos run test` (all passing; `chameleon_ui`'s
  google_fonts network-fetch warnings in this sandbox are expected, see
  its own Phase 1 review note) all work from a clean clone now.
- Repo-wide grep for leftover `calbank`/`CalBank` found only legitimate
  lineage references (a CHANGELOG "forked from" note, a code comment
  naming the source CLI, and this file's own build log) — zero actual
  leftover branding.
- Pushed to `https://github.com/georonathan47/chameleon_flutter_toolchain`
  (public), then tagged `chameleon_ui-v0.1.0`/`chameleon_core-v0.1.0` and
  updated `chameleon_app/brick.yaml`'s ref-var defaults plus the CLI's
  hardcoded copy (`flutter_create_command.dart`) to point at those real
  tags instead of `main`, re-bundled, re-verified (28/28 CLI tests still
  passing), committed and pushed as a follow-up commit.
- **Final proof**: activated `chameleon_cli` globally from this checkout,
  then ran `chameleon doctor` and `chameleon flutter create` in a scratch
  directory with **no local path override** — `chameleon_ui`/
  `chameleon_core` resolved via their real `git:` tag refs against the
  now-public, now-tagged GitHub repo, with no manual workaround needed.
  The generated app's `flutter analyze` (0 issues) and `flutter test`
  (9/9 passing) confirm the whole pipeline works end-to-end for a
  genuinely fresh user, not just inside this development checkout.

### Phase 1 — `packages/chameleon_ui` (complete)

- `flutter analyze`: clean, no issues. `flutter test`: 15/15 passing (including
  the golden gallery test).
- Renames applied throughout: `CalTheme`→`ChameleonTheme`, `CalColors`→
  `ChameleonColors`, `CalSemanticColors`→`ChameleonSemanticColors`,
  `CalTypography`→`ChameleonTypography`, `CalSpacing`→`ChameleonSpacing`,
  `CalRadius`→`ChameleonRadius`, `CalToast*`→`ChameleonToast*`. `FlavorBanner`,
  `DismissKeyboard`, `ActivityDetector`, `StringX` kept their names unchanged
  (already generic) — only their internal `CalTypography` references were
  repointed.
- **`CalTypeface`'s per-flavor font swap deleted entirely** — `chameleon_typography.dart`
  now builds its whole ramp from one fixed `GoogleFonts.inter` call, no
  mutable `.use()` state.
- **Branded loader replaced**: `CalBankSpinner`/`CalbankMark` deleted. New
  `ChameleonMark` (`lib/src/components/loader/chameleon_mark.dart`) is an
  original `CustomPainter`-drawn flat chameleon silhouette (oval body,
  two-Bézier spiral tail, rounded-triangle head, contrast-aware eye, two leg
  strokes) — no image/SVG asset. `ChameleonSpinner` wraps it in a rotation +
  scale-pulse animation. `LoaderCubit`/`LoaderState` ported as
  `ChameleonLoaderCubit`/`ChameleonLoaderState` (they were already
  visual-agnostic). The old composite `CalBankSpinnerWidget` was dropped as
  redundant since `ChameleonSpinner` already embeds the mark itself.
- Toast SVG icons (6 generic status glyphs) copied as-is — not brand marks.
- One golden-image caveat: the checked-in goldens
  (`test/theme/goldens/{ci,macos}/chameleon_theme_gallery.png`) were rendered
  with `flutter test --update-goldens` in a sandbox with no network access,
  so `google_fonts` fell back to the platform default font rather than
  fetching real Inter. The fallback rendering is deterministic so the test
  passes, but these two PNGs should be regenerated once with real network
  access so the golden actually reflects Inter.

### Phase 2 — `packages/chameleon_core` (complete)

- `flutter analyze`: clean, 0 issues. `flutter test`: 42/42 passing.
- `firebase_remote_config` does not appear anywhere in `pubspec.yaml`,
  `pubspec.lock`, or the generated DI module — verified by grep.
- **FirebaseFeatureFlags**: skipped entirely rather than ported-but-unwired.
  The task allowed either; skipping is simpler and avoids build_runner's
  injectable scanner picking up a `@LazySingleton(as: FeatureFlags)`-annotated
  class living in `lib/` regardless of barrel-file exports, which would have
  reintroduced a Firebase import into generated, committed code. `FeatureFlags`
  + `NoopFeatureFlags` ship instead; a consuming app implements `FeatureFlags`
  itself for a real backend.
- **NoopFeatureFlags** is deliberately *not* `@injectable`/`@LazySingleton`,
  mirroring `NoopBiometricAuthenticator` exactly (per the task's instruction
  to mirror that file's pattern) — binding is left to the consuming app's own
  DI setup, same as biometrics, rather than auto-registered by this package.
- **Judgment call beyond the explicit rename list**: `CalBankAppJsonConverter`
  (in `chopper_client_factory.dart`) was also CalBank-branded but wasn't in
  the task's rename list. Renamed to `ChameleonAppJsonConverter` for
  consistency with the "ZERO CalBank branding" goal — it's an internal type
  with no test coverage by name, so the rename is zero-risk.
- `CalCrashReporter` → `ChameleonCrashReporter` (chose the Chameleon-prefixed
  name over a bare `CrashReporter` for naming consistency with
  `ChameleonLogger`); file renamed `cal_crash_reporter.dart` →
  `chameleon_crash_reporter.dart`.
- Fixed 3 analyzer lints not present in the source package: a dangling
  `[NoopFeatureFlags]` doc reference (unresolvable without an import — swapped
  to a plain code-font mention), a `0.0` double literal flagged by
  `prefer_int_literals` (→ `0`), and `pubspec.yaml` dependency ordering
  (`flutter:` must sit alphabetically, not first, under
  `sort_pub_dependencies`).
- `injectable_generator` prints an expected warning about `TokenStorage`,
  `SessionCache`, `Connectivity`, and `FlutterSecureStorage` being
  unregistered in this micropackage — this matches the original
  `calbank_core` module exactly; those are bound by the consuming app's own
  DI setup, not this package.

### Phase 3 — `bricks/chameleon_feature` and `bricks/chameleon_bloc` (complete)

- Both bricks are structurally identical 1:1 ports of `calbank_feature` and
  `calbank_bloc` — every file, directory, and mustache filename (including
  `chameleon_bloc`'s literal `{{#use_bloc}}...dart{{/use_bloc}}` /
  `{{#use_cubit}}...dart{{/use_cubit}}` conditional filenames) carried over
  unchanged except for the rename set below. No architecture, hook logic, or
  test-skeleton shape was altered.
- **Renames applied**: `package:calbank_core/calbank_core.dart` →
  `package:chameleon_core/chameleon_core.dart` everywhere it appeared
  (`domain/repositories/*_repository.dart`, `domain/usecases/get_*.dart`,
  `data/datasources/*_remote_data_source.dart`,
  `data/repositories/*_repository_impl.dart`, `di/*_module.dart`,
  `presentation/bloc/*_state.dart`, and the matching test files);
  `brick.yaml` description prose "CalBank app" → "Chameleon app" in both
  bricks; hook error/log strings ("calbank_feature"/"calbank_bloc" brick
  names, "calbank flutter feature" CLI hint) → "chameleon_feature" /
  "chameleon_bloc" / "chameleon flutter feature".
- **No `CalBankAppLogger`/`Cal*` symbol references exist anywhere in either
  source brick's generated code** — verified by grepping both
  `calbank_feature` and `calbank_bloc` in full before porting; the only
  CalBank-branded text in either brick was the two `brick.yaml` description
  strings. So the "`CalBankAppLogger`→`ChameleonLogger`" rename called out in
  the task's brief didn't end up applying to any actual file — there was
  nothing to rename beyond the package import.
- `package:calbank_ui/calbank_ui.dart` is likewise never referenced by
  either brick's generated code (no page or widget in this scaffolding
  imports `chameleon_ui`), so no `calbank_ui`→`chameleon_ui` rename was
  needed either — noted since the task anticipated it might be present.
- Verified every `chameleon_core` symbol these bricks generate against
  (`Failure`, `NetworkException`, `ServerException`, `ApiCall`,
  `createChopperClient`, `runApiCall`, `initIsolateBinaryMessenger`,
  `rootIsolateToken`, `FlavorConfig`, `AuthInterceptor`,
  `IdempotencyInterceptor`, `RetryInterceptor`) exists in the real,
  finished `packages/chameleon_core` with identical names and signatures —
  read `errors/failures.dart`, `errors/exceptions.dart`,
  `network/chopper_client_factory.dart`, `utils/isolate_helper.dart`, and
  `config/flavor_config.dart` directly rather than assuming parity.
- **Smoke test**: built a throwaway `/tmp/chameleon_brick_target` (deleted
  after verification) with stand-in `core/network/api_envelope.dart`
  (`ApiEnvelope<T>`, copied from `calbank_app`'s brick, package rename
  only), `core/errors/app_failures.dart`, a minimal `core/config/env.dart`
  (hand-written, hardcoded URLs — a stand-in for the real app's
  `envied`-backed one, since the smoke target doesn't need real per-flavor
  secrets), `core/di/injection_container.dart` wired to
  `ChameleonCorePackageModule`, and a `pubspec.yaml` with `path:`
  dependencies on the real `packages/chameleon_core` and `chameleon_ui`.
  Ran `mason make chameleon_feature --feature_name widgets` +
  `mason make chameleon_bloc --feature_name widgets --bloc_name filters`
  (bloc) and a second `--feature_name reports --bloc_name sorting --cubit
  true` (cubit path), then `flutter pub get` → `dart run build_runner
  build` → `flutter analyze` → `flutter test` for each. **Result: clean on
  the first generation for `chameleon_feature`** (0 analyzer issues, 8/8
  tests) and **`chameleon_bloc`'s bloc path** — no template fixes needed at
  all. The only real fix was in my own invocation, not the brick: `mason
  make chameleon_bloc`'s generated test file imports
  `package:{{project_name.snakeCase()}}/...`, but `chameleon_bloc`'s
  `brick.yaml` (matching `calbank_bloc` exactly) never declares
  `project_name` as a var — it's expected to arrive as an extra key in the
  vars map the CLI supplies at generation time, same as the source brick.
  Mason CLI's boolean flags don't support `--cubit`/`--no-cubit` negation
  from the shell, so `cubit` needed a `-c config.json` file too. Final
  state: `flutter analyze` 0 issues and `flutter test` 18/18 passing across
  both a generated feature+bloc and a generated feature+cubit.
- Final file trees (both match the source bricks file-for-file, no added or
  removed files): `bricks/chameleon_feature/{brick.yaml, hooks/{pre_gen.dart,
  post_gen.dart, pubspec.yaml}, __brick__/lib/features/{{feature_name.snakeCase()}}/
  {data/{datasources,models,repositories,services}, di, domain/{entities,
  repositories,usecases}, presentation/{bloc,pages,widgets}, <feature>.dart},
  __brick__/test/features/{{feature_name.snakeCase()}}/{data,domain,
  presentation}}`; `bricks/chameleon_bloc/{brick.yaml, hooks/{pre_gen.dart,
  post_gen.dart, pubspec.yaml}, __brick__/lib/features/{{feature_name.snakeCase()}}/
  presentation/bloc/{state.dart, conditional bloc/event/cubit filenames},
  __brick__/test/features/{{feature_name.snakeCase()}}/presentation/
  {conditional bloc/cubit test filenames}}`.

### Phase 3 — `bricks/chameleon_app` (complete)

- Read the entire source brick (`calbank_app`'s `brick.yaml`,
  `hooks/{pre_gen,post_gen}.dart`, `hooks/pubspec.yaml`, and every file under
  `__brick__/`) plus the real, finished `packages/chameleon_ui` and
  `packages/chameleon_core` barrels and their key implementation files
  (`chopper_client_factory.dart`, `session_cache.dart`,
  `auth_interceptor.dart`, `token_storage.dart`, `feature_flags.dart`,
  `noop_feature_flags.dart`, `micropackage_init.module.dart`,
  `flavor_config.dart`, `logging_service.dart`, `chameleon_theme.dart`,
  `flavor_banner.dart`, `dismiss_keyboard.dart`, `toast.dart`) before writing
  any template, so the DI wiring and imports compile against real signatures
  rather than assumed ones.
- **Removed entirely (not flag-gated) vs. the source**: all Firebase
  (`firebase_core`/`firebase_remote_config`/`firebase_crashlytics`/
  `firebase_analytics`, `firebase_options_*.dart`, `DefaultFirebaseOptions`,
  `Firebase.initializeApp()`), Clarity (`clarity_flutter`, the
  `analytics_provider` var), `safe_device`/`InsecureDeviceApp`/
  `security_check_enabled`, the `InactivityService` watchdog +
  `_InactivityBoundary` + `use_inactivity` var, and the `router`
  enum/auto_route rejection path (go_router is now unconditional). Brick
  vars trimmed from 12 to 7: `project_name`, `org_name` (default changed
  `net.calbank` → `com.example`), `description`, `state_management`,
  `use_biometrics`, `permissions`, `chameleon_ui_ref`/`chameleon_core_ref`
  (both default to `main`, not a version tag — no tags exist yet; doc
  comments in `brick.yaml` say to bump once this repo cuts its first
  release). Dropped `use_crashlytics`, `use_inactivity`, `router`,
  `analytics_provider`, `calbank_lints_ref` vars entirely, and their
  `is_analytics_firebase`/`is_analytics_clarity`/`use_go_router` derived
  vars in `pre_gen.dart`.
- `bootstrap.dart` simplified to the exact shape specified: `ensureInitialized`
  → `Bloc.observer` → `FlutterError.onError` → `configureDependencies()` →
  `getIt<FeatureFlags>().initialize()` → `runApp(builder())`, inside the same
  `runZonedGuarded`. No `FirebaseOptions` parameter — `bootstrap` now takes
  only `Widget Function() builder`.
- `main_*.dart` drop the `CalTypography.use(...)` call entirely (verified
  `ChameleonTypography` has no such method — it's a single fixed Inter ramp,
  confirmed by reading `chameleon_typography.dart`) and the `firebase_options`
  import/argument. Flavor colors: dev `0xFFD32F2F` (unchanged), stg
  `0xFF1E88E5` (blue, changed from source's orange), prod `0x00000000`
  (unchanged).
- `core_module.dart`: removed `firebase_remote_config` import and the
  `FirebaseRemoteConfig` binding; added
  `@lazySingleton FeatureFlags get featureFlags => const NoopFeatureFlags();`
  — the same real-singleton-either-way pattern the source already uses for
  `BiometricAuthenticator`/`NoopBiometricAuthenticator`, so a future
  feature's constructor-injected `FeatureFlags` dependency doesn't change
  shape later. `SessionCache`→`NoopSessionCache`,
  `Connectivity`/`SharedPreferences`/`FlutterSecureStorage`/`TokenStorage`,
  and the `use_biometrics`-conditional `BiometricAuthenticator` binding all
  ported verbatim in spirit.
- `app/view/app.dart`: `FlavorBanner` wiring, `DismissKeyboard`, and
  `ChameleonToastHost` (renamed from `CalToastHost`) kept exactly as in the
  source, applied directly with no `_InactivityBoundary` wrapper (that type
  no longer exists).
- Faithfully ported (rename-only): `hooks/pre_gen.dart`'s project-name
  validation + permission-macro/usage-description derivation,
  `hooks/post_gen.dart`'s counter-demo deletion + `.env` seeding + `chmod +x`
  + `dart format` + provenance write (path changed
  `.calbank/template.yaml` → `.chameleon/template.yaml`, keys
  `chameleon_app_brick`/`chameleon_ui_ref`/`chameleon_core_ref`),
  `app_failures.dart`, `api_envelope.dart`, `app_router.dart`,
  `route_guard.dart`, `env.dart`, `injection_container.dart`
  (`CalbankCorePackageModule`→`ChameleonCorePackageModule`), `.env.example`,
  `analysis_options.yaml` (also dropped the `plugins: [custom_lint]` line —
  custom_lint is deferred, not part of v1), `ios/Podfile`
  (`calbank_permission_macros`→`chameleon_permission_macros`),
  `.github/workflows/ci.yml`, `.gitignore`, `docs/*`, `tasks/lessons.md`
  (all 16 numbered lessons carried over renamed only — none of them
  actually referenced Firebase/inactivity/security by content, so nothing
  needed dropping beyond the section header), `tasks/todo.md`,
  `.claude/CLAUDE.md`, `test/helpers/*`, `test/app/view/app_test.dart`,
  `test/core/router/route_guard_test.dart`,
  `test/core/di/injection_smoke_test.dart` (added `getIt<FeatureFlags>()`
  and `getIt<BiometricAuthenticator>()` resolution assertions in place of
  the dropped `InactivityService` one), `tool/checks.sh` (kept all grep
  guardrails, renamed strings only), `tool/verify.sh` (removed the
  `dart run custom_lint` step — deferred to a follow-up phase per the task).
  Dropped `core/services/inactivity_service.dart` + its test,
  `core/crash/`, `core/analytics/`, and both `firebase_options_*.dart` files
  and the `InactivityService` entries in `test/helpers/di_harness.dart` and
  `test/app/view/app_test.dart`.
- **`path_provider` judgment call**: dropped from `pubspec.yaml`. It appears
  only in `chameleon_core`'s `pubspec.lock` as a *transitive* dependency (not
  declared directly in `chameleon_core`'s own `pubspec.yaml`), and grepping
  every kept file in this brick found no direct `path_provider` usage — the
  source brick's only plausible use case for it (log-file rotation for a
  crash/logging service) isn't implemented that way in the real
  `chameleon_core`. Not declaring it keeps the generated app's dependency
  list minimal; add it back in a future feature if one actually needs it.
- **`FeatureFlags.initialize()` call shape**: `chameleon_core`'s real
  signature is `Future<void> initialize({Map<String, Object> defaults =
  const {}})`. Called with no arguments in `bootstrap.dart` (relying on the
  default `{}`) per the task's own guidance — `NoopFeatureFlags.initialize`
  is a no-op regardless, and there are no app-specific default flags yet to
  seed.
- **Mason CLI non-interactive invocation**: `mason make chameleon_app -c
  vars.json -o <dir> --on-conflict overwrite`, with a plain JSON vars file
  (`array`/`boolean` vars pass as native JSON types; CLI `--flag` syntax also
  works for scalars but a JSON config file was simplest for the `permissions`
  array).
- **Verification**: registered the brick locally (`mason get` at the repo
  root picks up the `bricks/chameleon_app` entry already in `mason.yaml`),
  then ran `mason make chameleon_app` twice into scratch dirs — once with
  every flag at its default (bloc, no biometrics, no permissions: 35 files)
  and once with every optional branch flipped on (cubit, `use_biometrics:
  true`, `permissions: [camera, location, notification]`: 36 files, confirms
  the biometric adapter's mustache-conditional filename resolves and the
  Podfile/checks.sh biometric blocks render). Both scratch apps got a
  `pubspec_overrides.yaml` pointing `chameleon_ui`/`chameleon_core` at real
  `path:` deps (the git refs don't resolve — this repo isn't pushed yet, as
  expected and noted in the task). For **both** variants: `flutter pub get`
  succeeded, `dart run build_runner build` generated all codegen output with
  no errors (the `freezed`/`json_serializable`/`injectable`/`chopper`/
  `envied` builders all completed clean), `flutter analyze` reported **0
  issues**, `flutter test` passed **9/9** tests, and
  `dart format --set-exit-if-changed lib test` reported 0 files changed
  (the post_gen hook's own `dart format` pass already left the tree
  canonical). No template bugs were found or fixed — both variants were
  clean on the first generation. `tool/checks.sh` exits 1 on a fresh app in
  both variants, as intended and documented in `docs/guardrails.md`/
  `tasks/lessons.md` #4: `core_module.dart`'s own
  `TODO(chameleon): AuthInterceptor.configureNoAuthPaths...` comment trips
  the leftover-TODO grep on purpose, until a real backend contract exists —
  this is inherited, unmodified behavior from the source brick, not a
  regression. Both scratch directories were deleted after verification.
- Final file tree: `bricks/chameleon_app/{brick.yaml, hooks/{pre_gen.dart,
  post_gen.dart, pubspec.yaml}, __brick__/{.claude/CLAUDE.md, .env.example,
  .github/workflows/ci.yml, .gitignore, analysis_options.yaml,
  assets/{images,svg,videos}/.gitkeep, docs/{architecture,codegen,
  guardrails}.md, ios/Podfile, lib/{app/{app.dart,view/app.dart},
  bootstrap.dart, main_development.dart, main_staging.dart,
  main_production.dart, core/{auth/{{#use_biometrics}}
  local_auth_biometric_authenticator.dart{{/use_biometrics}},
  config/env.dart, di/{core_module.dart,injection_container.dart},
  errors/app_failures.dart, network/api_envelope.dart,
  router/{app_router.dart,route_guard.dart}}}, pubspec.yaml,
  tasks/{lessons.md,todo.md},
  test/{app/view/app_test.dart, core/{di/injection_smoke_test.dart,
  router/route_guard_test.dart}, helpers/{di_harness.dart,pump_app.dart}},
  tool/{checks.sh,verify.sh}}}`. No brand assets shipped under
  `__brick__/assets/` beyond the three `.gitkeep` placeholders (verified).

### Phase 4 — `cli/chameleon_cli` (complete)

- Read the entire source `cli/calbank_cli` (every file under `lib/src/`,
  `bin/`, `test/`) plus all three finished bricks' `brick.yaml` files before
  writing anything, per the task. `chameleon_app`'s `brick.yaml` has exactly
  the 7 vars the task described (`project_name`, `org_name` default
  `com.example`, `description`, `state_management`, `use_biometrics`,
  `permissions`, `chameleon_ui_ref`/`chameleon_core_ref` both default
  `main`) — confirmed by reading the file directly rather than trusting the
  task's summary.
- **Scope cut exactly as specified**: only `doctor`, `flutter create`,
  `flutter feature`, `flutter bloc` exist. `updater.dart`,
  `commands/update_command.dart`, `commands/firebase_command.dart`,
  `commands/firebase_verify_command.dart`, and their test files were never
  ported. `command_runner.dart` registers only `DoctorCommand` and
  `FlutterCommand`. `Doctor`/`DoctorReport` dropped `hasFlutterfire`/
  `hasFirebaseTools` and the `flutterfire`/`firebase-tools` `ToolCheck`s
  entirely — `chameleon doctor` now reports exactly 5 checks (Flutter, Dart,
  git, very_good_cli, CocoaPods). `PipelineSteps.verify()` dropped the third
  `dart run custom_lint` gate and `lintProgress` — `chameleon_lints` doesn't
  exist in this toolchain, so `verify()` only runs `flutter analyze` +
  `flutter test`.
- **`flutter_create_command.dart`**: dropped `--crashlytics`,
  `--inactivity`, `--analytics-provider`, `--firebase-project-dev/-stg/
  -prod`, and `--router` entirely (go_router is unconditional — the source
  brick's `router` var doesn't exist in `chameleon_app`'s `brick.yaml`
  either). `--org` now defaults to `com.example`, `--desc` to `'A Chameleon
  Flutter application.'`. The whole "install flutterfire_cli on demand" /
  "Configuring Firebase" block is gone — there was nothing left needing it.
  The `vars` map passed to `MasonGenerator` is now exactly the 7 keys
  `chameleon_app`'s brick declares (no `router`/`use_crashlytics`/
  `use_inactivity`/`analytics_provider`/`calbank_lints_ref` keys survive).
  `chameleon_ui_ref`/`chameleon_core_ref` are hardcoded to `'main'` in the
  vars map with the same "kept in sync by hand with brick.yaml's own
  defaults" comment the source used, plus a `TODO(chameleon)` noting these
  should become real tags (e.g. `chameleon_ui-v0.1.0`) once this repo cuts
  its first tagged release — no tags exist yet, so `main` is the only
  correct value today. Success message: "CalBank" → "Chameleon" everywhere,
  "Add Firebase configs" next-step line removed (nothing to configure).
  Imports the bundled `chameleonAppBundle` from
  `lib/src/bundles/chameleon_app_bundle.dart`, not a git/path reference.
- **`flutter_feature_command.dart`/`flutter_bloc_command.dart`**: ported
  essentially verbatim — same snake_case/reserved-word validation, same
  "already exists" guards, same codegen/verify/fvm flag handling — with the
  provenance-marker path changed to `.chameleon/template.yaml` (confirmed
  the brick's own `post_gen.dart` writes exactly that path, at
  `hooks/post_gen.dart:66`) and all CalBank→Chameleon renames in error/log
  text. `flutter_bloc_command.dart` keeps `--feature` (mandatory) and
  `--cubit` exactly as source.
- **Icons — the interesting part**: `android_icon_generator.dart` and
  `ios_icon_installer.dart` ported unchanged except doc-comment renames
  ("CalBank's default" → "Chameleon's default", etc.) — both are generic
  raster-manipulation logic keyed only on `Uint8List sourceBytes` per
  flavor, exactly as the task predicted. `flavor_icon_sources.dart` (the
  463KB baked-PNG file) was **not ported** — replaced by
  `lib/src/icons/chameleon_icon_painter.dart`, a new file that procedurally
  draws an original chameleon glyph using `package:image` v4.10's real
  drawing primitives (verified each one's actual signature by reading
  `package:image`'s source under `~/.pub-cache` before using it, per the
  task's explicit warning not to invent API that doesn't exist):
  `img.fillPolygon` for the body (a rotated ellipse approximated by 48
  sampled points) and the head (a 4-vertex blunt/rounded triangle),
  `img.fillCircle` for the eye's sclera-and-pupil pair, and `img.drawLine`
  for the tail. `package:image` has no bezier/arc path API, so the tail's
  spiral is built by sampling a polar curve — radius shrinking linearly as
  the angle sweeps through 1.6 turns over 120 steps — into a point cloud and
  connecting consecutive samples with short `drawLine` segments whose
  thickness itself tapers from `0.05×size` down to about `0.0175×size` as
  the spiral winds inward, the same "flatten the curve into straight
  segments" technique real vector renderers use internally. All layout
  fractions (body center/radii/rotation, tail center/start-radius/turns,
  head vertices, eye center/radii) are pulled into a
  `ChameleonIconGeometry` class of named `double` constants rather than
  inlined magic numbers, specifically so the test file could sample exact
  pixel coordinates instead of guessing.
- **Judgment calls on resolution/colors** (all documented in doc comments
  at the point of use, per the task's ask): canvas size is **1024**, not the
  source's 1548 — read `flavor_icon_sources.dart`'s own header comment,
  which confirms 1548 was an arbitrary designer PNG-export dimension with
  no downstream significance, so there was nothing to match; 1024 is a
  clean size at least as large as anything either platform's installer
  actually asks for (Android's 512 Play Store icon, iOS's Icon Composer
  bundle), so every `copyResize` call in the existing (unchanged) installers
  only ever shrinks. Ink color (the glyph itself, every flavor) is a
  literal `0xFF2E3A33` dark green-charcoal — independently chosen, not
  imported, since this is a pure-Dart package with no access to
  `chameleon_ui`'s Flutter-only `ChameleonColors`; doc comment notes it
  sits in the same neighborhood as `chameleon_ui`'s `grey900`/`grey860`
  neutrals without claiming to be copied from them (verified those actual
  hex values by reading `packages/chameleon_ui/lib/src/tokens/
  chameleon_colors.dart` directly). Dev background `0xFFD32F2F` and staging
  background `0xFF1E88E5` were both copied verbatim from
  `FlavorConfig.initialize(bannerColor: ...)` in
  `bricks/chameleon_app/__brick__/lib/main_development.dart` and
  `main_staging.dart` respectively (read both files to confirm the literal
  rather than assuming), with a doc comment cross-referencing each source
  file. Production background is `0xFFF8F9FA`, the same neutral off-white
  `AndroidIconGenerator._backgroundColorXml` already hardcodes for the
  Android adaptive-icon background on every flavor — chosen as the closest
  honest equivalent to "no banner color," since an app icon (unlike a debug
  banner) cannot literally be transparent on either app store.
- **Bundling**: ran `mason bundle bricks/{chameleon_app,chameleon_feature,
  chameleon_bloc} -t dart -o cli/chameleon_cli/lib/src/bundles/` for real
  (not simulated) and confirmed the exported identifiers by grepping the
  generated files: `chameleonAppBundle`, `chameleonFeatureBundle`,
  `chameleonBlocBundle` — matches the source's `calbankAppBundle`-style
  naming exactly, so no guessing was needed for the commands' import names.
- **`pascal_case.dart`/`process_runner.dart`**: ported unchanged — neither
  contained any CalBank-specific reference. `version.dart` updated to
  `0.1.0` (was a hardcoded `1.1.0` in source, now matches this package's own
  `pubspec.yaml`).
- **Tests**: ported `doctor_command_test.dart`, `doctor_test.dart` (the
  `Doctor` class's own test, separate from the command test),
  `flutter_bloc_command_test.dart` (renamed `.calbank`→`.chameleon` in its
  fixture setup), `test/support/fake_process_runner.dart` verbatim, and
  `test/icons/{android_icon_generator_test.dart,ios_icon_installer_test.dart}`
  verbatim (both test the generic resize/bundle logic, unaffected by the
  source-artwork swap). `flavor_icon_installer_test.dart` was rewritten to
  assert against `ChameleonIconPainter` instead of the deleted
  `FlavorIconSources`, keeping the same "installs all three flavors on both
  platforms" structural assertions. `flutter_create_command_test.dart` was
  rewritten to drop every Firebase-specific test (source had 4:
  auto-install flutterfire_cli, per-flavor `flutterfire configure`,
  no-project-id skip) since none of that code path exists in v1 — the 4
  remaining tests (invalid name, missing name, non-empty output dir,
  doctor-unusable) were kept verbatim. New
  `test/icons/chameleon_icon_painter_test.dart` added: asserts the PNG
  decodes back to the requested size, all four corners sample pure
  background color, the body-center fraction samples ink, the eye's pupil
  center samples ink while a point just outside the pupil but inside the
  sclera radius samples background, and each of the three flavor helpers
  produces its own distinct background color — all sampled at exact pixel
  coordinates computed from `ChameleonIconGeometry`'s constants, not
  guessed. No `update_command_test.dart`/`firebase_verify_command_test.dart`
  /`updater_test.dart` — those commands/classes don't exist in v1.
- **Verification results**: `dart analyze` — 0 issues (two `lines_longer_
  than_80_chars` infos surfaced on the first pass in test files, fixed by
  wrapping). `dart test` — 28/28 passing.
- **End-to-end smoke test** (real, not simulated): `dart pub global
  activate --source path .`, then in a scratch dir, `chameleon doctor`
  (5/5 checks green) and `chameleon flutter create demo_app --no-install
  --no-codegen --no-verify --no-git` — both ran cleanly end-to-end
  (very_good create → icon generation → brick overlay → format/fix), no
  workarounds needed for those four flags themselves. As expected per the
  task, `chameleon_ui`/`chameleon_core` resolve via `git:` ref against
  `https://github.com/georonathan47/chameleon_flutter_toolchain`, which
  isn't pushed yet, so a bare `flutter pub get` would fail; worked around by
  hand-writing a `pubspec_overrides.yaml` inside `demo_app` with
  `dependency_overrides: {chameleon_ui: {path: ../../.../packages/
  chameleon_ui}, chameleon_core: {path: ...chameleon_core}}` pointing at
  this checkout's real packages. With that override: `fvm flutter pub get`
  resolved clean, `fvm dart run build_runner build
  --delete-conflicting-outputs` built 7 outputs with no errors, `fvm
  flutter analyze` — 0 issues, `fvm flutter test` — 9/9 passing. Then
  `chameleon flutter feature sample --no-codegen --no-verify` and
  `chameleon flutter bloc filters --feature sample --no-codegen --no-verify`
  both ran cleanly inside that same app; a follow-up `build_runner build` +
  `flutter analyze` (0 issues) + `flutter test` (18/18 passing, including
  the newly generated `filters_bloc_test.dart` and the feature's own
  data/presentation tests) confirmed the combined generation was clean on
  the first attempt — no template fixes needed. Deleted
  `/tmp/chameleon_e2e_smoke` afterward as instructed.
- **Icon files confirmed non-trivial and correctly shaped, not garbage**:
  verified file existence/dimensions directly (`android/app/src/
  development/res/mipmap-xxxhdpi/ic_launcher.png` = 192×192 PNG;
  `ios/Runner/AppIcons/AppIcon-dev.icon/Assets/Icon.png` = 1024×1024 PNG;
  Play Store icon = 512×512) and, beyond just checking dimensions, sampled
  actual pixel values from the generated dev icon at the exact fractional
  coordinates the painter uses: all four corners read pure dev-red
  `(211,47,47)` = `0xD32F2F`; the body-center fraction reads pure ink
  `(46,58,51)` = `0x2E3A33`; the eye's pupil-center fraction also reads ink;
  a point just outside the pupil but inside the sclera radius reads
  dev-red again (the "sclera ring" showing the flavor background through,
  as designed). This confirms the installed PNGs are the actual painted
  glyph, not placeholder or corrupted data.
