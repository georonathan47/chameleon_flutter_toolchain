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
| permission_handler macros ↔ Info.plist usage descriptions stay in step | `tool/checks.sh`; both derived from the same `permissions` brick variable |
| `AuthInterceptor`/`IdempotencyInterceptor` ship with empty path lists | `core_module.dart` has a `// TODO(chameleon):` until you configure them — `tool/checks.sh`'s leftover-TODO check fails until you do |
| Deep links need a registered URL scheme/App Link before the OS ever hands one to GoRouter | `tool/checks.sh` checks for `CFBundleURLTypes` (Info.plist) and an `autoVerify` intent-filter (AndroidManifest.xml) — unconditional, not gated by a flag |
| `use_biometrics` needs `NSFaceIDUsageDescription`/`USE_BIOMETRIC` declared | `tool/checks.sh`, only when `use_biometrics` is on |
| A debug hook needed in production isn't `@visibleForTesting` | Convention — see `tasks/lessons.md` #10 |

## `@visibleForTesting` vs. a debug hook

`@visibleForTesting` means *tests only* — the analyzer will reject it being
called from non-test code outside the same package. If production code
needs a hook (a QA dart-define, a debug menu action), make it public and gate
it on `kDebugMode` in the call site; the gate, not the annotation, is what
keeps it out of release builds.
