import 'package:flutter/material.dart';

/// Wraps [child] in a diagonal ribbon identifying a non-production build.
///
/// A design-system package must not know what a "flavor" is, so this widget
/// takes the ribbon's [label], [color], and [location] as plain constructor
/// arguments instead of reading an app-level flavor singleton — the app
/// decides those from its own flavor config and passes `shown: false` (or
/// simply doesn't wrap with this widget) in production.
class FlavorBanner extends StatelessWidget {
  const FlavorBanner({
    required this.child,
    this.label,
    this.color,
    this.location = BannerLocation.bottomEnd,
    this.shown = true,
    super.key,
  });

  final Widget child;

  /// Text on the ribbon, e.g. `'DEV'`. Ignored when [shown] is `false`.
  final String? label;

  /// Ribbon color. Ignored when [shown] is `false`.
  final Color? color;

  /// Corner the ribbon is anchored to.
  final BannerLocation location;

  /// Whether to draw the ribbon at all. Pass `false` in production instead of
  /// omitting this widget, so call sites don't need a conditional wrapper.
  final bool shown;

  @override
  Widget build(BuildContext context) {
    if (!shown || label == null || color == null) return child;

    return Banner(
      message: label!,
      color: color!,
      location: location,
      child: child,
    );
  }
}
