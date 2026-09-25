# Guardrails

Mechanisms, not just documentation — see `tasks/lessons.md` for the reasoning
behind each.

| Rule | Enforced by |
| --- | --- |
| Verify the branch builds before assessing what's left | `tool/verify.sh`; run it before reporting a task done |
| Never `setState` | `tool/checks.sh` greps `lib/` |
| Toasts, never SnackBars | `tool/checks.sh` greps `lib/`; use `ChameleonToastMessenger` from `chameleon_ui` |
| No `dartz` (use `fpdart`) | `tool/checks.sh` |
| No raw hex colors (use `ChameleonColors`/`ChameleonSemanticColors`) | `tool/checks.sh` |
| No leftover `TODO(chameleon)` placeholders | `tool/checks.sh` |
| permission_handler macros ↔ Info.plist usage descriptions stay in step | `tool/checks.sh`; both derived from the same `permissions` brick variable. Under Swift Package Manager (this app's default — see `docs/architecture.md`), the Info.plist entries alone are what actually activates each permission; the Podfile macros are CocoaPods-fallback redundancy, not the primary mechanism. |
| `AuthInterceptor`/`IdempotencyInterceptor` ship with empty path lists | `core_module.dart` has a `// TODO(chameleon):` until you configure them — `tool/checks.sh`'s leftover-TODO check fails until you do |
| Deep links need a registered URL scheme/App Link before the OS ever hands one to GoRouter | `tool/checks.sh` checks for `CFBundleURLTypes` (Info.plist) and an `autoVerify` intent-filter (AndroidManifest.xml) — unconditional, not gated by a flag. `post_gen.dart` generates both automatically; the App Link host is a placeholder derived from `org_name` — replace it with a domain you own before release. See `docs/architecture.md`'s "Deep linking" section. |
| `use_biometrics` needs `NSFaceIDUsageDescription`/`USE_BIOMETRIC` declared | `tool/checks.sh`, only when `use_biometrics` is on |
| `HomeWidgetUpdater` binding matches `use_home_widget` | `core_module.dart`'s mustache split — the real, `home_widget`-backed impl only compiles in when the flag is on |
| The iOS Widget Extension target itself exists | Not automated — see `ios/HomeWidgetExtension/README.md`; nothing text-greppable proves a Widget Extension target was created in Xcode |
| `PushNotificationService` binding matches `use_push_notifications` | `core_module.dart`'s mustache split — the real, `firebase_messaging`-backed impl only compiles in when the flag is on |
| `use_push_notifications` needs `POST_NOTIFICATIONS` declared (Android 13+) | `post_gen.dart`, automatic when the flag is on |
| A real Firebase project (`flutterfire configure`) and the iOS Push Notifications/Background Modes capabilities exist | Not automated — see `docs/architecture.md`'s "Push notifications" section; nothing text-greppable proves either was done |
| A debug hook needed in production isn't `@visibleForTesting` | Convention — see `tasks/lessons.md` #10 |
| Prefer dot shorthands (`.member`) once the target type is already known | `chameleon_lints` (`dart run custom_lint`) — `chameleon_prefer_dot_shorthands` |
| Prefer a feature's barrel file over reaching into its internal `data`/`domain`/`presentation`/`di` layers from outside that feature | `chameleon_lints` (`dart run custom_lint`) — `chameleon_prefer_barrel_imports` |
| Prefer `sealed class` for a hierarchy whose subtypes are all declared in the same file | `chameleon_lints` (`dart run custom_lint`) — `chameleon_prefer_sealed_class`; suppress a deliberately open hierarchy with `// ignore: chameleon_prefer_sealed_class` |
| A `TaskEither<Failure, ...>` method must be built from a safe `TaskEither` constructor, never a raw `async`/`await` block that can throw past its own contract | `chameleon_lints` (`dart run custom_lint`) — `chameleon_task_either_requires_safe_construction` |
| No raw `print`/`debugPrint` — log through `ChameleonLogger` | `chameleon_lints` (`dart run custom_lint`) — `chameleon_no_print` |

## `@visibleForTesting` vs. a debug hook

`@visibleForTesting` means *tests only* — the analyzer will reject it being
called from non-test code outside the same package. If production code
needs a hook (a QA dart-define, a debug menu action), make it public and gate
it on `kDebugMode` in the call site; the gate, not the annotation, is what
keeps it out of release builds.
