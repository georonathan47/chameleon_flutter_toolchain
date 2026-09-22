import 'package:chameleon_ui/chameleon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChameleonBreakpoints.classify', () {
    test('just below the tablet threshold is phone', () {
      expect(
        ChameleonBreakpoints.classify(ChameleonBreakpoints.tablet - 0.1),
        ChameleonWindowSizeClass.phone,
      );
    });

    test('exactly the tablet threshold is tablet', () {
      expect(
        ChameleonBreakpoints.classify(ChameleonBreakpoints.tablet),
        ChameleonWindowSizeClass.tablet,
      );
    });

    test('just below the foldable threshold is tablet', () {
      expect(
        ChameleonBreakpoints.classify(ChameleonBreakpoints.foldable - 0.1),
        ChameleonWindowSizeClass.tablet,
      );
    });

    test('exactly the foldable threshold is foldable', () {
      expect(
        ChameleonBreakpoints.classify(ChameleonBreakpoints.foldable),
        ChameleonWindowSizeClass.foldable,
      );
    });

    test('foldable has no upper bound', () {
      expect(
        ChameleonBreakpoints.classify(2000),
        ChameleonWindowSizeClass.foldable,
      );
    });
  });

  group('ChameleonBreakpoints.of', () {
    testWidgets('matches classify() for the reported width', (tester) async {
      final originalSize = tester.view.physicalSize;
      final originalRatio = tester.view.devicePixelRatio;
      addTearDown(() {
        tester.view.physicalSize = originalSize;
        tester.view.devicePixelRatio = originalRatio;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(700, 800);

      late ChameleonWindowSizeClass result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              result = ChameleonBreakpoints.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(result, ChameleonBreakpoints.classify(700));
      expect(result, ChameleonWindowSizeClass.tablet);
    });
  });
}
