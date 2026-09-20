import 'dart:async';

/// Delays an action until the caller stops asking for it.
///
/// Each [run] cancels the pending call and restarts the clock, so a burst of
/// rapid triggers — keystrokes in a text field, say — results in a single
/// invocation once [duration] of quiet has passed.
///
/// Owners must [dispose] it so a pending timer cannot fire after the widget or
/// bloc holding it is gone.
class Debouncer {
  Debouncer({this.duration = const Duration(milliseconds: 500)});

  /// How long to wait after the last [run] before invoking the action.
  final Duration duration;

  Timer? _timer;

  /// Whether a call is currently scheduled but has not yet fired.
  bool get isPending => _timer?.isActive ?? false;

  /// Schedules [action], replacing any call still waiting to fire.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Drops a pending call without invoking it.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Cancels anything pending. Call from the owner's own `dispose`/`close`.
  void dispose() => cancel();
}
