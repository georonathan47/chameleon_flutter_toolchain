import 'dart:io';
import 'dart:typed_data';

import 'package:chameleon_cli/src/icons/android_icon_generator.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

Uint8List _syntheticSourcePng() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);
  img.fill(image, color: img.ColorRgba8(255, 209, 0, 255));
  return img.encodePng(image);
}

void main() {
  group('AndroidIconGenerator', () {
    late Directory projectDir;

    setUp(() {
      projectDir = Directory.systemTemp.createTempSync(
        'android_icon_generator_test',
      );
    });

    tearDown(() {
      projectDir.deleteSync(recursive: true);
    });

    test('writes the full legacy + adaptive + playstore icon set', () {
      final resDir = p.join(
        projectDir.path,
        'android',
        'app',
        'src',
        'development',
        'res',
      );
      // Seed the default `very_good_cli` vector foreground this replaces.
      final vectorForegroundDir = Directory(p.join(resDir, 'drawable'))
        ..createSync(recursive: true);
      File(
        p.join(vectorForegroundDir.path, 'ic_launcher_foreground.xml'),
      ).writeAsStringSync('<vector/>');

      const AndroidIconGenerator().generate(
        projectDir: projectDir.path,
        flavor: 'development',
        sourceBytes: _syntheticSourcePng(),
      );

      const densities = {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
      };
      for (final entry in densities.entries) {
        final mipmapDir = p.join(resDir, 'mipmap-${entry.key}');
        for (final name in [
          'ic_launcher.png',
          'ic_launcher_round.png',
          'ic_launcher_foreground.png',
        ]) {
          final file = File(p.join(mipmapDir, name));
          expect(file.existsSync(), isTrue, reason: '$mipmapDir/$name');
        }

        final decoded = img.decodePng(
          File(p.join(mipmapDir, 'ic_launcher.png')).readAsBytesSync(),
        )!;
        expect(decoded.width, equals(entry.value));
        expect(decoded.height, equals(entry.value));

        final foreground = img.decodePng(
          File(
            p.join(mipmapDir, 'ic_launcher_foreground.png'),
          ).readAsBytesSync(),
        )!;
        expect(foreground.width, equals(entry.value * 108 ~/ 48));
      }

      final adaptiveXml = File(
        p.join(resDir, 'mipmap-anydpi-v26', 'ic_launcher.xml'),
      ).readAsStringSync();
      expect(adaptiveXml, contains('@mipmap/ic_launcher_foreground'));
      expect(adaptiveXml, isNot(contains('@drawable/ic_launcher_foreground')));

      final backgroundXml = File(
        p.join(resDir, 'values', 'ic_launcher_background.xml'),
      ).readAsStringSync();
      expect(backgroundXml, contains('#F8F9FA'));

      expect(
        File(
          p.join(resDir, 'drawable', 'ic_launcher_foreground.xml'),
        ).existsSync(),
        isFalse,
        reason: 'orphaned vector foreground should be deleted',
      );

      final playstoreIcon = img.decodePng(
        File(
          p.join(
            projectDir.path,
            'android',
            'app',
            'src',
            'development',
            'ic_launcher-playstore.png',
          ),
        ).readAsBytesSync(),
      )!;
      expect(playstoreIcon.width, equals(512));
      expect(playstoreIcon.height, equals(512));
    });
  });
}
