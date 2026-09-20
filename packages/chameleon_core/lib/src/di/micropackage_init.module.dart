//@GeneratedMicroModule;ChameleonCorePackageModule;package:chameleon_core/src/di/micropackage_init.module.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i687;

import 'package:chameleon_core/src/blocs/connectivity/connectivity_bloc.dart'
    as _i254;
import 'package:chameleon_core/src/network/auth_interceptor.dart' as _i875;
import 'package:chameleon_core/src/network/device_identity.dart' as _i181;
import 'package:chameleon_core/src/network/idempotency_interceptor.dart'
    as _i432;
import 'package:chameleon_core/src/network/network_info.dart' as _i272;
import 'package:chameleon_core/src/network/retry_interceptor.dart' as _i174;
import 'package:chameleon_core/src/network/session_cache.dart' as _i426;
import 'package:chameleon_core/src/network/session_event_bus.dart' as _i105;
import 'package:chameleon_core/src/network/token_storage.dart' as _i1039;
import 'package:chameleon_core/src/storage/secure_storage.dart' as _i718;
import 'package:chameleon_core/src/utils/logging/logging_service.dart' as _i633;
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:injectable/injectable.dart' as _i526;

class ChameleonCorePackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.factory<_i633.ChameleonLogger>(() => const _i633.ChameleonLogger());
    gh.lazySingleton<_i181.DeviceIdentity>(() => _i181.DeviceIdentity());
    gh.lazySingleton<_i174.RetryInterceptor>(() => _i174.RetryInterceptor());
    gh.lazySingleton<_i105.SessionEventBus>(
      () => _i105.SessionEventBus(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i718.SecureStorage>(
        () => _i718.SecureStorageImpl(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i875.AuthInterceptor>(() => _i875.AuthInterceptor(
          gh<_i1039.TokenStorage>(),
          gh<_i105.SessionEventBus>(),
          gh<_i426.SessionCache>(),
        ));
    gh.lazySingleton<_i432.IdempotencyInterceptor>(
        () => _i432.IdempotencyInterceptor(gh<_i181.DeviceIdentity>()));
    gh.lazySingleton<_i272.NetworkInfo>(
        () => _i272.NetworkInfoImpl(gh<_i895.Connectivity>()));
    gh.lazySingleton<_i254.ConnectivityBloc>(
        () => _i254.ConnectivityBloc(gh<_i272.NetworkInfo>()));
  }
}
