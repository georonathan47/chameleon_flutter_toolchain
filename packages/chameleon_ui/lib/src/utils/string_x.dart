import 'package:flutter/material.dart';

import '../tokens/chameleon_typography.dart';

/// Turns a plain [String] into a [Text] styled with the Chameleon typography
/// ramp, e.g. `'Welcome back'.asHeading2()`.
///
/// Each method maps 1:1 onto a style in [ChameleonTypography], so call sites
/// never inline font sizes, weights, or line heights. `color` and
/// `fontWeight` override the token defaults for the cases where content
/// colour or emphasis differs; everything else is a straight passthrough to
/// [Text].
extension StringX on String {
  /// Shared builder: resolves the ramp style, applies the optional overrides,
  /// and forwards the standard [Text] arguments.
  Text _text(
    TextStyle base, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? softWrap,
    double? textScaleFactor,
    String? semanticsLabel,
    TextStyle? style,
  }) {
    final resolved = base
        .copyWith(color: color, fontWeight: fontWeight)
        .merge(style);

    return Text(
      this,
      style: resolved,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
      textScaler: textScaleFactor == null
          ? null
          : TextScaler.linear(textScaleFactor),
      semanticsLabel: semanticsLabel,
    );
  }

  // --- Display ---

  /// Inter Black Italic display title (31/30, -1) used by onboarding slides.
  Text asDisplayBlackItalic({
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? softWrap,
    double? textScaleFactor,
    String? semanticsLabel,
    TextStyle? style,
  }) => _text(
    ChameleonTypography.displayBlackItalic,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    softWrap: softWrap,
    textScaleFactor: textScaleFactor,
    semanticsLabel: semanticsLabel,
    style: style,
  );

  // --- Headings ---

  /// Heading 1 — 36/44, .w700.
  Text asHeading1({
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? softWrap,
    double? textScaleFactor,
    String? semanticsLabel,
    TextStyle? style,
  }) => _text(
    ChameleonTypography.heading1,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    softWrap: softWrap,
    textScaleFactor: textScaleFactor,
    semanticsLabel: semanticsLabel,
    style: style,
  );

  /// Heading 2 — 32/40, .w700.
  Text asHeading2({
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? softWrap,
    double? textScaleFactor,
    String? semanticsLabel,
    TextStyle? style,
  }) => _text(
    ChameleonTypography.heading2,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    softWrap: softWrap,
    textScaleFactor: textScaleFactor,
    semanticsLabel: semanticsLabel,
    style: style,
  );

  /// Heading 3 — 24/32, .w700.
  Text asHeading3({
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? softWrap,
    double? textScaleFactor,
    String? semanticsLabel,
    TextStyle? style,
  }) => _text(
    ChameleonTypography.heading3,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    softWrap: softWrap,
    textScaleFactor: textScaleFactor,
    semanticsLabel: semanticsLabel,
    style: style,
  );

  // --- Subheadings ---

  /// Subheading 1 — 20/28, .w600.
  Text asSubheading1({
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? softWrap,
    double? textScaleFactor,
    String? semanticsLabel,
    TextStyle? style,
  }) => _text(
    ChameleonTypography.subheading1,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    softWrap: softWrap,
    textScaleFactor: textScaleFactor,
    semanticsLabel: semanticsLabel,
    style: style,
  );

  /// Subheading 2 — 18/26, .w600.
  Text asSubheading2({
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? softWrap,
    double? textScaleFactor,
    String? semanticsLabel,
    TextStyle? style,
  }) => _text(
    ChameleonTypography.subheading2,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    softWrap: softWrap,
    textScaleFactor: textScaleFactor,
    semanticsLabel: semanticsLabel,
    style: style,
  );

  /// Subheading 3 — 16/24, .w600.
  Text asSubheading3({
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? softWrap,
    double? textScaleFactor,
    String? semanticsLabel,
    TextStyle? style,
  }) => _text(
    ChameleonTypography.subheading3,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    softWrap: softWrap,
    textScaleFactor: textScaleFactor,
    semanticsLabel: semanticsLabel,
    style: style,
  );

  // --- Titles ---

  /// Title 1 — 16/24, .w600.
  Text asTitle1({
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? softWrap,
    double? textScaleFactor,
    String? semanticsLabel,
    TextStyle? style,
  }) => _text(
    ChameleonTypography.title1,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    softWrap: softWrap,
    textScaleFactor: textScaleFactor,
    semanticsLabel: semanticsLabel,
    style: style,
  );

  /// Title 2 — 14/20, .w600.
  Text asTitle2({
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? softWrap,
    double? textScaleFactor,
    String? semanticsLabel,
    TextStyle? style,
  }) => _text(
    ChameleonTypography.title2,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    softWrap: softWrap,
    textScaleFactor: textScaleFactor,
    semanticsLabel: semanticsLabel,
    style: style,
  );

  // --- Body ---

  /// Body 1 — 16/24, w400.
  Text asBody1({
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? softWrap,
    double? textScaleFactor,
    String? semanticsLabel,
    TextStyle? style,
  }) => _text(
    ChameleonTypography.body1,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    softWrap: softWrap,
    textScaleFactor: textScaleFactor,
    semanticsLabel: semanticsLabel,
    style: style,
  );

  /// Body 2 — 14/20, w400.
  Text asBody2({
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? softWrap,
    double? textScaleFactor,
    String? semanticsLabel,
    TextStyle? style,
  }) => _text(
    ChameleonTypography.body2,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    softWrap: softWrap,
    textScaleFactor: textScaleFactor,
    semanticsLabel: semanticsLabel,
    style: style,
  );

  /// Body 3 — 12/16, w400.
  Text asBody3({
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? softWrap,
    double? textScaleFactor,
    String? semanticsLabel,
    TextStyle? style,
  }) => _text(
    ChameleonTypography.body3,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    softWrap: softWrap,
    textScaleFactor: textScaleFactor,
    semanticsLabel: semanticsLabel,
    style: style,
  );

  // --- Labels ---

  /// Label 1 — 14/20, .w500.
  Text asLabel1({
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? softWrap,
    double? textScaleFactor,
    String? semanticsLabel,
    TextStyle? style,
  }) => _text(
    ChameleonTypography.label1,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    softWrap: softWrap,
    textScaleFactor: textScaleFactor,
    semanticsLabel: semanticsLabel,
    style: style,
  );
  Text asButtonText({
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? softWrap,
    double? textScaleFactor,
    String? semanticsLabel,
    TextStyle? style,
  }) => _text(
    ChameleonTypography.buttonLabel1,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    softWrap: softWrap,
    textScaleFactor: textScaleFactor,
    semanticsLabel: semanticsLabel,
    style: style,
  );

  /// Label 2 — 12/16, .w500.
  Text asLabel2({
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? softWrap,
    double? textScaleFactor,
    String? semanticsLabel,
    TextStyle? style,
  }) => _text(
    ChameleonTypography.label2,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    softWrap: softWrap,
    textScaleFactor: textScaleFactor,
    semanticsLabel: semanticsLabel,
    style: style,
  );

  /// Label 3 — 11/16, .w500.
  Text asLabel3({
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? softWrap,
    double? textScaleFactor,
    String? semanticsLabel,
    TextStyle? style,
  }) => _text(
    ChameleonTypography.label3,
    color: color,
    fontWeight: fontWeight,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    softWrap: softWrap,
    textScaleFactor: textScaleFactor,
    semanticsLabel: semanticsLabel,
    style: style,
  );

  /// This string as the label of a primary (high-emphasis) CTA.
  ///
  /// Styling comes from `elevatedButtonTheme`, so call sites pass only what
  /// varies — usually just [onPressed]. Pass [icon] for a leading icon.
  FilledButton toPrimaryButton({
    VoidCallback? onPressed,
    Color? color,
    Widget? icon,
    String? semanticsLabel,
    FontWeight? fontWeight,
  }) {
    final label = asButtonText(
      color: color,
      fontWeight: fontWeight,
      semanticsLabel: semanticsLabel,
    );

    if (icon == null) {
      return FilledButton(onPressed: onPressed, child: label);
    }

    return FilledButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label,
    );
  }

  /// This string as the label of a primary (high-emphasis) CTA.
  ///
  /// Styling comes from `outlinedButtonTheme`, so call sites pass only what
  /// varies — usually just [onPressed]. Pass [icon] for a leading icon.
  OutlinedButton toOutlinedButton({
    VoidCallback? onPressed,
    Color? color,
    Widget? icon,
    String? semanticsLabel,
    FontWeight? fontWeight,
  }) {
    final label = asButtonText(
      color: color,
      fontWeight: fontWeight,
      semanticsLabel: semanticsLabel,
    );

    if (icon == null) {
      return OutlinedButton(onPressed: onPressed, child: label);
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label,
    );
  }
}
