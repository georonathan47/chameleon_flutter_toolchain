import 'package:flutter/material.dart';

/// An original, flat chameleon silhouette — Chameleon's loading/brand mark.
///
/// Drawn entirely with [Canvas]/[Path] primitives (no image or SVG asset): an
/// oval body, a rounded triangular head with a single dot eye, a tapered
/// spiral-curled tail, and a couple of small curved legs for character.
///
/// Used on its own as a static mark, or wrapped by `ChameleonSpinner` for
/// loading states.
class ChameleonMark extends StatelessWidget {
  const ChameleonMark({this.size = 48, this.color, super.key});

  /// Side of the (square) box the mark is painted into.
  final double size;

  /// Fill color of the silhouette. Defaults to the ambient [IconTheme]'s
  /// color, falling back to the current [ColorScheme.primary] when neither is
  /// set — this widget does not hardcode a design-token color so it stays
  /// reusable outside the Chameleon theme too.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor =
        color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ChameleonMarkPainter(resolvedColor)),
    );
  }
}

/// Paints [ChameleonMark]'s silhouette into a normalized `100 x 100` design
/// box, scaled uniformly to fit whatever size the parent provides.
class _ChameleonMarkPainter extends CustomPainter {
  const _ChameleonMarkPainter(this.color);

  final Color color;

  /// The design box the geometry below is authored against.
  static const double _designSize = 100;

  /// Center and radii of the body oval.
  static const Offset _bodyCenter = Offset(56, 54);
  static const double _bodyRadiusX = 26;
  static const double _bodyRadiusY = 17;

  @override
  void paint(Canvas canvas, Size size) {
    final fit = size.shortestSide / _designSize;
    final dx = (size.width - _designSize * fit) / 2;
    final dy = (size.height - _designSize * fit) / 2;

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color
      ..isAntiAlias = true;

    final eyeColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    final bodyRect = Rect.fromCenter(
      center: _bodyCenter,
      width: _bodyRadiusX * 2,
      height: _bodyRadiusY * 2,
    );

    canvas
      ..save()
      ..translate(dx, dy)
      ..scale(fit)
      // Tail first, so its straight closing edge sits behind the body.
      ..drawPath(_tailPath(), fill)
      // Body — the oval trunk.
      ..drawOval(bodyRect, fill)
      // Head — a rounded triangle overlapping the body's front (right) edge.
      ..drawPath(_headPath(), fill)
      // Legs — two short curved strokes under the belly.
      ..drawPath(_legsPath(), _legPaint())
      // Eye — a single contrasting dot on the head.
      ..drawCircle(const Offset(83, 42), 3.2, Paint()..color = eyeColor)
      ..restore();
  }

  /// A tapered, inward-curling hook: wide where it meets the body, narrowing
  /// to a point as it spirals under and back on itself.
  Path _tailPath() {
    return Path()
      ..moveTo(38, 46)
      // Outer edge: sweeps left and down from the body.
      ..quadraticBezierTo(10, 42, 6, 64)
      ..quadraticBezierTo(4, 80, 22, 78)
      // Inner edge: curls back up and returns to the body, narrower than the
      // outer sweep so the shape reads as a tapered curl rather than a band.
      ..quadraticBezierTo(16, 70, 18, 62)
      ..quadraticBezierTo(20, 48, 38, 58)
      ..close();
  }

  /// A rounded triangle: three vertices with the corners softened by curving
  /// through a point just short of each apex.
  Path _headPath() {
    const apex = Offset(96, 42);
    const top = Offset(70, 26);
    const bottom = Offset(70, 58);
    const cornerRadius = 6.0;

    // Points just short of each vertex, along the edge toward the named
    // neighbour — where each rounded corner's straight edge stops short.
    final topNearBottom = _pointToward(top, bottom, cornerRadius);
    final bottomNearTop = _pointToward(bottom, top, cornerRadius);
    final bottomNearApex = _pointToward(bottom, apex, cornerRadius);
    final apexNearBottom = _pointToward(apex, bottom, cornerRadius);
    final apexNearTop = _pointToward(apex, top, cornerRadius);
    final topNearApex = _pointToward(top, apex, cornerRadius);

    return Path()
      ..moveTo(topNearBottom.dx, topNearBottom.dy)
      // top -> bottom edge, softened at the "bottom" corner.
      ..lineTo(bottomNearTop.dx, bottomNearTop.dy)
      ..quadraticBezierTo(
        bottom.dx,
        bottom.dy,
        bottomNearApex.dx,
        bottomNearApex.dy,
      )
      // bottom -> apex edge, softened at the "apex" corner (the nose tip).
      ..lineTo(apexNearBottom.dx, apexNearBottom.dy)
      ..quadraticBezierTo(apex.dx, apex.dy, apexNearTop.dx, apexNearTop.dy)
      // apex -> top edge, softened at the "top" corner.
      ..lineTo(topNearApex.dx, topNearApex.dy)
      ..quadraticBezierTo(
        top.dx,
        top.dy,
        topNearBottom.dx,
        topNearBottom.dy,
      )
      ..close();
  }

  /// A point [distance] along the segment from [from] toward [to].
  static Offset _pointToward(Offset from, Offset to, double distance) {
    final delta = to - from;
    final length = delta.distance;
    if (length == 0) return from;
    return from + delta * (distance / length);
  }

  Path _legsPath() {
    return Path()
      ..moveTo(46, 68)
      ..quadraticBezierTo(42, 82, 52, 86)
      ..moveTo(64, 68)
      ..quadraticBezierTo(62, 82, 72, 86);
  }

  Paint _legPaint() => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5
    ..strokeCap = StrokeCap.round
    ..color = color;

  @override
  bool shouldRepaint(covariant _ChameleonMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
