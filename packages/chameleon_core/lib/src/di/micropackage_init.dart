import 'package:injectable/injectable.dart';

/// Marks `chameleon_core` as an injectable "microPackage" so its
/// `@lazySingleton`/`@injectable`-annotated classes (`AuthInterceptor`,
/// `IdempotencyInterceptor`, `NetworkInfoImpl`, `ConnectivityBloc`,
/// `DeviceIdentity`, `SessionEventBus`, `ChameleonLogger`) are picked up by
/// the **app's** `@InjectableInit()` build_runner run automatically, even
/// though they live in this separate package's source tree.
///
/// The generated `micropackage_init.module.dart` this produces must be
/// committed — consuming apps don't run codegen against a dependency's own
/// sources, so the generated module has to ship as part of the package.
///
/// This function is never called; it exists only so the generator has
/// something to attach the annotation to.
@InjectableInit.microPackage()
void initMicroPackage() {}
