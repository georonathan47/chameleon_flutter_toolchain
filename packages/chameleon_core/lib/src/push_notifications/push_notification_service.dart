/// Push notification registration and receipt, kept vendor-agnostic the
/// same way `HomeWidgetUpdater` keeps this package free of a `home_widget`
/// dependency: a cross-cutting infra package cannot hang a hard dependency
/// on `firebase_messaging` (or force every consumer to ship Firebase). A
/// consuming app supplies the real `firebase_messaging`-backed
/// implementation only when it opts into push notifications; apps that
/// don't opt in — and this package's own tests — get the no-op default
/// below.
///
/// [onMessage] carries a plain `Map`, not a vendor type (e.g.
/// `RemoteMessage`), so this interface itself never needs a
/// `firebase_messaging` import.
abstract interface class PushNotificationService {
  /// The device's current push token, or `null` if unavailable.
  Future<String?> getToken();

  /// Prompts for notification permission (including the Android 13+
  /// runtime prompt). Returns whether it was granted.
  Future<bool> requestPermission();

  /// Emits one entry per message received while the app is in the
  /// foreground.
  Stream<Map<String, dynamic>> get onMessage;
}

/// The default: no token, permission always denied, no messages ever
/// arrive. An app that hasn't opted into push notifications has no
/// notification UI calling this in the first place, but binding a real
/// singleton either way (instead of leaving it unbound) keeps a feature's
/// constructor-injected dependency the same shape regardless of the flag.
class NoopPushNotificationService implements PushNotificationService {
  const NoopPushNotificationService();

  @override
  Future<String?> getToken() async => null;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Stream<Map<String, dynamic>> get onMessage => const Stream.empty();
}
