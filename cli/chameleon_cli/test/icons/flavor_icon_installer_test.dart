import 'dart:io';

import 'package:chameleon_cli/src/icons/flavor_icon_installer.dart';
import 'package:chameleon_cli/src/icons/flavor_icon_sources.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('FlavorIconSources', () {
    test('every flavor icon decodes as a square 512x512 PNG', () {
      for (final bytes in [
        FlavorIconSources.development(),
        FlavorIconSources.staging(),
        FlavorIconSources.production(),
      ]) {
        final decoded = img.decodePng(bytes);
        expect(decoded, isNotNull);
        expect(decoded!.width, equals(decoded.height));
        expect(decoded.width, equals(512));
      }
    });
  });

  group('FlavorIconInstaller', () {
    test('installs all three flavors on both platforms', () {
      final projectDir = Directory.systemTemp.createTempSync(
        'flavor_icon_installer_test',
      );
      addTearDown(() => projectDir.deleteSync(recursive: true));

      const FlavorIconInstaller().installAll(projectDir.path);

      const androidFlavorDirs = ['development', 'staging', 'production'];
      for (final flavor in androidFlavorDirs) {
        expect(
          File(
            p.join(
              projectDir.path,
              'android',
              'app',
              'src',
              flavor,
              'res',
              'mipmap-mdpi',
              'ic_launcher.png',
            ),
          ).existsSync(),
          isTrue,
          reason: flavor,
        );
      }

      const iosBundles = {
        'AppIcon-dev.icon',
        'AppIcon-stg.icon',
        'AppIcon.icon',
      };
      for (final bundle in iosBundles) {
        final iconFile = File(
          p.join(
            projectDir.path,
            'ios',
            'Runner',
            'AppIcons',
            bundle,
            'Assets',
            'Icon.png',
          ),
        );
        expect(iconFile.existsSync(), isTrue, reason: bundle);

        // The 512x512 source is upscaled for iOS — confirm the installed
        // file actually is 1024x1024, not the raw un-upscaled source.
        final decoded = img.decodePng(iconFile.readAsBytesSync());
        expect(decoded, isNotNull, reason: bundle);
        expect(decoded!.width, equals(1024), reason: bundle);
        expect(decoded.height, equals(1024), reason: bundle);
      }
    });
  });
}
