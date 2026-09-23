import 'package:flutter/material.dart';

import '../tokens/chameleon_colors.dart';

/// The handful of [ChameleonSemanticColors] roles `chameleon_ui`'s own
/// bespoke components (dialogs, the bottom sheet, the empty state, the
/// skeleton) need that Flutter's [ColorScheme] doesn't cover — `error` is
/// already on [ColorScheme], so components read
/// `Theme.of(context).colorScheme.error` directly instead of duplicating
/// it here.
///
/// A [ThemeExtension] rather than a bespoke `.of(context)` resolver: it's
/// the framework's own sanctioned mechanism for exactly this ("a themed
/// value `ColorScheme` doesn't cover, that should still flip with
/// `Theme.of(context)` and animate via `lerp`"), registered on both
/// `ChameleonTheme.light`/`.dark`. Resolve it with:
///
/// ```dart
/// final colors =
///     Theme.of(context).extension<ChameleonSemanticColorsExtension>()!;
/// ```
@immutable
class ChameleonSemanticColorsExtension
    extends ThemeExtension<ChameleonSemanticColorsExtension> {
  const ChameleonSemanticColorsExtension({
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.outlineVariant,
    required this.scrim,
    required this.skeletonBase,
    required this.skeletonHighlight,
  });

  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color outlineVariant;
  final Color scrim;

  /// `ChameleonSkeleton`'s placeholder box color — a new role, not
  /// retrofitted onto [ChameleonSemanticColors]: the skeleton previously
  /// read raw [ChameleonColors.grey200] with no semantic name to mirror.
  final Color skeletonBase;

  /// `ChameleonSkeleton`'s sweeping highlight color.
  final Color skeletonHighlight;

  static const light = ChameleonSemanticColorsExtension(
    surface: ChameleonSemanticColors.surface,
    textPrimary: ChameleonSemanticColors.textPrimary,
    textSecondary: ChameleonSemanticColors.textSecondary,
    textDisabled: ChameleonSemanticColors.textDisabled,
    outlineVariant: ChameleonSemanticColors.outlineVariant,
    scrim: ChameleonSemanticColors.scrim,
    skeletonBase: ChameleonColors.grey200,
    skeletonHighlight: ChameleonColors.grey150,
  );

  static const dark = ChameleonSemanticColorsExtension(
    surface: ChameleonSemanticColorsDark.surface,
    textPrimary: ChameleonSemanticColorsDark.textPrimary,
    textSecondary: ChameleonSemanticColorsDark.textSecondary,
    textDisabled: ChameleonSemanticColorsDark.textDisabled,
    outlineVariant: ChameleonSemanticColorsDark.outlineVariant,
    scrim: ChameleonSemanticColorsDark.scrim,
    skeletonBase: ChameleonColors.grey700,
    skeletonHighlight: ChameleonColors.grey800,
  );

  @override
  ChameleonSemanticColorsExtension copyWith({
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? outlineVariant,
    Color? scrim,
    Color? skeletonBase,
    Color? skeletonHighlight,
  }) {
    return ChameleonSemanticColorsExtension(
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      scrim: scrim ?? this.scrim,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
    );
  }

  @override
  ChameleonSemanticColorsExtension lerp(
    ThemeExtension<ChameleonSemanticColorsExtension>? other,
    double t,
  ) {
    if (other is! ChameleonSemanticColorsExtension) return this;
    return ChameleonSemanticColorsExtension(
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(
        skeletonHighlight,
        other.skeletonHighlight,
        t,
      )!,
    );
  }
}
