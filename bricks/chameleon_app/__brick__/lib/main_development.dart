import 'dart:async';

import 'package:chameleon_core/chameleon_core.dart';

import 'app/app.dart';
import 'bootstrap.dart';

void main() {
  FlavorConfig.initialize(
    flavor: Flavor.dev,
    name: 'DEV',
    bannerColor: 0xFFD32F2F,
  );

  unawaited(bootstrap(() => const App()));
}
