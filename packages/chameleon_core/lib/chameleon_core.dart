/// Chameleon cross-cutting infrastructure — failures, logging, network layer,
/// isolate helpers, flavor config, and feature flags.
///
/// Import this single file to get the package's public surface. Everything
/// under `src/` is implementation detail and not exported here.
///
/// Note: `FirebaseFeatureFlags` is intentionally not part of this surface —
/// see `lib/src/feature_flags/noop_feature_flags.dart` and the package
/// README for why. Consuming apps that want Firebase Remote Config supply
/// their own `FeatureFlags` implementation and add `firebase_remote_config`
/// themselves.
library;

export 'src/auth/biometric_authenticator.dart';
export 'src/blocs/connectivity/connectivity_bloc.dart';
export 'src/config/flavor_config.dart';
// Generated — registers every @lazySingleton/@injectable class in this
// package with a consuming app's GetIt container. The app's own
// @InjectableInit must pass `externalPackageModulesBefore:
// [ExternalModule(ChameleonCorePackageModule)]`; injectable's "automatic"
// microPackage discovery does a plain filesystem glob rooted at the
// consumer's own directory, which never reaches a dependency resolved via
// pub cache or a git ref — verified by generating a real app and watching
// the auto-discovery silently find nothing.
export 'src/di/micropackage_init.module.dart';
export 'src/errors/exceptions.dart';
export 'src/errors/failures.dart';
export 'src/feature_flags/feature_flags.dart';
export 'src/feature_flags/noop_feature_flags.dart';
export 'src/home_widget/home_widget_updater.dart';
export 'src/network/auth_interceptor.dart';
export 'src/network/chopper_client_factory.dart';
export 'src/network/device_identity.dart';
export 'src/network/idempotency_interceptor.dart';
export 'src/network/network_info.dart';
export 'src/network/network_logging_interceptor.dart';
export 'src/network/retry_interceptor.dart';
export 'src/network/session_cache.dart';
export 'src/network/session_event_bus.dart';
export 'src/network/token_storage.dart';
export 'src/push_notifications/push_notification_service.dart';
export 'src/services/device_service.dart';
export 'src/storage/secure_storage.dart';
export 'src/utils/debouncer.dart';
export 'src/utils/extensions/context_extensions.dart';
export 'src/utils/extensions/duration_x.dart';
export 'src/utils/isolate_helper.dart';
export 'src/utils/logging/analytics_reporter.dart';
export 'src/utils/logging/chameleon_crash_reporter.dart';
export 'src/utils/logging/logging_service.dart';
