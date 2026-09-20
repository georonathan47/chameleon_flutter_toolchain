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
}
