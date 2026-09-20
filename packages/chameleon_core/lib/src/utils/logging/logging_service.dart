import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';

import 'package:injectable/injectable.dart';

import '../../config/flavor_config.dart';
import '../../errors/failures.dart';
import 'analytics_reporter.dart';
import 'chameleon_crash_reporter.dart';

/// Global flavor-based app logger
///
@injectable
class ChameleonLogger {
  /// Can't be instantiated — all methods are static
  const ChameleonLogger();

  /// Where errors are reported. Defaults to [NoopCrashReporter] so this
  /// package has no hard crash-reporting dependency and unit tests need no
  /// vendor app. The app wires its real reporter in once at boot via
  /// [useCrashReporter].
  static ChameleonCrashReporter _crashReporter = const NoopCrashReporter();

  /// Selects where [failure] and [error] report to. Call once at boot (and
  /// again at the top of every worker isolate — statics are per-isolate, so a
  /// worker starts back at [NoopCrashReporter] unless re-set).
  // ignore: use_setters_to_change_properties
  static void useCrashReporter(ChameleonCrashReporter reporter) =>
      _crashReporter = reporter;

  /// Where [trackEvent] sends to. Defaults to [NoopAnalyticsReporter] for
  /// the same reason [_crashReporter] defaults to [NoopCrashReporter] — no
  /// hard analytics-vendor dependency, no vendor app needed for tests.
  static AnalyticsReporter _analyticsReporter = const NoopAnalyticsReporter();

  /// Selects where [trackEvent] reports to. Call once at boot (and again at
  /// the top of every worker isolate, same caveat as [useCrashReporter]).
  // ignore: use_setters_to_change_properties
  static void useAnalyticsReporter(AnalyticsReporter reporter) =>
      _analyticsReporter = reporter;

  Failure mapReason(String reason) {
    final normalized = reason.toLowerCase();

    if (normalized.contains('timeout') || normalized.contains('timed out')) {
      return UnexpectedFailure.withDebug(debugMessage: reason);
    }
    return UnknownFailure(reason);
  }

  /// Reports to the configured [ChameleonCrashReporter], swallowing any error
  /// the reporter itself throws.
  ///
  /// A crash reporter can throw **synchronously** (e.g. Firebase's own
  /// `FirebaseCrashlytics.instance` throws before Firebase has initialized),
  /// so `unawaited` alone does not contain it — the throw happens before a
  /// future exists.
  ///
  /// Reporting an error must never itself raise one: a logging call sits on
  /// the failure path, where a second exception would mask the original.
  static void _reportToCrashReporter(
    Object error,
    StackTrace stackTrace, {
    String? reason,
  }) {
    try {
      _crashReporter.recordError(error, stackTrace, reason: reason);
    } on Object catch (_) {
      // Crash reporter unavailable (tests, pre-init boot). The console output
      // above still carries the detail; losing the remote report is strictly
      // better than losing the original error.
    }
  }

  /// Log a failure — pretty console in dev, reported to the crash reporter in
  /// release.
  static void failure(Failure f, {String? context}) {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━ [ErrorHandler] ━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('Type    : ${f.runtimeType}');
      debugPrint('Message : ${f.message}');
      if (context != null) debugPrint('Context : $context');
      if (f.statusCode != null) debugPrint('Status  : ${f.statusCode}');
      if (f.debugMessage != null) debugPrint('Debug   : ${f.debugMessage}');
      if (f.stackTrace != null) {
        debugPrint('Stack   :');
        debugPrint('${f.stackTrace}');
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }

    _reportToCrashReporter(
      f,
      f.stackTrace ?? StackTrace.current,
      reason: f.debugMessage ?? f.message,
    );
  }

  /// Whether console logging is on for the running flavor.
  ///
  /// Reads [FlavorConfig.flavorOrNull] rather than `instance`, which asserts.
  /// A logging call must never be the thing that breaks a request — and this
  /// is reached from worker isolates (the data layer runs network calls
  /// through `compute()`), where statics start out unset. Workers re-seed the
  /// flavor on entry; if one ever doesn't, logging degrades to silence
  /// instead of throwing.
  ///
  /// Defaults to prod's behaviour (no console output) when the flavor is
  /// unknown, so an uninitialized environment can never leak logs.
  static bool get _isConsoleLoggingEnabled {
    final flavor = FlavorConfig.flavorOrNull;
    return flavor != null && flavor != Flavor.prod;
  }

  /// API - log API results only
  static void logAPI(
    String source,
    String method,
    String fullUrl, {
    String? requestBody,
    String? responseBody,
    int? code,
    int? durationMs,
  }) {
    final canLog = kDebugMode && _isConsoleLoggingEnabled;
    if (canLog) {
      debugPrint('\n');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━ API RESPONSE ━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('API      : [$method] -> $source');
      if (code != null) {
        debugPrint('Status   : ${_emoji(code)} $code ${_emoji(code)}');
      }
      if (durationMs != null) debugPrint('Duration : $durationMs');
      debugPrint('Request  : $requestBody');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('Response : $responseBody');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  /// Info — debug only, completely stripped in release
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('ℹ️[INFO]ℹ️ - $message');
    }
  }

  /// Tracks a product-analytics event — a distinct call site from [info]:
  /// not every debug log is something worth counting as a tracked event, so
  /// callers opt into analytics explicitly here rather than every [info]
  /// call silently fanning out to the configured [AnalyticsReporter].
  ///
  /// Reports unconditionally (not gated by [kDebugMode] like the console
  /// logging above) — analytics is meant to fire in release. Swallows
  /// whatever the reporter itself throws, same reasoning as
  /// [_reportToCrashReporter]: a tracking call must never be what breaks a
  /// feature.
  static void trackEvent(String name, {Map<String, Object?>? properties}) {
    try {
      _analyticsReporter.trackEvent(name, properties: properties);
    } on Object catch (_) {
      // Analytics reporter unavailable (tests, pre-init boot) — losing the
      // event is strictly better than throwing from a tracking call site.
    }
  }

  // Error - flutter-specific errors
  static void error(Failure f, {String? context}) {
    final canLog = kDebugMode && _isConsoleLoggingEnabled;

    if (canLog) {
      debugPrint('Error');
      debugPrint('━━━━━━━━━━━━━━━━━━━━ [ErrorHandler] ━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('Type    : ${f.runtimeType}');
      debugPrint('Message : ${f.message}');
      if (context != null) debugPrint('Context : $context');
      if (f.statusCode != null) debugPrint('Status  : ${f.statusCode}');
      if (f.debugMessage != null) debugPrint('Debug   : ${f.debugMessage}');
      if (f.stackTrace != null) {
        debugPrint('Stack   :');
        debugPrint('${f.stackTrace}');
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }

    _reportToCrashReporter(
      f,
      f.stackTrace ?? StackTrace.current,
      reason: f.message,
    );
  }

  /// Warning — something unexpected but not fatal
  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('⚠️[WARN]⚠️ - $message');
    }
    // Optionally send as non-fatal to the crash reporter in release
    _reportToCrashReporter(
      'Error - $message',
      StackTrace.current,
      reason: message,
    );
  }

  static String _emoji(int code) {
    switch (code) {
      case >= 200 && < 300:
        return '✅';
      case >= 400 && < 500:
        return '❌';
      case >= 500:
        return '🚫';
      default:
        return '⚠️ No Code ⚠️';
    }
  }
}
