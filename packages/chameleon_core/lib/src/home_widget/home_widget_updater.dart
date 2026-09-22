/// Pushes data to a home-screen widget, kept vendor-agnostic the same way
/// `BiometricAuthenticator` keeps this package free of a `local_auth`
/// dependency: a cross-cutting infra package cannot hang a hard dependency
/// on `home_widget` (or force every consumer to carry a widget extension
/// they never asked for). A consuming app supplies the real
/// `home_widget`-backed implementation only when it opts into a home
/// screen widget; apps that don't opt in — and this package's own tests —
/// get the no-op default below.
abstract interface class HomeWidgetUpdater {
  /// Saves [value] under [key] for the widget to read on its next update.
  ///
  /// Returns whether the write succeeded.
  Future<bool> saveData(String key, Object? value);

  /// Asks the OS to re-render the widget from whatever was last saved with
  /// [saveData].
  ///
  /// Returns whether the update was requested successfully.
  Future<bool> updateWidget();
}

/// The default: nothing saved, nothing updated, both report failure. An app
/// that hasn't opted into a home screen widget has no widget-facing code
/// calling this in the first place, but binding a real singleton either way
/// (instead of leaving it unbound) keeps a feature's constructor-injected
/// dependency the same shape regardless of the flag.
class NoopHomeWidgetUpdater implements HomeWidgetUpdater {
  const NoopHomeWidgetUpdater();

  @override
  Future<bool> saveData(String key, Object? value) async => false;

  @override
  Future<bool> updateWidget() async => false;
}
