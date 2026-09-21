import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

/// Generates every Android launcher-icon asset a Chameleon flavor needs from
/// one full-bleed source image — the legacy density set, a raster
/// adaptive-icon foreground (replacing `very_good_cli`'s default vector
/// one, which can't represent a flat branded PNG), and the Play Store
/// listing icon. Runs once per flavor at `chameleon create` time,
/// writing straight into the generated app's native `android/` tree — no
/// dependency is added to the generated app itself.
class AndroidIconGenerator {
  const AndroidIconGenerator();

  /// Legacy launcher icon densities, in px, keyed by Android's density
  /// bucket name — matches what `very_good_cli`'s own template ships.
  static const _legacyDensities = {
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
  };

  /// Adaptive-icon foreground canvas is 108dp at every density; content is
  /// inset ~18% per side to stay inside Android's safe-zone circle — matches
  /// the inset already baked into `very_good_cli`'s own default vector
  /// foreground's transform (`scale 0.0675`, `translate 19.44` on a 108dp/
  /// 1024-unit path).
  static const double _foregroundInset = 0.18;

  static const _adaptiveIconXml = '''
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
''';

  static const _backgroundColorXml = '''
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#F8F9FA</color>
</resources>
''';

  void generate({
    required String projectDir,
    required String flavor,
    required Uint8List sourceBytes,
  }) {
    final source = img.decodePng(sourceBytes);
    if (source == null) {
      throw StateError('Could not decode the default icon for "$flavor".');
    }

    final flavorDir = p.join(projectDir, 'android', 'app', 'src', flavor);
    final resDir = p.join(flavorDir, 'res');

    for (final entry in _legacyDensities.entries) {
      final density = entry.key;
      final size = entry.value;
      final mipmapDir = Directory(p.join(resDir, 'mipmap-$density'))
        ..createSync(recursive: true);

      final legacyIcon = img.encodePng(
        img.copyResize(
          source,
          width: size,
          height: size,
          interpolation: img.Interpolation.average,
        ),
      );
      File(
        p.join(mipmapDir.path, 'ic_launcher.png'),
      ).writeAsBytesSync(legacyIcon);
      File(
        p.join(mipmapDir.path, 'ic_launcher_round.png'),
      ).writeAsBytesSync(legacyIcon);

      // 108dp adaptive canvas scales with the same factor as the 48dp
      // legacy icon at this density (108 / 48 = 2.25, divides evenly).
      final adaptiveCanvasSize = size * 108 ~/ 48;
      final foreground = _adaptiveForeground(
        source,
        canvasSize: adaptiveCanvasSize,
      );
      File(
        p.join(mipmapDir.path, 'ic_launcher_foreground.png'),
      ).writeAsBytesSync(img.encodePng(foreground));
    }

    final anydpiDir = Directory(p.join(resDir, 'mipmap-anydpi-v26'))
      ..createSync(recursive: true);
    File(
      p.join(anydpiDir.path, 'ic_launcher.xml'),
    ).writeAsStringSync(_adaptiveIconXml);
    File(
      p.join(anydpiDir.path, 'ic_launcher_round.xml'),
    ).writeAsStringSync(_adaptiveIconXml);

    final valuesDir = Directory(p.join(resDir, 'values'))
      ..createSync(recursive: true);
    File(
      p.join(valuesDir.path, 'ic_launcher_background.xml'),
    ).writeAsStringSync(_backgroundColorXml);

    // Orphaned once the adaptive icon XML points at the raster foreground
    // above instead.
    final vectorForeground = File(
      p.join(resDir, 'drawable', 'ic_launcher_foreground.xml'),
    );
    if (vectorForeground.existsSync()) {
      vectorForeground.deleteSync();
    }

    final playstoreIcon = img.encodePng(
      img.copyResize(
        source,
        width: 512,
        height: 512,
        interpolation: img.Interpolation.average,
      ),
    );
    File(
      p.join(flavorDir, 'ic_launcher-playstore.png'),
    ).writeAsBytesSync(playstoreIcon);
  }

  img.Image _adaptiveForeground(img.Image source, {required int canvasSize}) {
    final canvas = img.Image(
      width: canvasSize,
      height: canvasSize,
      numChannels: 4,
    );
    final contentSize = (canvasSize * (1 - _foregroundInset * 2)).round();
    final content = img.copyResize(
      source,
      width: contentSize,
      height: contentSize,
      interpolation: img.Interpolation.average,
    );
    final offset = ((canvasSize - contentSize) / 2).round();
    return img.compositeImage(canvas, content, dstX: offset, dstY: offset);
  }
}
