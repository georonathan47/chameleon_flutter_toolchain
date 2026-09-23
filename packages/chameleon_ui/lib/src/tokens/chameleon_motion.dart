import 'package:flutter/animation.dart';

/// Chameleon motion scale.
///
/// Durations and curves are centralized here so animation timing stays
/// consistent with the design system rather than being scattered as literals
/// across widgets.
abstract final class ChameleonMotion {
  /// A brief crossfade for small in-place state changes — a field's trailing
  /// status swapping between a spinner and its resolved icon, say.
  static const Duration fast = Duration(milliseconds: 200);

  /// `cubic-bezier(0.22, 0.9, 0.36, 1)`.
  ///
  /// A fast, emphatic start that decelerates into place. Flutter's [Cubic]
  /// takes the same control points, so this is exact rather than approximated.
  static const Cubic emphasizedDecelerate = Cubic(0.22, 0.9, 0.36, 1);

  /// How long a single splash tile takes to fade and drop into place.
  static const Duration splashTileFade = Duration(milliseconds: 550);

  /// Delay between consecutive tiles entering, producing a diagonal sweep.
  static const Duration splashTileStagger = Duration(milliseconds: 200);

  /// How far a splash tile falls as it enters, in design-space units.
  static const double splashDrop = 20;

  /// `cubic-bezier(0.16, 1, 0.3, 1)` — an even sharper deceleration, used by
  /// hero-style card stacks and backgrounds.
  static const Cubic expressiveDecelerate = Cubic(0.16, 1, 0.3, 1);

  /// A bouncy overshoot for elements that spring into place.
  ///
  /// Flutter's [Curves.easeOutBack] overshoots the target and settles back,
  /// which is the "bouncy" read a loader wordmark's slide-up calls for.
  static const Curve bouncyDecelerate = Curves.easeOutBack;

  /// How long a loader wordmark takes to slide up into view.
  static const Duration wordmarkSlide = Duration(milliseconds: 700);

  /// Held before the wordmark starts, so it follows the assembled mark rather
  /// than competing with the mark's own build-in.
  static const Duration wordmarkDelay = Duration(milliseconds: 700);

  /// Height of the clip window the wordmark is revealed through. The text
  /// sits fully below this window at rest.
  static const double wordmarkClipHeight = 103;

  /// How far the wordmark travels upward out of its clip.
  static const double wordmarkRise = 62;

  /// One cycle of a card-stack fan animation.
  static const Duration cardStackCycle = Duration(milliseconds: 3915);

  /// One sweep of a `ChameleonSkeleton`'s shimmer highlight.
  static const Duration shimmerSweep = Duration(milliseconds: 1200);
}
