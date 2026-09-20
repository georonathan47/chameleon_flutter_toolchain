import 'package:chameleon_cli/src/icons/chameleon_icon_painter.dart';
import 'package:image/image.dart' as img;
import 'package:test/test.dart';

void main() {
  group('paintChameleonIcon', () {
    test('decodes back to the requested square size', () {
      final bytes = paintChameleonIcon(
        size: 256,
        backgroundColor: ChameleonIconPainter.developmentBackground,
      );
      final decoded = img.decodePng(bytes);

      expect(decoded, isNotNull);
      expect(decoded!.width, equals(256));
      expect(decoded.height, equals(256));
    });

    test('the four corners are pure background, untouched by the glyph', () {
      const size = 256;
      final bytes = paintChameleonIcon(
        size: size,
        backgroundColor: ChameleonIconPainter.productionBackground,
      );
      final decoded = img.decodePng(bytes)!;

      final expectedBg = _rgbFromArgb(
        ChameleonIconPainter.productionBackground,
      );
      for (final corner in [
        (0, 0),
        (size - 1, 0),
        (0, size - 1),
        (size - 1, size - 1),
      ]) {
        final pixel = decoded.getPixel(corner.$1, corner.$2);
        expect(
          (pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()),
          equals(expectedBg),
          reason: 'corner $corner',
        );
      }
    });

    test('the body center samples the ink color', () {
      const size = 512;
      final bytes = paintChameleonIcon(
        size: size,
        backgroundColor: ChameleonIconPainter.developmentBackground,
      );
      final decoded = img.decodePng(bytes)!;

      final x = (size * ChameleonIconGeometry.bodyCenterXFraction).round();
      final y = (size * ChameleonIconGeometry.bodyCenterYFraction).round();
      final pixel = decoded.getPixel(x, y);
      final expectedInk = _rgbFromArgb(ChameleonIconPainter.inkColor);

      expect(
        (pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()),
        equals(expectedInk),
      );
    });

    test('the eye pupil center samples ink over a background-colored sclera '
        'ring', () {
      const size = 512;
      final bytes = paintChameleonIcon(
        size: size,
        backgroundColor: ChameleonIconPainter.stagingBackground,
      );
      final decoded = img.decodePng(bytes)!;

      final eyeX = (size * ChameleonIconGeometry.eyeCenterXFraction).round();
      final eyeY = (size * ChameleonIconGeometry.eyeCenterYFraction).round();
      final expectedInk = _rgbFromArgb(ChameleonIconPainter.inkColor);
      final pupilPixel = decoded.getPixel(eyeX, eyeY);
      expect(
        (pupilPixel.r.toInt(), pupilPixel.g.toInt(), pupilPixel.b.toInt()),
        equals(expectedInk),
        reason: 'pupil center should be ink-colored',
      );

      // Just outside the pupil but still inside the sclera disc: background
      // color shows through.
      final scleraRadius =
          (size * ChameleonIconGeometry.eyeOuterRadiusFraction).round();
      final scleraOffset = (scleraRadius * 0.7).round();
      final scleraPixel = decoded.getPixel(eyeX + scleraOffset, eyeY);
      final expectedBg = _rgbFromArgb(ChameleonIconPainter.stagingBackground);
      expect(
        (scleraPixel.r.toInt(), scleraPixel.g.toInt(), scleraPixel.b.toInt()),
        equals(expectedBg),
        reason: 'sclera ring should show the flavor background color',
      );
    });

    test('every flavor helper produces a distinct background', () {
      final dev = img.decodePng(ChameleonIconPainter.development())!;
      final stg = img.decodePng(ChameleonIconPainter.staging())!;
      final prod = img.decodePng(ChameleonIconPainter.production())!;

      expect(dev.getPixel(0, 0).r.toInt(), equals(0xD3));
      expect(stg.getPixel(0, 0).b.toInt(), equals(0xE5));
      expect(prod.getPixel(0, 0).r.toInt(), equals(0xF8));
    });
  });
}

(int, int, int) _rgbFromArgb(int argb) =>
    ((argb >> 16) & 0xFF, (argb >> 8) & 0xFF, argb & 0xFF);
