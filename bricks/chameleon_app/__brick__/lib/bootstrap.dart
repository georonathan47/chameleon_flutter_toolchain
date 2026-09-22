import 'dart:async';

import 'package:chameleon_core/chameleon_core.dart';
{{#use_push_notifications}}
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
{{/use_push_notifications}}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
{{#use_push_notifications}}
import 'core/push_notifications/firebase_push_notification_service.dart';
{{/use_push_notifications}}

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

      {{#use_push_notifications}}
      // No FirebaseOptions passed deliberately: this reads native config
      // files (google-services.json/GoogleService-Info.plist) directly, so
      // generated code compiles and analyzes immediately without depending
      // on a firebase_options.dart this toolchain can't generate (that file
      // needs a real Firebase project — see docs/architecture.md's "Push
      // notifications" section for the one-time `flutterfire configure`
      // step). It's a runtime failure, not a compile error, until then —
      // same bar as every other opt-in flag in this brick.
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler,
      );
      {{/use_push_notifications}}

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
