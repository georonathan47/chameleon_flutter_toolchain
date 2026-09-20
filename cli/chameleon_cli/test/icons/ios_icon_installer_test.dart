import 'dart:io';
import 'dart:typed_data';

import 'package:chameleon_cli/src/icons/ios_icon_installer.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('IosIconInstaller', () {
    late Directory projectDir;

    setUp(() {
      projectDir = Directory.systemTemp.createTempSync(
        'ios_icon_installer_test',
      );
    });

    tearDown(() {
      projectDir.deleteSync(recursive: true);
    });

    void seedDefaultBundle(String bundleName, List<String> defaultAssets) {
      final assetsDir = Directory(
        p.join(
          projectDir.path,
          'ios',
          'Runner',
          'AppIcons',
          bundleName,
          'Assets',
        ),
      )..createSync(recursive: true);
      for (final asset in defaultAssets) {
        File(p.join(assetsDir.path, asset)).writeAsStringSync('default');
      }
    }

    test(
      'installs Icon.png + icon.json and removes orphaned dev-flavor layers',
      () {
        seedDefaultBundle('AppIcon-dev.icon', [
          'Logo.svg',
          'Flag.png',
          'Environment.png',
        ]);

        const IosIconInstaller().install(
          projectDir: projectDir.path,
          flavor: 'development',
          sourceBytes: Uint8List.fromList([1, 2, 3]),
        );

        final bundleDir = p.join(
          projectDir.path,
          'ios',
          'Runner',
          'AppIcons',
          'AppIcon-dev.icon',
        );
        expect(
          File(p.join(bundleDir, 'Assets', 'Icon.png')).readAsBytesSync(),
          equals([1, 2, 3]),
        );
        final iconJson = File(
          p.join(bundleDir, 'icon.json'),
        ).readAsStringSync();
        expect(iconJson, contains('"image-name" : "Icon.png"'));
        expect(iconJson, contains('"appearance" : "dark"'));

        for (final orphan in ['Logo.svg', 'Flag.png', 'Environment.png']) {
          expect(
            File(p.join(bundleDir, 'Assets', orphan)).existsSync(),
            isFalse,
            reason: orphan,
          );
        }
      },
    );

    test('installs into the production bundle without a flavor suffix', () {
      seedDefaultBundle('AppIcon.icon', ['Logo.svg']);

      const IosIconInstaller().install(
        projectDir: projectDir.path,
        flavor: 'production',
        sourceBytes: Uint8List.fromList([9]),
      );

      final bundleDir = p.join(
        projectDir.path,
        'ios',
        'Runner',
        'AppIcons',
        'AppIcon.icon',
      );
      expect(
        File(p.join(bundleDir, 'Assets', 'Icon.png')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(bundleDir, 'Assets', 'Logo.svg')).existsSync(),
        isFalse,
      );
    });

    test('rejects an unknown flavor', () {
      expect(
        () => const IosIconInstaller().install(
          projectDir: projectDir.path,
          flavor: 'nope',
          sourceBytes: Uint8List.fromList([1]),
        ),
        throwsArgumentError,
      );
    });
  });
}
