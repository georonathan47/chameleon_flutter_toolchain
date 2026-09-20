import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

/// Installs a Chameleon flavor's default icon into `very_good_cli`'s Apple
/// **Icon Composer** `.icon` bundle (Xcode 26+'s `icon.json` + `Assets/`
/// format, which bundles light/dark/tinted appearance in one file — dark
/// mode is auto-derived from the single layer below via `"automatic"`, the
/// same mechanism the bundle already used for its default artwork).
///
/// `very_good_cli`'s dev/stg bundles ship separate Logo/Flag/Environment
/// layers (their own ribbon-drawing mechanism); Chameleon's source images
/// already have the ribbon baked in as one flat image, so every flavor is
/// normalized to production's proven single-layer schema instead of trying
/// to decompose a flat image into that layered structure.
class IosIconInstaller {
  const IosIconInstaller();

  static const _bundleNameByFlavor = {
    'development': 'AppIcon-dev.icon',
    'staging': 'AppIcon-stg.icon',
    'production': 'AppIcon.icon',
  };

  /// Default per-flavor layer files `very_good_cli` ships that become
  /// orphaned once [_iconJson] replaces them with a single `Icon.png` layer.
  static const Map<String, List<String>> _orphanedAssetsByFlavor = {
    'development': ['Logo.svg', 'Flag.png', 'Environment.png'],
    'staging': ['Logo.svg', 'Flag.png', 'Environment.png'],
    'production': ['Logo.svg'],
  };

  static const _iconJson = '''
{
  "fill-specializations" : [
    {
      "value" : "automatic"
    },
    {
      "appearance" : "dark",
      "value" : "automatic"
    }
  ],
  "groups" : [
    {
      "blur-material" : 0.5,
      "layers" : [
        {
          "fill-specializations" : [
            {
              "appearance" : "dark",
              "value" : {
                "solid" : "extended-gray:1.00000,1.00000"
              }
            },
            {
              "appearance" : "tinted",
              "value" : {
                "solid" : "extended-gray:1.00000,1.00000"
              }
            }
          ],
          "glass" : false,
          "image-name" : "Icon.png",
          "name" : "Icon",
          "position" : {
            "scale" : 1.0,
            "translation-in-points" : [
              0,
              0
            ]
          }
        }
      ],
      "lighting" : "individual",
      "shadow" : {
        "kind" : "neutral",
        "opacity" : 0.5
      },
      "specular" : true,
      "translucency" : {
        "enabled" : true,
        "value" : 0.5
      }
    }
  ],
  "supported-platforms" : {
    "squares" : "shared"
  }
}
''';

  void install({
    required String projectDir,
    required String flavor,
    required Uint8List sourceBytes,
  }) {
    final bundleName = _bundleNameByFlavor[flavor];
    if (bundleName == null) {
      throw ArgumentError.value(flavor, 'flavor', 'Unknown flavor.');
    }

    final bundleDir = p.join(
      projectDir,
      'ios',
      'Runner',
      'AppIcons',
      bundleName,
    );
    final assetsDir = Directory(p.join(bundleDir, 'Assets'))
      ..createSync(recursive: true);

    File(p.join(assetsDir.path, 'Icon.png')).writeAsBytesSync(sourceBytes);
    File(p.join(bundleDir, 'icon.json')).writeAsStringSync(_iconJson);

    for (final orphan in _orphanedAssetsByFlavor[flavor] ?? const <String>[]) {
      final file = File(p.join(assetsDir.path, orphan));
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }
}
