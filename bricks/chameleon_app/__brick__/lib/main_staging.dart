import 'dart:async';

import 'package:chameleon_core/chameleon_core.dart';

import 'app/app.dart';
import 'bootstrap.dart';

void main() {
  FlavorConfig.initialize(
    flavor: Flavor.stg,
    name: 'STG',
    bannerColor: 0xFF1E88E5,
  );

  unawaited(bootstrap(() => const App()));
}
