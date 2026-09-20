import 'dart:async';

import 'package:chameleon_core/chameleon_core.dart';

import 'app/app.dart';
import 'bootstrap.dart';

void main() {
  FlavorConfig.initialize(
    flavor: Flavor.prod,
    name: 'PROD',
    bannerColor: 0x00000000,
  );

  unawaited(bootstrap(() => const App()));
}
