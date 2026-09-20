import 'package:chameleon_core/chameleon_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoopFeatureFlags', () {
    const featureFlags = NoopFeatureFlags();

    test('initialize() completes without doing anything', () async {
      await expectLater(featureFlags.initialize(), completes);
    });

    test(
      'initialize() with defaults still completes without throwing',
      () async {
        await expectLater(
          featureFlags.initialize(defaults: const {'show_new_dashboard': true}),
          completes,
        );
      },
    );

    test('getBool() defaults to false', () {
      expect(featureFlags.getBool('show_new_dashboard'), isFalse);
    });

    test('getString() defaults to an empty string', () {
      expect(featureFlags.getString('theme'), equals(''));
    });

    test('getInt() defaults to zero', () {
      expect(featureFlags.getInt('max_retries'), equals(0));
    });

    test('getDouble() defaults to zero', () {
      expect(featureFlags.getDouble('discount_rate'), equals(0.0));
    });

    test('is a FeatureFlags implementation', () {
      expect(featureFlags, isA<FeatureFlags>());
    });
  });
}
