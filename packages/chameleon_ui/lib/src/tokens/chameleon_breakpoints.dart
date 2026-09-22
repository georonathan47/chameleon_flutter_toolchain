import 'package:flutter/widgets.dart';

/// A window size class — which of this design system's three responsive
/// tiers the current width falls into.
///
/// Named by device rather than Material 3's abstract compact/medium/
/// expanded terminology, and deliberately three tiers, not five: no
/// desktop tier. A window size class is determined purely by available
/// width, not device type, so a foldable isn't a fourth tier of its own —
/// a folded cover screen is narrow enough to land in [phone] like any
/// phone, and an unfolded inner display lands in [tablet] (portrait) or
/// [foldable] (landscape) from its real measured width alone.
enum ChameleonWindowSizeClass {
  /// Below [ChameleonBreakpoints.tablet] — phones, and a folded
  /// foldable's cover screen.
  phone,

  /// [ChameleonBreakpoints.tablet] to just below
  /// [ChameleonBreakpoints.foldable] — tablets in portrait, and an
  /// unfolded foldable's inner display in portrait.
  tablet,

  /// [ChameleonBreakpoints.foldable] and above, uncapped — tablets in
  /// landscape, and an unfolded foldable's inner display in landscape:
  /// the device this tier is named for.
  foldable,
}

/// Chameleon responsive breakpoints.
///
/// Each constant is the minimum width (logical pixels / dp) its window
/// size class starts at — the same convention Material 3's own window
/// size classes and CSS frameworks like Tailwind/Bootstrap use. Values
/// confirmed against Android's own current adaptive-layout guidance
/// (developer.android.com's window size class table).
abstract final class ChameleonBreakpoints {
  /// 0 — [ChameleonWindowSizeClass.phone] starts here.
  static const double phone = 0;

  /// 600 — [ChameleonWindowSizeClass.tablet] starts here.
  static const double tablet = 600;

  /// 840 — [ChameleonWindowSizeClass.foldable] starts here, uncapped.
  static const double foldable = 840;

  /// The window size class for [width] (logical pixels / dp).
  static ChameleonWindowSizeClass classify(double width) {
    if (width < tablet) return ChameleonWindowSizeClass.phone;
    if (width < foldable) return ChameleonWindowSizeClass.tablet;
    return ChameleonWindowSizeClass.foldable;
  }

  /// The window size class for [context]'s current width.
  ///
  /// Reads [MediaQuery.sizeOf] specifically, not [MediaQuery.of] — a
  /// consumer only rebuilds when the *size* changes, not on every
  /// MediaQuery field (padding, brightness, text scale, ...).
  static ChameleonWindowSizeClass of(BuildContext context) =>
      classify(MediaQuery.sizeOf(context).width);
}
