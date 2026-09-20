import 'package:chameleon_ui/chameleon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the whole ramp is built from a single, fixed typeface (Inter)', () {
    expect(ChameleonTypography.fontFamily, contains('Inter'));
    expect(ChameleonTypography.heading1.fontFamily, contains('Inter'));
    expect(ChameleonTypography.body2.fontFamily, contains('Inter'));
    expect(ChameleonTypography.label1.fontFamily, contains('Inter'));
  });

  test('the ramp values match the design tokens', () {
    expect(ChameleonTypography.heading1.fontSize, 36);
    expect(ChameleonTypography.heading1.fontWeight, FontWeight.w700);
    expect(ChameleonTypography.heading1.height, 44 / 36);

    expect(ChameleonTypography.body1.fontSize, 16);
    expect(ChameleonTypography.body1.fontWeight, FontWeight.w400);
    expect(ChameleonTypography.body1.letterSpacing, 0.15);

    expect(ChameleonTypography.label1.fontSize, 14);
    expect(ChameleonTypography.label1.fontWeight, FontWeight.w500);
  });

  test('displayBlackItalic asks for the heaviest weight and italic style', () {
    final style = ChameleonTypography.displayBlackItalic;
    expect(style.fontWeight, FontWeight.w900);
    expect(style.fontStyle, FontStyle.italic);
  });

  test('every style defaults to the primary text color', () {
    expect(
      ChameleonTypography.heading1.color,
      ChameleonSemanticColors.textPrimary,
    );
    expect(
      ChameleonTypography.body1.color,
      ChameleonSemanticColors.textPrimary,
    );
  });

  test('textTheme maps the ramp onto the Material TextTheme slots', () {
    final textTheme = ChameleonTypography.textTheme;
    expect(
      textTheme.displayLarge?.fontSize,
      ChameleonTypography.heading1.fontSize,
    );
    expect(textTheme.bodyLarge?.fontSize, ChameleonTypography.body1.fontSize);
    expect(
      textTheme.labelLarge?.fontSize,
      ChameleonTypography.label1.fontSize,
    );
  });
}
