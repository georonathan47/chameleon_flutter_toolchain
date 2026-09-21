import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'android_icon_generator.dart';
import 'flavor_icon_sources.dart';
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

  /// `FlavorIconSources`' artwork is 512x512 — plenty for every Android
  /// target (Play Store's 512 icon included) but soft if written directly
  /// as iOS's Icon Composer layer, which is commonly authored at 1024x1024.
  /// Upscaled once here, iOS-only, rather than changing the source art
  /// itself or Android's (correctly un-upscaled) legacy/adaptive/Play Store
  /// outputs.
  static const int _iosIconSize = 1024;

  void installAll(String projectDir) {
    final sourcesByFlavor = <String, Uint8List>{
      'development': FlavorIconSources.development(),
      'staging': FlavorIconSources.staging(),
      'production': FlavorIconSources.production(),
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
        sourceBytes: _upscaledForIos(sourceBytes),
      );
    }
  }

  Uint8List _upscaledForIos(Uint8List sourceBytes) {
    final source = img.decodePng(sourceBytes);
    if (source == null) {
      throw StateError('Could not decode a flavor icon source image.');
    }
    if (source.width >= _iosIconSize && source.height >= _iosIconSize) {
      return sourceBytes;
    }
    return img.encodePng(
      img.copyResize(
        source,
        width: _iosIconSize,
        height: _iosIconSize,
        interpolation: img.Interpolation.cubic,
      ),
    );
  }
}
