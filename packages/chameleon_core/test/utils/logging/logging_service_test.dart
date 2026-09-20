import 'package:chameleon_core/chameleon_core.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingCrashReporter implements ChameleonCrashReporter {
  final recorded = <(Object error, StackTrace stackTrace, String? reason)>[];

  @override
  void recordError(Object error, StackTrace stackTrace, {String? reason}) {
    recorded.add((error, stackTrace, reason));
  }
}

class _ThrowingCrashReporter implements ChameleonCrashReporter {
  @override
  void recordError(Object error, StackTrace stackTrace, {String? reason}) {
    throw StateError('crash reporter unavailable');
  }
}

class _RecordingAnalyticsReporter implements AnalyticsReporter {
  final recorded = <(String name, Map<String, Object?>? properties)>[];

  @override
  void trackEvent(String name, {Map<String, Object?>? properties}) {
    recorded.add((name, properties));
  }
}

class _ThrowingAnalyticsReporter implements AnalyticsReporter {
  @override
  void trackEvent(String name, {Map<String, Object?>? properties}) {
    throw StateError('analytics reporter unavailable');
  }
}

void main() {
  tearDown(() {
    ChameleonLogger.useCrashReporter(const NoopCrashReporter());
    ChameleonLogger.useAnalyticsReporter(const NoopAnalyticsReporter());
  });

  test('defaults to a no-op reporter — reporting never throws', () {
    expect(
      () => ChameleonLogger.error(const UnknownFailure('boom')),
      returnsNormally,
    );
  });

  test('useCrashReporter() routes failure() to the configured reporter', () {
    final reporter = _RecordingCrashReporter();
    ChameleonLogger.useCrashReporter(reporter);

    final failure = ServerFailure.withDebug(
      debugMessage: 'GET /accounts -> 500',
    );
    ChameleonLogger.failure(failure);

    expect(reporter.recorded, hasLength(1));
    expect(reporter.recorded.single.$1, same(failure));
  });

  test(
    'a crash reporter that itself throws is swallowed, not propagated',
    () {
      ChameleonLogger.useCrashReporter(_ThrowingCrashReporter());

      expect(
        () => ChameleonLogger.error(const UnknownFailure('boom')),
        returnsNormally,
      );
    },
  );

  test('defaults to a no-op analytics reporter — trackEvent never throws', () {
    expect(
      () => ChameleonLogger.trackEvent('transfer_completed'),
      returnsNormally,
    );
  });

  test(
    'useAnalyticsReporter() routes trackEvent() to the configured reporter',
    () {
      final reporter = _RecordingAnalyticsReporter();
      ChameleonLogger.useAnalyticsReporter(reporter);

      ChameleonLogger.trackEvent(
        'transfer_completed',
        properties: {'amount': 100},
      );

      expect(reporter.recorded, hasLength(1));
      expect(reporter.recorded.single.$1, equals('transfer_completed'));
      expect(reporter.recorded.single.$2, equals({'amount': 100}));
    },
  );

  test(
    'an analytics reporter that itself throws is swallowed, not propagated',
    () {
      ChameleonLogger.useAnalyticsReporter(_ThrowingAnalyticsReporter());

      expect(
        () => ChameleonLogger.trackEvent('transfer_completed'),
        returnsNormally,
      );
    },
  );
}
