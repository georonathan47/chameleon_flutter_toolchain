import 'package:flutter/material.dart';

import '../tokens/chameleon_colors.dart';
import '../tokens/chameleon_spacing.dart';
import '../tokens/chameleon_typography.dart';
import 'chameleon_semantic_colors_extension.dart';

/// Assembles the Chameleon [ThemeData] from the design-system layers
/// ([ChameleonColors]/[ChameleonSemanticColors], [ChameleonTypography],
/// [ChameleonSpacing]/[ChameleonRadius]).
///
/// [light] and [dark] are structurally identical — same [ColorScheme]
/// shape, same theme blocks — differing only in which semantic-color class
/// backs them ([ChameleonSemanticColors] vs [ChameleonSemanticColorsDark]).
/// Each also registers a [ChameleonSemanticColorsExtension], the handful of
/// roles `chameleon_ui`'s own bespoke components need that [ColorScheme]
/// doesn't cover.
abstract final class ChameleonTheme {
  /// The Chameleon light theme.
  static ThemeData get light => _build(
    brightness: Brightness.light,
    colors: _Colors.light,
    extension: ChameleonSemanticColorsExtension.light,
  );

  /// The Chameleon dark theme.
  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    colors: _Colors.dark,
    extension: ChameleonSemanticColorsExtension.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required _Colors colors,
    required ChameleonSemanticColorsExtension extension,
  }) {
    // ColorScheme.light()/.dark() specifically, not the base ColorScheme()
    // constructor: the two factories bake in sane Material defaults for
    // every field this class doesn't override (surfaceTint, shadow,
    // secondaryContainer, tertiary, ...) — several of which (surfaceTint,
    // shadow) feed real elevation-overlay rendering on Card/Dialog/
    // FilledButton under Material 3. The base constructor derives those
    // differently; using the matching factory keeps `light` pixel-identical
    // to before this file added `dark`.
    final colorScheme = brightness == Brightness.dark
        ? ColorScheme.dark(
            primary: colors.primary,
            onPrimary: colors.onPrimary,
            primaryContainer: colors.primaryContainer,
            onPrimaryContainer: colors.onPrimaryContainer,
            secondary: colors.secondary,
            onSecondary: colors.onSecondary,
            error: colors.error,
            errorContainer: colors.errorContainer,
            onErrorContainer: colors.onErrorContainer,
            surface: colors.surface,
            onSurface: colors.textPrimary,
            onSurfaceVariant: colors.textHelper,
            outline: colors.outline,
            outlineVariant: colors.outlineVariant,
          )
        : ColorScheme.light(
            primary: colors.primary,
            onPrimary: colors.onPrimary,
            primaryContainer: colors.primaryContainer,
            onPrimaryContainer: colors.onPrimaryContainer,
            secondary: colors.secondary,
            onSecondary: colors.onSecondary,
            error: colors.error,
            errorContainer: colors.errorContainer,
            onErrorContainer: colors.onErrorContainer,
            surface: colors.surface,
            onSurface: colors.textPrimary,
            onSurfaceVariant: colors.textHelper,
            outline: colors.outline,
            outlineVariant: colors.outlineVariant,
          );

    // TextTheme.apply — not a chameleon_typography.dart change — overrides
    // the light-only color ChameleonTypography._style() bakes into every
    // style by default. Without this, a plain, unstyled Text widget (which
    // inherits Theme.of(context).textTheme, not an explicit
    // ChameleonTypography getter) would stay nearly invisible against a
    // dark surface.
    final textTheme = ChameleonTypography.textTheme.apply(
      bodyColor: colors.textPrimary,
      displayColor: colors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.surface,
      textTheme: textTheme,
      fontFamily: ChameleonTypography.fontFamily,
      extensions: [extension],

      // Top app bar.
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: ChameleonTypography.subheading2.copyWith(
          color: colors.onPrimary,
        ),
      ),

      // Cards.
      cardTheme: CardThemeData(
        color: colors.cardSurface,
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
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.disabledButtonBackground,
          disabledForegroundColor: colors.textDisabled,
          padding: const EdgeInsets.symmetric(horizontal: ChameleonSpacing.lg),
          textStyle: ChameleonTypography.label1,
        ),
      ),

      // Medium-emphasis (secondary) buttons — muted gold.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          minimumSize: const Size.fromHeight(52),
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.disabledButtonBackground,
          disabledForegroundColor: colors.textDisabled,
          textStyle: ChameleonTypography.label1.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Low-emphasis (tertiary / ghost) buttons.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.textButtonForeground,
          textStyle: ChameleonTypography.label1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ChameleonRadius.lg),
          ),
        ),
      ),

      // Text inputs.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ChameleonSpacing.base,
          vertical: ChameleonSpacing.sm,
        ),
        labelStyle: ChameleonTypography.body2.copyWith(
          color: colors.inputLabel,
        ),
        hintStyle: ChameleonTypography.body2.copyWith(
          color: colors.textHelper,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ChameleonRadius.xl),
          borderSide: BorderSide(color: colors.inputBorderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ChameleonRadius.xl),
          borderSide: BorderSide(color: colors.inputBorderFocus, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ChameleonRadius.xl),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ChameleonRadius.xl),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
      ),

      // Bottom navigation.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.navBarContainer,
        indicatorColor: colors.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(ChameleonTypography.label3),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? colors.navBarIconActive
                : colors.navBarIconInactive,
          );
        }),
      ),

      // Dividers.
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Icons.
      iconTheme: IconThemeData(color: colors.iconDefault),
    );
  }
}

/// The subset of semantic-color fields `_build` needs, resolved once per
/// brightness so the method body above reads identically for both themes
/// instead of branching per-field.
enum _Colors {
  light(
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
    textPrimary: ChameleonSemanticColors.textPrimary,
    textHelper: ChameleonSemanticColors.textHelper,
    textDisabled: ChameleonSemanticColors.textDisabled,
    outline: ChameleonSemanticColors.outline,
    outlineVariant: ChameleonSemanticColors.outlineVariant,
    // These three spots used a raw ChameleonColors primitive directly even
    // before dark mode existed — kept that way here rather than promoting
    // them to new semantic roles nothing else needs.
    cardSurface: ChameleonColors.grey100,
    disabledButtonBackground: ChameleonColors.yellow300,
    textButtonForeground: ChameleonColors.grey850,
    inputContainer: ChameleonSemanticColors.inputContainer,
    inputLabel: ChameleonSemanticColors.inputLabel,
    inputBorderDefault: ChameleonSemanticColors.inputBorderDefault,
    inputBorderFocus: ChameleonSemanticColors.inputBorderFocus,
    navBarContainer: ChameleonSemanticColors.navBarContainer,
    navBarIconActive: ChameleonSemanticColors.navBarIconActive,
    navBarIconInactive: ChameleonSemanticColors.navBarIconInactive,
    iconDefault: ChameleonSemanticColors.iconDefault,
  ),

  dark(
    primary: ChameleonSemanticColorsDark.primary,
    onPrimary: ChameleonSemanticColorsDark.onPrimary,
    primaryContainer: ChameleonSemanticColorsDark.primaryContainer,
    onPrimaryContainer: ChameleonSemanticColorsDark.onPrimaryContainer,
    secondary: ChameleonSemanticColorsDark.secondary,
    onSecondary: ChameleonSemanticColorsDark.onSecondary,
    error: ChameleonSemanticColorsDark.error,
    errorContainer: ChameleonSemanticColorsDark.errorContainer,
    onErrorContainer: ChameleonSemanticColorsDark.onErrorContainer,
    surface: ChameleonSemanticColorsDark.surface,
    textPrimary: ChameleonSemanticColorsDark.textPrimary,
    textHelper: ChameleonSemanticColorsDark.textHelper,
    textDisabled: ChameleonSemanticColorsDark.textDisabled,
    outline: ChameleonSemanticColorsDark.outline,
    outlineVariant: ChameleonSemanticColorsDark.outlineVariant,
    cardSurface: ChameleonColors.grey800,
    disabledButtonBackground: ChameleonColors.yellow900,
    textButtonForeground: ChameleonColors.grey100,
    inputContainer: ChameleonSemanticColorsDark.inputContainer,
    inputLabel: ChameleonSemanticColorsDark.inputLabel,
    inputBorderDefault: ChameleonSemanticColorsDark.inputBorderDefault,
    inputBorderFocus: ChameleonSemanticColorsDark.inputBorderFocus,
    navBarContainer: ChameleonSemanticColorsDark.navBarContainer,
    navBarIconActive: ChameleonSemanticColorsDark.navBarIconActive,
    navBarIconInactive: ChameleonSemanticColorsDark.navBarIconInactive,
    iconDefault: ChameleonSemanticColorsDark.iconDefault,
  );

  const _Colors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.error,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.surface,
    required this.textPrimary,
    required this.textHelper,
    required this.textDisabled,
    required this.outline,
    required this.outlineVariant,
    required this.cardSurface,
    required this.disabledButtonBackground,
    required this.textButtonForeground,
    required this.inputContainer,
    required this.inputLabel,
    required this.inputBorderDefault,
    required this.inputBorderFocus,
    required this.navBarContainer,
    required this.navBarIconActive,
    required this.navBarIconInactive,
    required this.iconDefault,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color error;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color surface;
  final Color textPrimary;
  final Color textHelper;
  final Color textDisabled;
  final Color outline;
  final Color outlineVariant;
  final Color cardSurface;
  final Color disabledButtonBackground;
  final Color textButtonForeground;
  final Color inputContainer;
  final Color inputLabel;
  final Color inputBorderDefault;
  final Color inputBorderFocus;
  final Color navBarContainer;
  final Color navBarIconActive;
  final Color navBarIconInactive;
  final Color iconDefault;
}
