import 'dart:async';

import 'package:chameleon_core/chameleon_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';

class _AppBlocObserver extends BlocObserver {
  const _AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    ChameleonLogger.error(
      UnexpectedFailure.withDebug(debugMessage: '${bloc.runtimeType}: $error'),
      context: '${bloc.runtimeType}',
    );
    super.onError(bloc, error, stackTrace);
  }
}

/// Shared entrypoint for every flavor. Each `main_*.dart` calls
/// [FlavorConfig.initialize], then this.
Future<void> bootstrap(Widget Function() builder) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      Bloc.observer = const _AppBlocObserver();

      FlutterError.onError = (details) {
        ChameleonLogger.error(
          UnexpectedFailure.withDebug(
            debugMessage: details.exceptionAsString(),
          ),
          context: 'FlutterError',
        );
      };

      await configureDependencies();

      // Noop by default (see CoreModule's FeatureFlags binding) — called
      // anyway for parity/extensibility once a real FeatureFlags backend is
      // wired in.
      await getIt<FeatureFlags>().initialize();

      runApp(builder());
    },
    (error, stackTrace) {
      ChameleonLogger.error(
        UnexpectedFailure.withDebug(
          debugMessage: error.toString(),
          stackTrace: stackTrace,
        ),
        context: 'runZonedGuarded',
      );
    },
  );
}
