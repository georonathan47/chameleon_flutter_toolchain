import 'package:chameleon_ui/chameleon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ChameleonTheme.light builds without throwing', () {
    expect(ChameleonTheme.light, isA<ThemeData>());
  });

  test(
    'the light theme uses the brand primary as its color scheme primary',
    () {
      expect(
        ChameleonTheme.light.colorScheme.primary,
        ChameleonSemanticColors.primary,
      );
      expect(
        ChameleonTheme.light.scaffoldBackgroundColor,
        ChameleonSemanticColors.surface,
      );
    },
  );

  test('ChameleonTheme.dark builds without throwing', () {
    expect(ChameleonTheme.dark, isA<ThemeData>());
  });

  test(
    'the dark theme uses the brand primary but a dark surface/scaffold',
    () {
      expect(
        ChameleonTheme.dark.colorScheme.primary,
        ChameleonSemanticColorsDark.primary,
      );
      expect(
        ChameleonTheme.dark.scaffoldBackgroundColor,
        ChameleonSemanticColorsDark.surface,
      );
      expect(ChameleonTheme.dark.brightness, Brightness.dark);
    },
  );

  test('both themes register ChameleonSemanticColorsExtension', () {
    expect(
      ChameleonTheme.light.extension<ChameleonSemanticColorsExtension>(),
      ChameleonSemanticColorsExtension.light,
    );
    expect(
      ChameleonTheme.dark.extension<ChameleonSemanticColorsExtension>(),
      ChameleonSemanticColorsExtension.dark,
    );
  });
}
