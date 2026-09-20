import 'package:chameleon_core/chameleon_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:{{project_name.snakeCase()}}/app/app.dart';

/// A [NetworkInfo] that reports "online" and never emits changes — enough
/// for widget tests that just need `ConnectivityBloc` to resolve, without
/// pulling in `connectivity_plus`'s platform channel.
class FakeNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;

  @override
  Stream<bool> get onConnectivityChanged => const Stream.empty();
}

/// Registers everything `App`'s widget tree resolves from `getIt` with a
/// lightweight fake, so a widget test can pump `App` (or anything nested
/// inside it) without booting real platform-channel plugins.
///
/// Call from `setUp` and pair with `tearDown(getIt.reset)` — a DI dependency
/// added to a widget without a matching test stub is exactly the failure
/// guardrail #7 in tasks/lessons.md describes.
void registerTestDependencies() {
  getIt
    ..registerLazySingleton<NetworkInfo>(FakeNetworkInfo.new)
    ..registerLazySingleton<ConnectivityBloc>(
      () => ConnectivityBloc(getIt<NetworkInfo>()),
    );
}
