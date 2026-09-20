import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'chameleon_colors.dart';

/// Chameleon typography ramp.
///
/// Sizes, weights, and spacing are fixed by the design tokens, and the whole
/// ramp is built from a single, fixed typeface (Inter) — a design-system
/// package must not know what a flavor is, so there is no per-flavor
/// typeface-swap mechanism here, and no mutable global state to configure at
/// boot.
///
/// Line-height tokens are absolute pixel values in the design system;
/// Flutter's [TextStyle.height] is a multiplier, so each style computes
/// `height = lineHeightPx / fontSizePx`.
///
/// All styles default to [ChameleonSemanticColors.textPrimary]; override
/// `color` per-use where a different content color is required.
abstract final class ChameleonTypography {
  /// Builds a Chameleon [TextStyle] from the `google_fonts` Inter family.
  ///
  /// This is the single point where the typeface is applied — every style in
  /// the ramp routes through it, so no call site names a family directly.
  static TextStyle _font({
    double? fontSize,
    double? height,
    double? letterSpacing,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      height: height,
      letterSpacing: letterSpacing,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color,
    );
  }

  /// Underlying font family name, kept in one place.
  static String get fontFamily => _font().fontFamily!;

  /// Builds a [TextStyle] from absolute design-token pixel values.
  static TextStyle _style({
    required double size,
    required double lineHeightPx,
    required double letterSpacing,
    required FontWeight weight,
  }) {
    return _font(
      fontSize: size,
      height: lineHeightPx / size,
      letterSpacing: letterSpacing,
      fontWeight: weight,
      color: ChameleonSemanticColors.textPrimary,
    );
  }

  // --- Display ---
  /// Black Italic display title used by onboarding-style slides.
  ///
  /// The ramp's [_style] helper can't express this (it takes no `fontStyle`),
  /// so this goes to [_font] directly.
  ///
  /// Callers override `color` per slide (dark on light slides, white on
  /// photo).
  static TextStyle get displayBlackItalic => _font(
    fontSize: 31,
    height: 30 / 31,
    letterSpacing: -1,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    color: ChameleonSemanticColors.textPrimary,
  );

  // --- Headings ---
  static TextStyle get heading1 => _style(
    size: 36,
    lineHeightPx: 44,
    letterSpacing: 0,
    weight: FontWeight.w700,
  );

  static TextStyle get heading2 => _style(
    size: 32,
    lineHeightPx: 40,
    letterSpacing: 0,
    weight: FontWeight.w700,
  );

  static TextStyle get heading3 => _style(
    size: 24,
    lineHeightPx: 32,
    letterSpacing: -2,
    weight: FontWeight.w700,
  );

  // --- Subheadings ---
  static TextStyle get subheading1 => _style(
    size: 20,
    lineHeightPx: 28,
    weight: FontWeight.w700,
    letterSpacing: .45,
  );

  static TextStyle get subheading2 => _style(
    size: 18,
    lineHeightPx: 26,
    letterSpacing: -0.5,
    weight: FontWeight.w600,
  );

  static TextStyle get subheading3 => _style(
    size: 16,
    lineHeightPx: 24,
    letterSpacing: -0.9,
    weight: FontWeight.w600,
  );

  // --- Titles ---
  static TextStyle get title1 => _style(
    size: 16,
    lineHeightPx: 24,
    letterSpacing: -0.7,
    weight: FontWeight.w600,
  );

  static TextStyle get title2 => _style(
    size: 14,
    lineHeightPx: 20,
    letterSpacing: -0.6,
    weight: FontWeight.w600,
  );

  // --- Body ---
  static TextStyle get body1 => _style(
    size: 16,
    lineHeightPx: 24,
    letterSpacing: 0.15,
    weight: FontWeight.w400,
  );

  static TextStyle get body2 => _style(
    size: 14,
    lineHeightPx: 20,
    letterSpacing: 0.1,
    weight: FontWeight.w500,
  );

  static TextStyle get body3 => _style(
    size: 12,
    lineHeightPx: 16,
    letterSpacing: .46,
    weight: FontWeight.w500,
  );

  // --- Labels ---
  static TextStyle get label1 => _style(
    size: 14,
    lineHeightPx: 20,
    letterSpacing: 0,
    weight: FontWeight.w500,
  );

  static TextStyle get buttonLabel1 => _style(
    size: 16,
    lineHeightPx: 20,
    letterSpacing: 0.15,
    weight: FontWeight.w600,
  );

  static TextStyle get label2 => _style(
    size: 12,
    lineHeightPx: 16,
    letterSpacing: -0.9,
    weight: FontWeight.w500,
  );

  static TextStyle get label3 => _style(
    size: 11,
    lineHeightPx: 16,
    letterSpacing: -0.5,
    weight: FontWeight.w500,
  );

  /// Maps the Chameleon ramp onto Flutter's Material [TextTheme] slots so
  /// that framework widgets pick up the correct styles automatically.
  static TextTheme get textTheme => TextTheme(
    displayLarge: heading1,
    displayMedium: heading2,
    displaySmall: heading3,
    headlineLarge: heading2,
    headlineMedium: heading3,
    headlineSmall: subheading1,
    titleLarge: subheading1,
    titleMedium: title1,
    titleSmall: title2,
    bodyLarge: body1,
    bodyMedium: body2,
    bodySmall: body3,
    labelLarge: label1,
    labelMedium: label2,
    labelSmall: label3,
  );
}
