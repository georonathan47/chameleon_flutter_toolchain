#!/usr/bin/env bash
# Chameleon project guardrails. Run in CI and before every PR.
set -euo pipefail
fail=0

check() {  # check <name> <pattern> <message>
  if grep -rn --include="*.dart" -E "$2" lib/ | grep -v "^\s*//"; then
    echo "✗ $1: $3"
    fail=1
  else
    echo "✓ $1"
  fi
}

check "no setState"       '(^|[^a-zA-Z])setState\('        "Bloc/Cubit owns all state. See tasks/lessons.md."
check "no SnackBar"       'ScaffoldMessenger|showSnackBar'  "Use ChameleonToastMessenger from chameleon_ui."
check "no dartz"          "package:dartz"                  "Use fpdart."
check "no raw hex colors" 'Color\(0x'                       "Use ChameleonColors / ChameleonSemanticColors from chameleon_ui."
check "no leftover TODOs" 'TODO\(chameleon\)'                 "Template placeholders must be filled in."

# Every requested permission macro has a matching usage description.
# This mapping must stay in step with hooks/pre_gen.dart's _usageDescription
# — the Info.plist key does not always match the macro name (photos ->
# NSPhotoLibraryUsageDescription, location -> NSLocationWhenInUseUsageDescription).
usage_key_for() {
  case "$1" in
    CAMERA) echo "NSCameraUsageDescription" ;;
    MICROPHONE) echo "NSMicrophoneUsageDescription" ;;
    PHOTOS) echo "NSPhotoLibraryUsageDescription" ;;
    LOCATION) echo "NSLocationWhenInUseUsageDescription" ;;
    CONTACTS) echo "NSContactsUsageDescription" ;;
    NOTIFICATION) echo "" ;;
    *) echo "" ;;
  esac
}

if [ -f ios/Podfile ] && [ -f ios/Runner/Info.plist ]; then
  for macro in $(grep -o 'PERMISSION_[A-Z]*' ios/Podfile 2>/dev/null | sort -u); do
    permission="${macro#PERMISSION_}"
    key="$(usage_key_for "$permission")"
    if [ -z "$key" ]; then
      continue
    fi
    if ! grep -q "$key" ios/Runner/Info.plist; then
      echo "✗ $macro has no $key in ios/Runner/Info.plist (ITMS-90683)"
      fail=1
    fi
  done
fi

# Deep links (GoRouter receives them automatically once MaterialApp.router
# is wired — already true, see lib/app/view/app.dart — but only once the OS
# actually hands the app a link, which needs this native registration).
# Unconditional: unlike a permission macro, there's no flag/signal for
# "this app wants deep links" to discover from, and every real Chameleon app
# eventually needs at least a password-reset/magic-link scheme.
if [ -f ios/Runner/Info.plist ] && ! grep -q "CFBundleURLTypes" ios/Runner/Info.plist; then
  echo "✗ No CFBundleURLTypes in ios/Runner/Info.plist — deep links need a registered URL scheme."
  fail=1
fi
if [ -f android/app/src/main/AndroidManifest.xml ] && ! grep -q 'android:autoVerify="true"' android/app/src/main/AndroidManifest.xml; then
  echo "✗ No autoVerify intent-filter in AndroidManifest.xml — deep links need a registered App Link."
  fail=1
fi

{{#use_biometrics}}
# use_biometrics is on: local_auth needs these declared or Face ID/the
# biometric prompt silently fails on-device with no OS error surfaced.
if [ -f ios/Runner/Info.plist ] && ! grep -q "NSFaceIDUsageDescription" ios/Runner/Info.plist; then
  echo "✗ use_biometrics is on but NSFaceIDUsageDescription is missing from ios/Runner/Info.plist (ITMS-90683)"
  fail=1
fi
if [ -f android/app/src/main/AndroidManifest.xml ] && ! grep -q "USE_BIOMETRIC" android/app/src/main/AndroidManifest.xml; then
  echo "✗ use_biometrics is on but the USE_BIOMETRIC permission is missing from AndroidManifest.xml"
  fail=1
fi
{{/use_biometrics}}

exit $fail
