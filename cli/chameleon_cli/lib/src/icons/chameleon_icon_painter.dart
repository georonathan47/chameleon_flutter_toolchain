import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Layout fractions (of the square canvas side) the chameleon glyph is
/// drawn from — pulled out as named constants, rather than inlined magic
/// numbers, so `chameleon_icon_painter_test.dart` can sample exact pixel
/// coordinates instead of guessing where the glyph ended up.
abstract final class ChameleonIconGeometry {
  /// Body ellipse center, as a fraction of the canvas side.
  static const double bodyCenterXFraction = 0.46;
  static const double bodyCenterYFraction = 0.56;

  /// Body ellipse semi-axes, as a fraction of the canvas side.
  static const double bodyRadiusXFraction = 0.24;
  static const double bodyRadiusYFraction = 0.16;

  /// Body tilt, in radians — gives the silhouette a diagonal, mid-stride
  /// lean instead of sitting bolt upright.
  static const double bodyRotation = -0.35;

  /// Tail spiral center and starting radius, as fractions of the canvas
  /// side. The spiral winds inward from [tailStartRadiusFraction] toward
  /// the center as its angle sweeps through [tailTurns] full turns.
  static const double tailCenterXFraction = 0.20;
  static const double tailCenterYFraction = 0.68;
  static const double tailStartRadiusFraction = 0.16;
  static const double tailTurns = 1.6;

  /// Head vertices, as fractions of the canvas side — four points instead
  /// of a sharp triangle's three, so the snout tip reads as blunt/rounded
  /// rather than needle-pointed.
  static const double headTopXFraction = 0.62;
  static const double headTopYFraction = 0.30;
  static const double headNoseXFraction = 0.86;
  static const double headNoseYFraction = 0.42;
  static const double headChinXFraction = 0.68;
  static const double headChinYFraction = 0.58;
  static const double headBackXFraction = 0.58;
  static const double headBackYFraction = 0.52;

  /// Eye center and radii, as fractions of the canvas side. The eye is
  /// drawn as an outer disc in the *background* color (so it reads as an
  /// eye against the ink-colored head on every flavor background) with a
  /// smaller ink-colored pupil centered on top of it.
  static const double eyeCenterXFraction = 0.66;
  static const double eyeCenterYFraction = 0.36;
  static const double eyeOuterRadiusFraction = 0.045;
  static const double eyePupilRadiusFraction = 0.020;
}

/// Procedurally draws Chameleon's default app-icon glyph — one flat
/// chameleon silhouette (a spiral tail, an oval body, a blunt triangular
/// head, and a dot eye) in a single fixed "ink" color, over a flavor-
/// specific background fill.
///
/// Replaces the baked PNG artwork the source CLI (`calbank_cli`) shipped as
/// a 463KB base64 blob in `flavor_icon_sources.dart` — this toolchain has no
/// brand artwork to bake in, and this package is pure Dart with no access to
/// `dart:ui`/`Canvas`, so the glyph is built entirely from
/// `package:image`'s raster primitives (`fillPolygon`, `fillCircle`,
/// `drawLine`) instead. `package:image` has no bezier/arc path API, so the
/// tail's spiral is produced by sampling a polar parametric curve
/// (`r` shrinking as `theta` sweeps through 1.6 turns) into a point cloud
/// and connecting consecutive samples with short, tapering `drawLine`
/// segments — the same "flatten the curve, then draw straight segments"
/// technique vector renderers use internally, done by hand since nothing
/// here does it automatically.
abstract final class ChameleonIconPainter {
  /// Fixed square resolution every generated icon is drawn at, before the
  /// Android/iOS installers downsample it per density and platform. The
  /// source CLI's baked PNGs happened to be 1548×1548 — an arbitrary
  /// designer export size (nothing in that codebase treats 1548 as
  /// meaningful), so there is no dimension to match here. 1024 is used
  /// instead: a clean size at least as large as the biggest asset either
  /// platform actually asks for (Android's Play Store listing icon at 512,
  /// iOS Icon Composer bundles), so every downstream `copyResize` call only
  /// ever shrinks, never enlarges.
  static const int canvasSize = 1024;

  /// Chameleon's default "ink" color the glyph itself is always drawn in,
  /// regardless of flavor — a dark, slightly green-leaning charcoal, in the
  /// same neighborhood as `chameleon_ui`'s neutral tokens
  /// (`ChameleonColors.grey900` = `0xFF181A1B`, `grey860` = `0xFF1A1C1E`)
  /// but not copied from either: this CLI is a pure-Dart package and cannot
  /// depend on the Flutter `chameleon_ui` package, so this is an
  /// independently-chosen literal, documented here rather than imported.
  static const int inkColor = 0xFF2E3A33;

  /// Dev flavor background — the same literal `main_development.dart`
  /// passes to `FlavorConfig.initialize(bannerColor: ...)`. Keep this in
  /// sync by inspection if that file's banner color ever changes.
  static const int developmentBackground = 0xFFD32F2F;

  /// Staging flavor background — the same literal `main_staging.dart`
  /// passes to `FlavorConfig.initialize(bannerColor: ...)`.
  static const int stagingBackground = 0xFF1E88E5;

  /// Production has no debug banner to mirror ("no color" is the point of
  /// the prod banner), and an app icon can't literally be transparent
  /// (both app stores require full opacity), so this neutral off-white is
  /// the closest honest equivalent — it is also the exact neutral the
  /// Android adaptive-icon background XML already used for every flavor's
  /// icon (`#F8F9FA`, see `AndroidIconGenerator._backgroundColorXml`).
  static const int productionBackground = 0xFFF8F9FA;

  static Uint8List development() => paintChameleonIcon(
    size: canvasSize,
    backgroundColor: developmentBackground,
  );

  static Uint8List staging() =>
      paintChameleonIcon(size: canvasSize, backgroundColor: stagingBackground);

  static Uint8List production() => paintChameleonIcon(
    size: canvasSize,
    backgroundColor: productionBackground,
  );
}

/// Draws the chameleon glyph at `size`x`size` over a solid [backgroundColor]
/// fill and returns encoded PNG bytes. [backgroundColor] and [inkColor] are
/// both `0xAARRGGBB` ints (the same shape as Flutter's `Color.value`), so
/// callers can pass a literal without this pure-Dart package depending on
/// `dart:ui`.
Uint8List paintChameleonIcon({
  required int size,
  required int backgroundColor,
  int inkColor = ChameleonIconPainter.inkColor,
}) {
  final canvas = img.Image(width: size, height: size, numChannels: 4);
  final background = _colorFromArgb(backgroundColor);
  final ink = _colorFromArgb(inkColor);
  img.fill(canvas, color: background);

  // Tail first, so the body's rear overlaps the spiral's outermost coil —
  // matches a chameleon's tail curling out from under its body rather than
  // sitting on top of it.
  _drawTail(canvas, size, ink);
  _drawBody(canvas, size, ink);
  _drawHead(canvas, size, ink, background);

  return Uint8List.fromList(img.encodePng(canvas));
}

img.ColorRgba8 _colorFromArgb(int argb) => img.ColorRgba8(
  (argb >> 16) & 0xFF,
  (argb >> 8) & 0xFF,
  argb & 0xFF,
  (argb >> 24) & 0xFF,
);

void _drawTail(img.Image canvas, int size, img.ColorRgba8 ink) {
  final centerX = size * ChameleonIconGeometry.tailCenterXFraction;
  final centerY = size * ChameleonIconGeometry.tailCenterYFraction;
  final startRadius = size * ChameleonIconGeometry.tailStartRadiusFraction;
  final baseThickness = size * 0.05;
  const steps = 120;

  img.Point? previous;
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    final angle = t * ChameleonIconGeometry.tailTurns * 2 * math.pi;
    // Shrinks toward the spiral center as t -> 1, leaving a small non-zero
    // radius so the tail tapers to a point rather than snapping to it.
    final radius = startRadius * (1 - t) + size * 0.006;
    final point = img.Point(
      centerX + radius * math.cos(angle),
      centerY + radius * math.sin(angle),
    );
    if (previous != null) {
      img.drawLine(
        canvas,
        x1: previous.xi,
        y1: previous.yi,
        x2: point.xi,
        y2: point.yi,
        color: ink,
        thickness: baseThickness * (1 - t * 0.65),
        antialias: true,
      );
    }
    previous = point;
  }
}

void _drawBody(img.Image canvas, int size, img.ColorRgba8 ink) {
  final cx = size * ChameleonIconGeometry.bodyCenterXFraction;
  final cy = size * ChameleonIconGeometry.bodyCenterYFraction;
  final rx = size * ChameleonIconGeometry.bodyRadiusXFraction;
  final ry = size * ChameleonIconGeometry.bodyRadiusYFraction;
  const rotation = ChameleonIconGeometry.bodyRotation;
  const segments = 48;

  final vertices = <img.Point>[
    for (var i = 0; i < segments; i++)
      _ellipsePoint(
        cx: cx,
        cy: cy,
        rx: rx,
        ry: ry,
        rotation: rotation,
        t: (i / segments) * 2 * math.pi,
      ),
  ];
  img.fillPolygon(canvas, vertices: vertices, color: ink);
}

img.Point _ellipsePoint({
  required double cx,
  required double cy,
  required double rx,
  required double ry,
  required double rotation,
  required double t,
}) {
  final ex = rx * math.cos(t);
  final ey = ry * math.sin(t);
  final cosR = math.cos(rotation);
  final sinR = math.sin(rotation);
  return img.Point(
    cx + ex * cosR - ey * sinR,
    cy + ex * sinR + ey * cosR,
  );
}

void _drawHead(
  img.Image canvas,
  int size,
  img.ColorRgba8 ink,
  img.ColorRgba8 sclera,
) {
  final vertices = [
    img.Point(
      size * ChameleonIconGeometry.headTopXFraction,
      size * ChameleonIconGeometry.headTopYFraction,
    ),
    img.Point(
      size * ChameleonIconGeometry.headNoseXFraction,
      size * ChameleonIconGeometry.headNoseYFraction,
    ),
    img.Point(
      size * ChameleonIconGeometry.headChinXFraction,
      size * ChameleonIconGeometry.headChinYFraction,
    ),
    img.Point(
      size * ChameleonIconGeometry.headBackXFraction,
      size * ChameleonIconGeometry.headBackYFraction,
    ),
  ];
  img.fillPolygon(canvas, vertices: vertices, color: ink);

  final eyeX = (size * ChameleonIconGeometry.eyeCenterXFraction).round();
  final eyeY = (size * ChameleonIconGeometry.eyeCenterYFraction).round();

  // Outer "sclera" punched through to the background color, so the eye
  // reads as an eye against the ink head regardless of flavor background —
  // then a smaller ink pupil centered on top of it for definition.
  img.fillCircle(
    canvas,
    x: eyeX,
    y: eyeY,
    radius: (size * ChameleonIconGeometry.eyeOuterRadiusFraction).round(),
    color: sclera,
    antialias: true,
  );
  img.fillCircle(
    canvas,
    x: eyeX,
    y: eyeY,
    radius: (size * ChameleonIconGeometry.eyePupilRadiusFraction).round(),
    color: ink,
    antialias: true,
  );
}
