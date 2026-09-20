#!/usr/bin/env bash
# The verification gate: analyze + test + format + guardrails, in that order
# so the first real failure is the one reported, not a downstream symptom.
set -euo pipefail

FLUTTER="${FLUTTER:-flutter}"
if command -v fvm >/dev/null 2>&1 && [ -f .fvmrc ]; then
  FLUTTER="fvm flutter"
fi

echo "==> flutter analyze"
$FLUTTER analyze

echo "==> dart format --output=none --set-exit-if-changed lib test"
# Scoped to lib/ and test/, not "." — pointed at the whole project, dart
# format walks into build/ looking for a nested analysis_options.yaml (via
# CocoaPods/SPM-fetched plugin example directories under
# build/ios/SourcePackages) and crashes on a dangling relative include.
${FLUTTER/flutter/dart} format --output=none --set-exit-if-changed lib test

echo "==> flutter test"
$FLUTTER test

echo "==> tool/checks.sh"
./tool/checks.sh

echo "All checks passed."
