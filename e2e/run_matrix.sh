#!/usr/bin/env bash
# Generates a Chameleon app with each brick-flag combination that matters
# and verifies it for real.
#
# Pass/fail gate is `chameleon create`'s own verification step
# (flutter analyze + flutter test + dart run custom_lint), re-checked
# explicitly below. `tool/checks.sh` is run too and its output is shown,
# but it is NOT part of the gate: every freshly generated app fails its
# "no leftover TODOs" check by design — `core_module.dart` ships a
# `// TODO(chameleon): AuthInterceptor.configureNoAuthPaths...` comment
# that's meant to stay until a developer wires a real backend contract,
# documented in `bricks/chameleon_app/__brick__/docs/guardrails.md` and
# `tasks/lessons.md`, not a bug. A real regression (setState, SnackBar,
# dartz, a raw hex color, or a permission-macro mismatch) still shows up
# in the output for a human to notice; it just doesn't fail the matrix
# on its own.
set -uo pipefail

TOOLCHAIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRATCH_ROOT="$(dirname "$TOOLCHAIN_ROOT")"
CLI_DIR="$TOOLCHAIN_ROOT/cli/chameleon_cli"

echo "Bundling the bricks and activating chameleon_cli from $CLI_DIR ..."
mason bundle "$TOOLCHAIN_ROOT/bricks/chameleon_app" -t dart -o "$CLI_DIR/lib/src/bundles/" >/dev/null
mason bundle "$TOOLCHAIN_ROOT/bricks/chameleon_feature" -t dart -o "$CLI_DIR/lib/src/bundles/" >/dev/null
mason bundle "$TOOLCHAIN_ROOT/bricks/chameleon_state" -t dart -o "$CLI_DIR/lib/src/bundles/" >/dev/null
dart pub global activate --source path "$CLI_DIR" >/dev/null

declare -a NAMES=()
declare -a FLAGS=()

NAMES+=("e2e_defaults"); FLAGS+=("")
# --state cubit was removed (folded into the single "bloc" choice — see
# issue #10); this variant's real purpose was always exercising a
# non-default router alongside state management, not cubit specifically.
NAMES+=("e2e_auto_route"); FLAGS+=("--router auto_route")
NAMES+=("e2e_biometrics"); FLAGS+=("--biometrics")
NAMES+=("e2e_with_permissions"); FLAGS+=("--permissions camera,notification")
NAMES+=("e2e_home_widget"); FLAGS+=("--home-widget")
NAMES+=("e2e_push_notifications"); FLAGS+=("--push-notifications")
NAMES+=("e2e_provider"); FLAGS+=("--state provider")
NAMES+=("e2e_riverpod"); FLAGS+=("--state riverpod")

fail_count=0

for i in "${!NAMES[@]}"; do
  name="${NAMES[$i]}"
  flags="${FLAGS[$i]}"
  project_dir="$SCRATCH_ROOT/$name"

  echo ""
  echo "=== $name (chameleon create $name $flags) ==="
  rm -rf "$project_dir"

  # shellcheck disable=SC2086
  if ! chameleon create "$name" -o "$SCRATCH_ROOT" --no-git $flags; then
    echo "✗ $name: chameleon create failed"
    fail_count=$((fail_count + 1))
    continue
  fi

  echo "--- tool/checks.sh (informational — see header above) ---"
  (cd "$project_dir" && ./tool/checks.sh) || true

  echo "--- gate: flutter analyze && flutter test && dart run custom_lint ---"
  if ! (cd "$project_dir" && flutter analyze && flutter test && dart run custom_lint); then
    echo "✗ $name failed analyze/test/custom_lint — left at $project_dir for inspection"
    fail_count=$((fail_count + 1))
    continue
  fi

  # A freshly generated app must report no drift (the deliberate leftover
  # TODO is only a warning there). Compares against real remote tags, so it
  # also catches a hardcoded ref in create_command.dart going stale.
  echo "--- extra gate: chameleon audit ---"
  if [ "$name" = "e2e_biometrics" ]; then
    # --biometrics apps intentionally fail tool/checks.sh until the developer
    # adds NSFaceIDUsageDescription/USE_BIOMETRIC by hand (documented in
    # brick.yaml), so audit must fail here — on exactly those two checks.
    audit_output="$(cd "$project_dir" && chameleon audit 2>&1)"
    audit_exit=$?
    echo "$audit_output"
    if [ "$audit_exit" -eq 0 ] \
      || ! grep -q "NSFaceIDUsageDescription" <<<"$audit_output" \
      || ! grep -q "USE_BIOMETRIC" <<<"$audit_output"; then
      echo "✗ $name: chameleon audit should fail on the two missing biometric declarations"
      fail_count=$((fail_count + 1))
      continue
    fi
  elif ! (cd "$project_dir" && chameleon audit); then
    echo "✗ $name failed chameleon audit — left at $project_dir for inspection"
    fail_count=$((fail_count + 1))
    continue
  fi

  # flutter analyze/test only ever touch Dart — the home-widget variant is
  # the only one that also generates a native Kotlin file
  # (ChameleonHomeWidgetProvider.kt), and nothing above would notice if it
  # didn't compile. A real Gradle build is the only way to prove it does.
  if [ "$name" = "e2e_home_widget" ]; then
    echo "--- extra gate: flutter build apk --debug (native Kotlin isn't caught above) ---"
    # This brick only ships flavored entrypoints (main_development.dart et
    # al.) — there is no plain lib/main.dart — so a bare `flutter build apk
    # --debug` fails with "Target file lib/main.dart not found" regardless
    # of whether the generated app is otherwise correct. Found by actually
    # running this gate, not assumed.
    if ! (cd "$project_dir" && flutter build apk --debug --flavor development -t lib/main_development.dart); then
      echo "✗ $name failed flutter build apk — left at $project_dir for inspection"
      fail_count=$((fail_count + 1))
      continue
    fi
  fi

  echo "✓ $name passed"
  rm -rf "$project_dir"
done

# A separate chained check, not another NAMES/FLAGS row: it exercises
# `chameleon feature`/`chameleon state` (never invoked by any row above),
# specifically the state_management default-from-template.yaml path (no
# --state passed to `feature`) and the explicit --state override path
# (passed to `state`), in one non-default (riverpod) app. Each command's
# own default --verify already gates on analyze+test+custom_lint, so there
# is nothing extra to re-run here.
variant_count=$((${#NAMES[@]} + 1))
chain_name="e2e_feature_riverpod"
chain_dir="$SCRATCH_ROOT/$chain_name"

echo ""
echo "=== $chain_name (create --state riverpod -> feature -> state) ==="
rm -rf "$chain_dir"

chain_ok=true
if ! chameleon create "$chain_name" -o "$SCRATCH_ROOT" --no-git --state riverpod; then
  echo "✗ $chain_name: chameleon create failed"
  chain_ok=false
fi

if $chain_ok && ! (cd "$chain_dir" && chameleon feature widgets); then
  echo "✗ $chain_name: chameleon feature widgets failed (expected to default to riverpod)"
  chain_ok=false
fi

if $chain_ok && ! (cd "$chain_dir" && chameleon state counter --feature widgets --state provider); then
  echo "✗ $chain_name: chameleon state counter --state provider failed (explicit override)"
  chain_ok=false
fi

if $chain_ok; then
  echo "✓ $chain_name passed"
  rm -rf "$chain_dir"
else
  fail_count=$((fail_count + 1))
  echo "  left at $chain_dir for inspection"
fi

echo ""
if [ "$fail_count" -eq 0 ]; then
  echo "All $variant_count e2e variants passed."
  exit 0
else
  echo "$fail_count of $variant_count e2e variants failed."
  exit 1
fi
