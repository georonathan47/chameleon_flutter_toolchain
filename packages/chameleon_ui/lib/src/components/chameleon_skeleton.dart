import 'package:flutter/material.dart';

import '../theme/chameleon_semantic_colors_extension.dart';
import '../tokens/chameleon_motion.dart';
import '../tokens/chameleon_spacing.dart';
import 'loader/chameleon_spinner.dart';

/// A shimmering placeholder for content that's still loading in place — a
/// list item, a card — avoiding the layout jump a centered
/// [ChameleonSpinner] causes when it's replaced by real content.
///
/// Self-contained: no third-party shimmer package, just a [ShaderMask]
/// sweeping a [LinearGradient] highlight across a base-colored box, driven
/// by [ChameleonMotion.shimmerSweep].
///
/// Three shapes, matching what a skeleton usually stands in for:
///
/// ```dart
/// ChameleonSkeleton.circle(size: 40),       // an avatar
/// ChameleonSkeleton.textLine(width: 120),   // a line of text
/// ChameleonSkeleton.rect(width: 200, height: 80), // a card/image
/// ```
class ChameleonSkeleton extends StatefulWidget {
  const ChameleonSkeleton.rect({
    this.width,
    this.height = 16,
    this.borderRadius = ChameleonRadius.md,
    super.key,
  }) : shape = BoxShape.rectangle;

  const ChameleonSkeleton.circle({required double size, super.key})
    : width = size,
      height = size,
      shape = BoxShape.circle,
      borderRadius = 0;

  const ChameleonSkeleton.textLine({this.width, super.key})
    : height = 12,
      shape = BoxShape.rectangle,
      borderRadius = ChameleonRadius.sm;

  /// Omit to fill the available width in a bounded parent (e.g.
  /// [Expanded], a fixed-width [SizedBox]).
  final double? width;
  final double height;
  final BoxShape shape;
  final double borderRadius;

  @override
  State<ChameleonSkeleton> createState() => _ChameleonSkeletonState();
}

class _ChameleonSkeletonState extends State<ChameleonSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: ChameleonMotion.shimmerSweep,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(
          context,
        ).extension<ChameleonSemanticColorsExtension>() ??
        ChameleonSemanticColorsExtension.light;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                colors.skeletonBase,
                colors.skeletonHighlight,
                colors.skeletonBase,
              ],
              stops: const [0.35, 0.5, 0.65],
              // Slides the highlight band from fully off-screen-left to
              // fully off-screen-right (a 3x sweep, so it re-enters clean
              // on loop) — the same technique the `shimmer` package uses,
              // implemented here directly rather than taken as a
              // dependency. `_controller.value` isn't a compile-time
              // constant, so this whole gradient can't be `const`.
              transform: _SlidingGradientTransform(
                slidePercent: _controller.value,
              ),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: colors.skeletonBase,
          shape: widget.shape,
          borderRadius: widget.shape == BoxShape.rectangle
              ? BorderRadius.circular(widget.borderRadius)
              : null,
        ),
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  /// 0 to 1 over one sweep; mapped to a -1..2 translation below so the
  /// highlight starts fully off-screen-left and ends fully off-screen-right.
  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final offset = (slidePercent * 3) - 1;
    return Matrix4.translationValues(bounds.width * offset, 0, 0);
  }
}
