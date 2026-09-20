import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../tokens/chameleon_colors.dart';

/// A frosted-glass surface: a blurred, tinted, softly-bordered container with
/// painted highlight/shadow edges to sell the "glass" read.
class GlobalGlassSurface extends StatelessWidget {
  const GlobalGlassSurface({
    required this.fillColor,
    required this.borderRadius,
    required this.child,
    this.blurSigma = 10,
    this.borderColor,
    this.borderWidth = 0.8,
    this.boxShadows,
    this.showHighlights = true,
    this.onTap,
    super.key,
  });

  final Color fillColor;
  final BorderRadius borderRadius;
  final Widget child;
  final double blurSigma;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadows;
  final bool showHighlights;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow:
            boxShadows ??
            [
              BoxShadow(
                color: ChameleonColors.white.withValues(alpha: 0.48),
                blurRadius: 28,
                offset: const Offset(-12, -12),
              ),
              BoxShadow(
                color: ChameleonColors.black.withValues(alpha: 0.055),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: ChameleonColors.black.withValues(alpha: 0.085),
                blurRadius: 36,
                offset: const Offset(12, 20),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: CustomPaint(
            foregroundPainter: showHighlights
                ? _GlassHighlightPainter(borderRadius)
                : null,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: fillColor,
                border: Border.all(
                  color: borderColor ??
                      ChameleonColors.white.withValues(alpha: 0.34),
                  width: borderWidth,
                ),
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ChameleonColors.white.withValues(alpha: 0.58),
                    fillColor,
                    ChameleonColors.white.withValues(alpha: 0.16),
                  ],
                  stops: const [0, 0.46, 1],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: borderRadius,
                  onTap: onTap,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassHighlightPainter extends CustomPainter {
  const _GlassHighlightPainter(this.borderRadius);

  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = borderRadius.topLeft.x;
    final highlight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round
      ..color = ChameleonColors.white.withValues(alpha: 0.92)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.65);
    final edgeShadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.55
      ..strokeCap = StrokeCap.round
      ..color = ChameleonColors.black.withValues(alpha: 0.11)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.9);

    if (radius >= size.shortestSide / 2) {
      final oval = Rect.fromLTWH(1.2, 1.2, size.width - 2.4, size.height - 2.4);
      canvas
        ..drawArc(
          oval,
          math.pi * 1.08,
          math.pi * 0.62,
          false,
          highlight,
        )
        ..drawArc(
          oval,
          math.pi * 0.08,
          math.pi * 0.48,
          false,
          edgeShadow,
        );
      return;
    }

    final highlightPath = Path()
      ..moveTo(1.2, radius)
      ..quadraticBezierTo(1.2, 1.2, radius, 1.2)
      ..lineTo(size.width - (radius * 0.28), 1.2);
    canvas.drawPath(highlightPath, highlight);

    final shadowPath = Path()
      ..moveTo(size.width - 1.2, radius * 0.55)
      ..lineTo(size.width - 1.2, size.height - radius)
      ..quadraticBezierTo(
        size.width - 1.2,
        size.height - 1.2,
        size.width - radius,
        size.height - 1.2,
      )
      ..lineTo(radius * 0.65, size.height - 1.2);
    canvas.drawPath(shadowPath, edgeShadow);
  }

  @override
  bool shouldRepaint(covariant _GlassHighlightPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius;
  }
}
