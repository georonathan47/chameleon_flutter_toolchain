import 'dart:async';

import 'package:chameleon_core/chameleon_core.dart';

import 'app/app.dart';
import 'bootstrap.dart';

void main() {
  FlavorConfig.initialize(
    flavor: Flavor.stg,
    name: 'STG',
    // Matches the gold "STG" ribbon in the default staging app icon
    // (cli/chameleon_cli/lib/src/icons/flavor_icon_sources.dart).
    bannerColor: 0xFFEFBF04,
  );

  unawaited(bootstrap(() => const App()));
}
