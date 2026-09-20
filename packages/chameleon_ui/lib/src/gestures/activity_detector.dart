import 'package:flutter/widgets.dart';

/// Feeds user activity and app-lifecycle changes to whoever wants to track
/// them — typically an app-level inactivity watchdog.
///
/// Wraps the whole app, so no page has to report activity itself. Takes plain
/// callbacks rather than a concrete service type: a design-system package
/// must not know about the app's inactivity-timeout service, so the app wires
/// its own service's methods in as [onActivity] / [onAppPaused] /
/// [onAppResumed].
///
/// Uses a [Listener] rather than a [GestureDetector] on purpose:
/// `DismissKeyboard` already wraps the app in a translucent [GestureDetector],
/// and every page is full of buttons and scrollables; a second gesture
/// detector would join the gesture arena and compete for the taps and drags
/// those widgets need.
/// [Listener] observes raw pointer events *before* the arena resolves and never
/// claims them, so nothing downstream changes behaviour.
///
/// [HitTestBehavior.translucent] so pointers landing on transparent gaps —
/// padding, empty space in a [Stack] — still count as activity while children
/// below keep receiving them.
class ActivityDetector extends StatefulWidget {
  const ActivityDetector({
    required this.child,
    this.onActivity,
    this.onAppPaused,
    this.onAppResumed,
    super.key,
  });

  final Widget child;

  /// Called on a pointer down, move, or scroll signal.
  final VoidCallback? onActivity;

  /// Called when the app enters `paused`, `hidden`, or `detached`.
  final VoidCallback? onAppPaused;

  /// Called when the app returns to `resumed`.
  final VoidCallback? onAppResumed;

  @override
  State<ActivityDetector> createState() => _ActivityDetectorState();
}

class _ActivityDetectorState extends State<ActivityDetector>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        widget.onAppPaused?.call();
      case AppLifecycleState.resumed:
        widget.onAppResumed?.call();
      case AppLifecycleState.inactive:
        // Fires for transient interruptions the user has not really left for:
        // the app switcher, a permission dialog, an incoming call banner.
        // Treating those as a pause would lock the app during a half-second
        // glance — notably when stepping out to read an OTP.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      // Down covers taps; move covers scrolls and drags, which can hold the
      // app busy for minutes without a single new pointer-down.
      onPointerDown: (_) => widget.onActivity?.call(),
      onPointerMove: (_) => widget.onActivity?.call(),
      onPointerSignal: (_) => widget.onActivity?.call(),
      child: widget.child,
    );
  }
}
