import 'dart:async';

import 'package:flutter/material.dart';

import '../../tokens/chameleon_motion.dart';
import '../../tokens/chameleon_spacing.dart';
import 'chameleon_toast.dart';
import 'chameleon_toast_type.dart';

/// Shows [ChameleonToast] over whatever is on screen.
///
/// Global by construction: it holds its own [OverlayState] via
/// [ChameleonToastHost], which is mounted once above the router. That means a
/// toast can be raised from anywhere — a cubit listener, a service, a page —
/// without the caller needing a `Scaffold` in its subtree, which is the
/// limitation that makes `ScaffoldMessenger` awkward for app-wide messages.
///
/// Only one toast is on screen at a time. A second [show] replaces the first
/// rather than stacking, so a burst of messages cannot bury the UI.
abstract final class ChameleonToastMessenger {
  /// The overlay the host registered. Null before the app mounts.
  static OverlayState? _overlay;

  /// The toast currently on screen, if any.
  static OverlayEntry? _entry;

  /// Hides the current toast once it has had its time.
  static Timer? _dismissTimer;

  /// Drives the slide-and-fade entry, and its reverse on dismissal.
  static AnimationController? _animation;

  /// How long a toast stays up before hiding itself.
  ///
  /// Long enough to read two lines without hurrying, short enough that an
  /// ignored toast clears itself rather than sitting over the UI.
  static const Duration visibleDuration = Duration(seconds: 4);

  /// Registers the overlay to draw into. Called by [ChameleonToastHost].
  ///
  /// Kept a method rather than a setter so it pairs with [detach], which takes
  /// the overlay as an argument and therefore cannot be one.
  // ignore: use_setters_to_change_properties
  static void attach(OverlayState overlay) => _overlay = overlay;

  /// Releases [overlay], and anything currently showing in it.
  ///
  /// Guarded so a stale host tearing down after a new one has attached cannot
  /// unregister the live overlay.
  static void detach(OverlayState overlay) {
    if (!identical(_overlay, overlay)) return;

    // Synchronous teardown, not `dismiss()`: the overlay is going away now, so
    // there is nothing left to animate an exit into, and an controller left
    // ticking would outlive the tree it belongs to.
    reset();
  }

  /// Raises a toast carrying [title] and [description].
  ///
  /// [type] selects the icon and its tile colour; it defaults to the neutral
  /// announcement so the common case is just the two strings.
  ///
  /// Does nothing when no host is mounted — a message with nowhere to go is
  /// not worth crashing over.
  static void show({
    required String title,
    required String description,
    ChameleonToastType type = ChameleonToastType.announcement,
    Duration duration = visibleDuration,
    Color? backgroundColor,
    Color? foregroundColor,
    Duration transitionDuration = ChameleonMotion.fast,
    Curve transitionCurve = ChameleonMotion.emphasizedDecelerate,
  }) {
    final overlay = _overlay;
    if (overlay == null) {
      assert(
        false,
        'ChameleonToastMessenger.show() with no ChameleonToastHost mounted. '
        'Wrap the app in ChameleonToastHost (see App.builder).',
      );
      return;
    }

    // Replace rather than stack: a queue of toasts is a queue of things
    // covering the screen.
    dismiss();

    final animation = AnimationController(
      vsync: overlay,
      duration: transitionDuration,
    );
    _animation = animation;

    final entry = OverlayEntry(
      builder: (context) => _ToastOverlay(
        animation: animation,
        title: title,
        description: description,
        type: type,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        transitionCurve: transitionCurve,
        onDismiss: dismiss,
      ),
    );
    _entry = entry;

    overlay.insert(entry);
    unawaited(animation.forward());

    _dismissTimer = Timer(duration, dismiss);
  }

  /// Reports a failure.
  ///
  /// The app's default way to surface an error to the user: a backend message,
  /// a validation failure, a request that could not be completed. [message]
  /// carries the specifics, so it becomes the description rather than the
  /// title — the title says *what kind* of thing happened, which is what makes
  /// a glance enough.
  static void error(
    String message, {
    String title = 'Something went wrong',
    Duration duration = visibleDuration,
    Color? backgroundColor,
    Color? foregroundColor,
    Duration transitionDuration = ChameleonMotion.fast,
    Curve transitionCurve = ChameleonMotion.emphasizedDecelerate,
  }) => show(
    title: title,
    description: message,
    type: ChameleonToastType.error,
    duration: duration,
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    transitionDuration: transitionDuration,
    transitionCurve: transitionCurve,
  );

  /// Confirms something worked.
  static void success(
    String message, {
    String title = 'Done',
    Duration duration = visibleDuration,
    Color? backgroundColor,
    Color? foregroundColor,
    Duration transitionDuration = ChameleonMotion.fast,
    Curve transitionCurve = ChameleonMotion.emphasizedDecelerate,
  }) => show(
    title: title,
    description: message,
    type: ChameleonToastType.success,
    duration: duration,
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    transitionDuration: transitionDuration,
    transitionCurve: transitionCurve,
  );

  /// Removes the toast immediately, cancelling its timer.
  ///
  /// Safe to call when nothing is showing, and safe to call twice — the close
  /// button, the timer and a replacement all route through here.
  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;

    final entry = _entry;
    final animation = _animation;
    _entry = null;
    _animation = null;

    if (entry == null || animation == null) return;

    // Play the entry backwards, then tear down. The entry is removed in the
    // callback rather than immediately so the exit is actually seen.
    unawaited(
      animation.reverse().whenComplete(() {
        entry.remove();
        animation.dispose();
      }),
    );
  }

  /// Whether a toast is currently on screen. For tests.
  @visibleForTesting
  static bool get isShowing => _entry != null;

  /// Drops all state without animating.
  ///
  /// [dismiss] plays an exit before tearing down, which needs frames to
  /// complete. A test that ends while a toast is still on screen never pumps
  /// those frames, leaving a live [AnimationController] whose ticker outlives
  /// the test — it then ticks against the next test's reset clock and trips
  /// `elapsedInSeconds >= 0.0`. This tears everything down synchronously
  /// instead, so no state crosses a test boundary.
  @visibleForTesting
  static void reset() {
    _dismissTimer?.cancel();
    _dismissTimer = null;

    _animation?.dispose();
    _animation = null;

    // The entry may already be detached if its overlay went first, so removal
    // is guarded rather than assumed.
    if (_entry?.mounted ?? false) _entry!.remove();
    _entry = null;

    _overlay = null;
  }
}

/// Positions the toast and gives it its entry motion and swipe-to-dismiss.
class _ToastOverlay extends StatelessWidget {
  const _ToastOverlay({
    required this.animation,
    required this.title,
    required this.description,
    required this.type,
    required this.transitionCurve,
    required this.onDismiss,
    this.backgroundColor,
    this.foregroundColor,
  });

  final AnimationController animation;
  final String title;
  final String description;
  final ChameleonToastType type;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Curve transitionCurve;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final slide = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: transitionCurve));

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(ChameleonSpacing.base),
          child: FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slide,
              child: Dismissible(
                // Unique per toast, so a replacement is never mistaken for the
                // one it replaced.
                key: ValueKey(identityHashCode(this)),
                direction: DismissDirection.up,
                onDismissed: (_) => onDismiss(),
                child: ChameleonToast(
                  title: title,
                  description: description,
                  type: type,
                  backgroundColor: backgroundColor,
                  foregroundColor: foregroundColor,
                  onDismiss: onDismiss,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mounts the overlay [ChameleonToastMessenger] draws into.
///
/// Wrapped around the app once, above the router, so every route inherits it.
/// It renders [child] unchanged and adds an [Overlay] above it.
class ChameleonToastHost extends StatefulWidget {
  const ChameleonToastHost({required this.child, super.key});

  final Widget child;

  @override
  State<ChameleonToastHost> createState() => _ChameleonToastHostState();
}

class _ChameleonToastHostState extends State<ChameleonToastHost> {
  /// Identifies this host's overlay so the messenger can be handed it once the
  /// first frame has laid it out.
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();

  /// The overlay this host registered.
  ///
  /// Held rather than re-read from the key on the way out: by the time
  /// [dispose] runs the key's state is already gone, so looking it up there
  /// would silently skip the detach and leave the messenger holding a dead
  /// overlay.
  OverlayState? _attachedOverlay;

  @override
  void initState() {
    super.initState();
    // The overlay does not exist until the tree is built, so registration
    // waits for the first frame rather than reading a null state here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final overlay = _overlayKey.currentState;
      if (overlay == null) return;

      _attachedOverlay = overlay;
      ChameleonToastMessenger.attach(overlay);
    });
  }

  @override
  void dispose() {
    final overlay = _attachedOverlay;
    if (overlay != null) ChameleonToastMessenger.detach(overlay);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      key: _overlayKey,
      initialEntries: [
        OverlayEntry(builder: (context) => widget.child),
      ],
    );
  }
}
