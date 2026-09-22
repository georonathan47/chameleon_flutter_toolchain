# Lessons

Patterns worth not relearning. Reviewed at session start.

## Inherited from the Chameleon template (v1.0.0)

<!-- These came from chameleon_app. They apply to every Chameleon Flutter
     project. Do not delete them; add project-specific lessons below. -->

1. **Verify the branch builds before assessing "what's left."** Run
   `flutter analyze` and `flutter test` before forming any opinion about
   remaining work — file listings and source reads describe intent, not
   state. Check: `./tool/verify.sh` exits 0.
2. **Codegen failure cascades.** One unparseable file stops every builder
   (`freezed`, `json_serializable`, `injectable`, `chopper`, `envied`)
   because they all analyze the whole library. Find the syntax error first;
   ignore the rest of the list until it's fixed.
3. **`@freezed` + `@JsonSerializable`: don't stack them.** A model is
   `@freezed` with a `fromJson` factory and a `part '*.g.dart'`. Nothing
   else.
4. **Ported infrastructure carries the old project's assumptions.**
   `auth_interceptor.dart`'s no-auth path list and
   `idempotency_interceptor.dart`'s required-path list both start **empty**
   in `chameleon_core` — wire this app's real endpoints via
   `configureNoAuthPaths` / `configureRequiredPaths` in `core_module.dart`
   before shipping. Check: neither is still empty by launch.
5. **Route guards need a tri-state, not a boolean.** `AuthUnknown` /
   `Authenticated` / `Unauthenticated` — the redirect returns `null` while
   unresolved, so a returning user isn't bounced to login for the frames
   before secure storage is read.
6. **A DI singleton must be provided with `.value`.**
   `BlocProvider(create: (_) => getIt<X>())` closes the bloc when the widget
   is disposed, but the container still holds it. Use `BlocProvider.value`.
7. **A route depending on DI breaks widget tests** unless the test
   registers stubs in `setUp` with `tearDown(getIt.reset)`. See
   `test/helpers/di_harness.dart`.
8. **A green test suite can hide a dead error path.** Chopper nulls
   `Response.body` on a non-2xx response and moves the payload to
   `Response.error` — a test stub that bypasses chopper and puts the map
   straight into `body` tests a shape production never produces. Model the
   failure shape a real client builds, not a shortcut.
9. **Verify generated-code assumptions against the generator, not
   intuition.** Regenerate before wiring anything up, and re-read the
   regenerated output — a stale `.g.dart`/`.chopper.dart` has you debugging
   a signature the build hasn't produced yet.
10. **A chopper client only knows the services you hand it.** Registering
    something in DI is not the same as registering it with the
    `ChopperClient` that constructs it (`services: [...]`). Cover the real
    object graph with a smoke test — see
    `test/core/di/injection_smoke_test.dart`.
11. **injectable cannot resolve a bare function-type constructor
    parameter**, and it resolves *every* constructor parameter, optional
    ones included. Keep an `@injectable`/`@lazySingleton` class's
    constructor free of anything that isn't a real registered dependency —
    settable fields/methods for config, a separate named constructor for
    test seams.
12. **`@visibleForTesting` blocks legitimate debug hooks.** It means "tests
    only," not "not for normal use." A production debug hook is public and
    gated on `kDebugMode`.
13. **Isolates: statics don't cross, and test doubles are copied, not
    shared.** Seed required statics (`FlavorConfig`, DI) at the worker's
    entry point via `initIsolateBinaryMessenger`. A mock that records state
    into an instance field is copied into the worker and discarded when it
    exits — send captures home over a `SendPort` instead.
14. **Never `setState`.** State — including small widget-local UI state —
    belongs in a Cubit or Bloc. Check:
    `grep -rn "setState" lib --include="*.dart"` returns nothing.
15. **A permission that's always "permanently denied" is a build-config
    bug, not app logic.** `permission_handler` compiles every permission
    handler out by default. This app's iOS/macOS dependencies resolve via
    **Swift Package Manager** (Flutter 3.44+'s default — see
    `docs/architecture.md`'s "Swift Package Manager" section), and under
    SPM `permission_handler` auto-enables each permission define straight
    from `Info.plist`: no macro, no `pod install`, nothing else to
    configure. The `ios/Podfile` `post_install` block still sets the
    matching `PERMISSION_*` macro too — harmless redundancy, kept only as
    the fallback path for the rare case Flutter falls back to CocoaPods for
    a plugin. Either way, every macro/permission needs a matching
    `NS*UsageDescription` in `Info.plist` (App Store rejection ITMS-90683
    otherwise). Check: `./tool/checks.sh`.
16. **Toasts, never SnackBars.** `ScaffoldMessenger`/`SnackBar` are banned;
    use `ChameleonToastMessenger` from `chameleon_ui`. Check:
    `grep -rn "showSnackBar\|ScaffoldMessenger" lib --include="*.dart"`
    returns nothing outside comments.
17. **A home-screen widget's native half can't be fully generated.**
    Android is: `ChameleonHomeWidgetProvider.kt`, its layout, its
    `appwidget-provider` XML, and the `AndroidManifest.xml` receiver entry
    are all written for you when `use_home_widget` is on. iOS isn't —
    creating a Widget Extension target is an Xcode-UI-only operation with
    no scriptable path (confirmed against Flutter's own "Adding iOS app
    extensions" doc), so `ios/HomeWidgetExtension/` ships Swift starter
    source plus a README covering the manual target-creation and App Group
    steps instead of pretending they can be automated. See
    `docs/architecture.md`'s "Home screen widgets" section.
18. **A plugin's SPM package can require a higher iOS floor than this
    template ships with.** `home_widget` needs iOS 14+; `very_good_cli`'s
    default `project.pbxproj`/`Podfile` are 13.0. `flutter build ios`
    fails outright, not just the Widget Extension — found by actually
    building, not assumed. `use_home_widget` bumps both files' deployment
    target to 14.0 for exactly this reason.
19. **A standing `tool/checks.sh` check can exist for longer than anything
    that satisfies it.** The deep-link check (`CFBundleURLTypes`/
    `autoVerify`) was already unconditional in `checks.sh` and already
    documented in `docs/guardrails.md` before `post_gen.dart` generated
    either entry — every app this brick produced was silently failing its
    own guardrail script. A guardrail existing is not evidence the thing it
    checks for was ever actually built; verify both sides.
20. **A Firebase-backed feature needs `flutterfire configure`, not
    brick-generated Gradle/plist files.** `firebase_core` on Android
    normally means adding the Google Services Gradle plugin plus
    `google-services.json` — this toolchain has deliberately never
    hand-patched `build.gradle.kts` (same reasoning that kept home-screen
    widgets off Jetpack Glance/Compose). `flutterfire configure` is
    Firebase's own tool for exactly that wiring, safer than reimplementing
    it here. `use_push_notifications` ships the Dart-side interface/impl
    and documents that command as the one required setup step, rather than
    scripting around it.

## Project-specific
