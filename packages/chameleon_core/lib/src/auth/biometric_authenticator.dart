/// Face ID/Touch ID/fingerprint unlock, kept vendor-agnostic the same way
/// `ChameleonCrashReporter` keeps this package free of a Firebase dependency:
/// a cross-cutting infra package cannot hang a hard dependency on
/// `local_auth` (or force every consumer to declare
/// `NSFaceIDUsageDescription`/the Android biometric permission whether or not
/// they want the feature). A consuming app supplies the real
/// `local_auth`-backed implementation only when it opts into biometrics; apps
/// that don't opt in — and this package's own tests — get the no-op default
/// below.
abstract interface class BiometricAuthenticator {
  /// Whether this device can attempt biometric authentication at all
  /// (enrolled biometrics + hardware support).
  Future<bool> get isAvailable;

  /// Prompts for biometric authentication, showing [reason] as the
  /// OS-native rationale text. Returns whether it succeeded.
  Future<bool> authenticate({required String reason});
}

/// The default: unavailable, and authentication always fails closed. An app
/// that hasn't opted into biometrics has no biometric UI calling this in the
/// first place, but binding a real singleton either way (instead of leaving
/// it unbound) keeps a feature's constructor-injected dependency the same
/// shape regardless of the flag.
class NoopBiometricAuthenticator implements BiometricAuthenticator {
  const NoopBiometricAuthenticator();

  @override
  Future<bool> get isAvailable async => false;

  @override
  Future<bool> authenticate({required String reason}) async => false;
}
