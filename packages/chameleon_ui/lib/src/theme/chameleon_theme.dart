import 'package:flutter/material.dart';

import '../tokens/chameleon_colors.dart';
import '../tokens/chameleon_spacing.dart';
import '../tokens/chameleon_typography.dart';

/// Assembles the Chameleon [ThemeData] from the design-system layers
/// ([ChameleonColors]/[ChameleonSemanticColors], [ChameleonTypography],
/// [ChameleonSpacing]/[ChameleonRadius]).
///
/// Only a light theme is defined for now; the design tokens are predominantly
/// light. A dark theme can be added once dark values exist.
abstract final class ChameleonTheme {
  /// The Chameleon light theme.
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: ChameleonSemanticColors.primary,
      onPrimary: ChameleonSemanticColors.onPrimary,
      primaryContainer: ChameleonSemanticColors.primaryContainer,
      onPrimaryContainer: ChameleonSemanticColors.onPrimaryContainer,
      secondary: ChameleonSemanticColors.secondary,
      onSecondary: ChameleonSemanticColors.onSecondary,
      error: ChameleonSemanticColors.error,
      errorContainer: ChameleonSemanticColors.errorContainer,
      onErrorContainer: ChameleonSemanticColors.onErrorContainer,
      surface: ChameleonSemanticColors.surface,
      onSurface: ChameleonSemanticColors.textPrimary,
      onSurfaceVariant: ChameleonSemanticColors.textHelper,
      outline: ChameleonSemanticColors.outline,
      outlineVariant: ChameleonSemanticColors.outlineVariant,
    );

    final textTheme = ChameleonTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ChameleonSemanticColors.surface,
      textTheme: textTheme,
      fontFamily: ChameleonTypography.fontFamily,

      // Top app bar.
      appBarTheme: AppBarTheme(
        backgroundColor: ChameleonSemanticColors.primary,
        foregroundColor: ChameleonSemanticColors.onPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: ChameleonTypography.subheading2.copyWith(
          color: ChameleonSemanticColors.onPrimary,
        ),
      ),

      // Cards.
      cardTheme: CardThemeData(
        color: ChameleonColors.grey100,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ChameleonRadius.xl2),
        ),
      ),

      // Primary (high-emphasis) buttons.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: ChameleonSpacing.xxs,
          shape: const StadiumBorder(),
          minimumSize: const Size.fromHeight(52),
          backgroundColor: ChameleonSemanticColors.primary,
          foregroundColor: ChameleonSemanticColors.onPrimary,
          disabledBackgroundColor: ChameleonColors.yellow300,
          disabledForegroundColor: ChameleonSemanticColors.textDisabled,
          padding: const EdgeInsets.symmetric(horizontal: ChameleonSpacing.lg),
          textStyle: ChameleonTypography.label1,
        ),
      ),

      // Medium-emphasis (secondary) buttons — muted gold.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          minimumSize: const Size.fromHeight(52),
          backgroundColor: ChameleonSemanticColors.primary,
          foregroundColor: ChameleonSemanticColors.onPrimary,
          disabledBackgroundColor: ChameleonColors.yellow300,
          disabledForegroundColor: ChameleonSemanticColors.textDisabled,
          textStyle: ChameleonTypography.label1.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Low-emphasis (tertiary / ghost) buttons.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ChameleonColors.grey850,
          textStyle: ChameleonTypography.label1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ChameleonRadius.lg),
          ),
        ),
      ),

      // Text inputs.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ChameleonSemanticColors.inputContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ChameleonSpacing.base,
          vertical: ChameleonSpacing.sm,
        ),
        labelStyle: ChameleonTypography.body2.copyWith(
          color: ChameleonSemanticColors.inputLabel,
        ),
        hintStyle: ChameleonTypography.body2.copyWith(
          color: ChameleonSemanticColors.textHelper,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ChameleonRadius.xl),
          borderSide: const BorderSide(
            color: ChameleonSemanticColors.inputBorderDefault,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ChameleonRadius.xl),
          borderSide: const BorderSide(
            color: ChameleonSemanticColors.inputBorderFocus,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ChameleonRadius.xl),
          borderSide: const BorderSide(color: ChameleonSemanticColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ChameleonRadius.xl),
          borderSide: const BorderSide(
            color: ChameleonSemanticColors.error,
            width: 1.5,
          ),
        ),
      ),

      // Bottom navigation.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ChameleonSemanticColors.navBarContainer,
        indicatorColor: ChameleonSemanticColors.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(ChameleonTypography.label3),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? ChameleonSemanticColors.navBarIconActive
                : ChameleonSemanticColors.navBarIconInactive,
          );
        }),
      ),

      // Dividers.
      dividerTheme: const DividerThemeData(
        color: ChameleonSemanticColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Icons.
      iconTheme: const IconThemeData(
        color: ChameleonSemanticColors.iconDefault,
      ),
    );
  }
}
