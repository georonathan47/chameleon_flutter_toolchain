import 'dart:io';

import 'package:chameleon_cli/src/icons/chameleon_icon_painter.dart';
import 'package:chameleon_cli/src/icons/flavor_icon_installer.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('ChameleonIconPainter', () {
    test('every flavor icon decodes as a square PNG', () {
      for (final bytes in [
        ChameleonIconPainter.development(),
        ChameleonIconPainter.staging(),
        ChameleonIconPainter.production(),
      ]) {
        final decoded = img.decodePng(bytes);
        expect(decoded, isNotNull);
        expect(decoded!.width, equals(decoded.height));
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
        expect(
          File(
            p.join(
              projectDir.path,
              'ios',
              'Runner',
              'AppIcons',
              bundle,
              'Assets',
              'Icon.png',
            ),
          ).existsSync(),
          isTrue,
          reason: bundle,
        );
      }
    });
  });
}
