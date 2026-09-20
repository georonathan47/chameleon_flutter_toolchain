import 'dart:typed_data';

import 'android_icon_generator.dart';
import 'chameleon_icon_painter.dart';
import 'ios_icon_installer.dart';

/// Installs Chameleon's default per-flavor app icons (Android + iOS) into a
/// freshly-scaffolded project. The single entry point `FlutterCreateCommand`
/// calls right after `very_good create` populates the native `android/`/
/// `ios/` trees it writes into.
class FlavorIconInstaller {
  const FlavorIconInstaller({
    this.android = const AndroidIconGenerator(),
    this.ios = const IosIconInstaller(),
  });

  final AndroidIconGenerator android;
  final IosIconInstaller ios;

  void installAll(String projectDir) {
    final sourcesByFlavor = <String, Uint8List>{
      'development': ChameleonIconPainter.development(),
      'staging': ChameleonIconPainter.staging(),
      'production': ChameleonIconPainter.production(),
    };

    for (final MapEntry(key: flavor, value: sourceBytes)
        in sourcesByFlavor.entries) {
      android.generate(
        projectDir: projectDir,
        flavor: flavor,
        sourceBytes: sourceBytes,
      );
      ios.install(
        projectDir: projectDir,
        flavor: flavor,
        sourceBytes: sourceBytes,
      );
    }
  }
}
