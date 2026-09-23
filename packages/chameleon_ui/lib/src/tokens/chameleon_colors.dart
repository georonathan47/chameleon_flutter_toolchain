import 'package:flutter/material.dart';

/// Chameleon color palette.
///
/// Structure mirrors the token hierarchy:
/// * [ChameleonColors] — the raw primitive palette (the source-of-truth
///   swatches, e.g. `yellow500`).
/// * [ChameleonSemanticColors] — meaningful, role-based aliases
///   (`textPrimary`, `surface`, `primary`, ...) that map onto the
///   primitives. UI code should prefer these semantic names so the palette
///   can evolve without touching widgets.
///
/// All values are compile-time constants.
abstract final class ChameleonColors {
  // ---------------------------------------------------------------------------
  // Yellow (brand primary) — ROOTS.yellow*
  // ---------------------------------------------------------------------------
  /// Cream wash behind a selected choice card.
  static const Color yellow50 = Color(0xFFFBF4DC);
  static const Color yellow100 = Color(0xFFFFF8D9);
  static const Color yellow200 = Color(0xFFFFEEA8);
  static const Color yellow300 = Color(0xFFFFE476);
  static const Color yellow400 = Color(0xFFFFDB4C);

  /// Signature primary brand color.
  static const Color yellow500 = Color(0xFFFFD100);
  static const Color yellow600 = Color(0xFFD9B62F);
  static const Color yellow700 = Color(0xFF9A7E1F);
  static const Color yellow800 = Color(0xFF8E711C);
  static const Color yellow900 = Color(0xFF6A5314);
  static const Color yellow1000 = Color(0xFF322709);

  // ---------------------------------------------------------------------------
  // Gold — ROOTS.gold*
  // ---------------------------------------------------------------------------
  static const Color gold100 = Color(0xFFFAF6E4);
  static const Color gold200 = Color(0xFFFAF2CE);
  static const Color gold300 = Color(0xFFF0E4AF);
  static const Color gold400 = Color(0xFFE5D379);
  static const Color gold500 = Color(0xFFDBC144);
  static const Color gold600 = Color(0xFFBBA124);
  static const Color gold700 = Color(0xFF86731A);
  static const Color gold800 = Color(0xFF50450F);
  static const Color gold900 = Color(0xFF1B1705);

  // ---------------------------------------------------------------------------
  // Grey (neutrals) — ROOTS.grey*
  // ---------------------------------------------------------------------------
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF8F9FA);
  static const Color grey100 = Color(0xFFF8F9FA);

  /// Progress-track background.
  static const Color grey150 = Color(0xFFE6E6E6);
  static const Color grey200 = Color(0xFFE9ECEF);

  /// Disabled input-field fill.
  static const Color grey250 = Color(0xFFEDEDED);
  static const Color grey300 = Color(0xFFDEE2E6);

  /// Disabled input-field border.
  static const Color grey350 = Color(0xFFD1D5DC);
  static const Color grey400 = Color(0xFFCED4DA);

  /// Outline of the auth gate's choice cards.
  static const Color grey450 = Color(0xFFC1C1C1);
  static const Color grey500 = Color(0xFFADB5BD);

  /// Fill base of the auth gate's choice cards, washed back to 20% over the
  /// white field.
  static const Color grey620 = Color(0xFF626262);

  /// Cool step-indicator grey.
  static const Color grey550 = Color(0xFF667085);
  static const Color grey600 = Color(0xFF868E96);
  static const Color grey700 = Color(0xFF495057);
  static const Color grey800 = Color(0xFF343A40);
  static const Color grey840 = Color(0xFF333F48);
  static const Color grey850 = Color(0xFF202428);

  /// 20% opacity of [grey850], used for modal scrims.
  static const Color grey850Alpha20 = Color(0x33202428);
  static const Color grey860 = Color(0xFF1A1C1E);
  static const Color grey900 = Color(0xFF181A1B);
  static const Color grey1000 = Color(0xFF000000);

  // ---------------------------------------------------------------------------
  // Red (error) — ROOTS.red*
  // ---------------------------------------------------------------------------
  static const Color red100 = Color(0xFFF7CFD2);
  static const Color red200 = Color(0xFFEF9FA5);
  static const Color red300 = Color(0xFFE66F78);
  static const Color red400 = Color(0xFFDE3F4B);
  static const Color red500 = Color(0xFFD60F1E);
  static const Color red600 = Color(0xFFAB0C18);
  static const Color red700 = Color(0xFF800912);
  static const Color red800 = Color(0xFF56060C);
  static const Color red900 = Color(0xFF2B0306);

  // ---------------------------------------------------------------------------
  // Green (success) — ROOTS.green*
  // ---------------------------------------------------------------------------
  static const Color green100 = Color(0xFFE8F5F4);
  static const Color green200 = Color(0xFFDDF0EE);
  static const Color green300 = Color(0xFFB8DFDC);
  static const Color green400 = Color(0xFF1A998E);
  static const Color green500 = Color(0xFF178A80);
  static const Color green600 = Color(0xFF157A72);
  static const Color green700 = Color(0xFF14736B);
  static const Color green800 = Color(0xFF105C55);
  static const Color green900 = Color(0xFF0C4540);
  static const Color green1000 = Color(0xFF093632);

  // ---------------------------------------------------------------------------
  // Blue (info) — ROOTS.blue*
  // ---------------------------------------------------------------------------
  static const Color blue100 = Color(0xFFCFE6F7);
  static const Color blue200 = Color(0xFF9FCCEF);
  static const Color blue300 = Color(0xFF6FB3E6);
  static const Color blue400 = Color(0xFF3F99DE);
  static const Color blue500 = Color(0xFF0F80D6);
  static const Color blue600 = Color(0xFF0C66AB);
  static const Color blue700 = Color(0xFF094D80);
  static const Color blue800 = Color(0xFF063356);
  static const Color blue900 = Color(0xFF031A2B);

  // ---------------------------------------------------------------------------
  // Orange (secondary) — ROOTS.orange*
  // ---------------------------------------------------------------------------
  static const Color orange100 = Color(0xFFFCE8CD);
  static const Color orange200 = Color(0xFFFAD19B);
  static const Color orange300 = Color(0xFFF7B96A);
  static const Color orange400 = Color(0xFFF5A238);
  static const Color orange500 = Color(0xFFF28B06);
  static const Color orange600 = Color(0xFFC26F05);
  static const Color orange700 = Color(0xFF915304);
  static const Color orange800 = Color(0xFF613802);
  static const Color orange900 = Color(0xFF301C01);

  // ---------------------------------------------------------------------------
  // Platinum Bronze (premium accents) — ROOTS.platinumBronze*
  // ---------------------------------------------------------------------------
  static const Color platinumBronze100 = Color(0xFFF4F1ED);
  static const Color platinumBronze200 = Color(0xFFE9E3DB);
  static const Color platinumBronze300 = Color(0xFFDED5C9);
  static const Color platinumBronze400 = Color(0xFF9D8F79);
  static const Color platinumBronze500 = Color(0xFF8C734C);
  static const Color platinumBronze600 = Color(0xFF7E6844);
  static const Color platinumBronze700 = Color(0xFF705C3D);
  static const Color platinumBronze800 = Color(0xFF54452E);
  static const Color platinumBronze900 = Color(0xFF463A26);
  static const Color platinumBronze1000 = Color(0xFF382E1E);

  // ---------------------------------------------------------------------------
  // Platinum Grey (premium neutrals) — ROOTS.platinumGrey*
  // ---------------------------------------------------------------------------
  static const Color platinumGrey100 = Color(0xFFF6F6F4);
  static const Color platinumGrey200 = Color(0xFFEDEDE9);
  static const Color platinumGrey300 = Color(0xFFE4E4DE);
  static const Color platinumGrey400 = Color(0xFFBCBBB9);
  static const Color platinumGrey500 = Color(0xFFA4A292);
  static const Color platinumGrey600 = Color(0xFF838174);
  static const Color platinumGrey700 = Color(0xFF626158);
  static const Color platinumGrey800 = Color(0xFF525149);
  static const Color platinumGrey900 = Color(0xFF42413B);
  static const Color platinumGrey1000 = Color(0xFF21201D);
}

/// Role-based semantic color aliases.
///
/// These map the raw [ChameleonColors] primitives onto meaningful roles. UI
/// code should use these names (via the `ColorScheme` where possible) rather
/// than raw swatches.
abstract final class ChameleonSemanticColors {
  // Brand / primary action.
  static const Color primary = ChameleonColors.yellow500;
  static const Color primaryHover = ChameleonColors.yellow600;
  static const Color onPrimary = ChameleonColors.yellow900;
  static const Color primaryContainer = ChameleonColors.yellow200;
  static const Color onPrimaryContainer = ChameleonColors.yellow1000;

  // Secondary (muted brand).
  static const Color secondary = ChameleonColors.orange500;
  static const Color onSecondary = ChameleonColors.yellow800;

  // Surfaces & scaffolding.
  static const Color surface = ChameleonColors.grey50;
  static const Color surfaceBright = ChameleonColors.grey50;
  static const Color surfaceContainer = ChameleonColors.grey200;
  static const Color surfaceDim = ChameleonColors.grey100;
  static const Color scrim = ChameleonColors.grey850Alpha20;

  /// The dark field used by surfaces that invert the app's light scheme —
  /// the toast, for one. Pairs with [textPrimaryInverse] for its copy.
  static const Color surfaceInverse = ChameleonColors.grey900;

  /// The auth gate's choice cards: a 20% grey wash over the white field, so
  /// they read as raised without carrying a shadow.
  static const Color surfaceChoiceCard = Color(0x33626262);

  /// The selected choice card trades the grey wash for an opaque brand cream.
  static const Color surfaceChoiceCardSelected = ChameleonColors.yellow50;

  // Typography / content.
  static const Color textPrimary = ChameleonColors.grey900;
  static const Color textPrimaryInverse = ChameleonColors.grey100;
  static const Color textSecondary = ChameleonColors.grey700;
  static const Color textHelper = ChameleonColors.grey600;
  static const Color textDisabled = ChameleonColors.grey500;

  /// The "Step N of M" counter in the sign-up flow chrome.
  static const Color textStepIndicator = ChameleonColors.grey550;
  static const Color textLink = ChameleonColors.blue600;
  static const Color textBrandBold = ChameleonColors.yellow800;

  // Borders / outlines.
  static const Color outline = ChameleonColors.grey400;
  static const Color outlineVariant = ChameleonColors.grey300;

  /// Hairline around the auth gate's choice cards.
  static const Color outlineChoiceCard = ChameleonColors.grey450;

  // Feedback states.
  static const Color success = ChameleonColors.green600;
  static const Color onSuccessContainer = ChameleonColors.green900;
  static const Color successContainer = ChameleonColors.green300;
  static const Color error = ChameleonColors.red600;
  static const Color onErrorContainer = ChameleonColors.red900;
  static const Color errorContainer = ChameleonColors.red200;
  static const Color warning = ChameleonColors.yellow700;
  static const Color onWarningContainer = ChameleonColors.orange900;
  static const Color warningContainer = ChameleonColors.orange200;
  static const Color info = ChameleonColors.blue600;
  static const Color infoContainer = ChameleonColors.blue200;

  // Financial data (money in / money out).
  static const Color amountPositive = ChameleonColors.green600;
  static const Color amountNegative = ChameleonColors.grey800;

  // Inputs.
  static const Color inputBorderDefault = ChameleonColors.grey400;
  static const Color inputBorderFocus = ChameleonColors.yellow500;
  static const Color inputContainer = ChameleonColors.grey50;
  static const Color inputLabel = ChameleonColors.grey600;

  // Navigation.
  static const Color navBarIconActive = ChameleonColors.grey900;
  static const Color navBarIconInactive = ChameleonColors.grey600;
  static const Color navBarContainer = ChameleonColors.grey100;
  static const Color tabIndicatorActive = ChameleonColors.yellow500;

  // Icons.
  static const Color iconDefault = ChameleonColors.grey860;
  static const Color iconAction = ChameleonColors.yellow500;
  static const Color iconDisabled = ChameleonColors.grey600;
}

/// Dark-mode counterpart to [ChameleonSemanticColors] — the same roles,
/// built from the same [ChameleonColors] primitive ramps rather than a
/// parallel hardcoded palette, per one consistent rule instead of a
/// field-by-field justification:
///
/// * Brand/feedback hues (`primary`, `secondary`, `error`, `success`,
///   `warning`, `info`) stay the same — only their *container* pairing
///   flips (a darker container, a lighter on-container text), standard
///   Material dark-theme practice.
/// * Neutrals invert: `surface*` moves to the dark end of the grey ramp,
///   `text*` moves to the light end, `outline*` sits mid-dark.
/// * [amountNegative] (neutral text on a light background in the light
///   palette) becomes a light grey to keep the same contrast intent on a
///   dark one.
///
/// Kept in step with [ChameleonSemanticColors]: every field there has a
/// counterpart here, even a couple ([surfaceInverse], [textPrimaryInverse])
/// nothing currently reads — `ChameleonToastMessenger` is deliberately
/// brightness-invariant (see its own doc comment) and never consults this
/// class, but a future dark-aware "inverse surface" consumer should still
/// find a correctly-mirrored value waiting here.
abstract final class ChameleonSemanticColorsDark {
  // Brand / primary action.
  static const Color primary = ChameleonColors.yellow500;
  static const Color primaryHover = ChameleonColors.yellow400;
  static const Color onPrimary = ChameleonColors.yellow1000;
  static const Color primaryContainer = ChameleonColors.yellow900;
  static const Color onPrimaryContainer = ChameleonColors.yellow200;

  // Secondary (muted brand).
  static const Color secondary = ChameleonColors.orange500;
  static const Color onSecondary = ChameleonColors.yellow800;

  // Surfaces & scaffolding.
  static const Color surface = ChameleonColors.grey900;
  static const Color surfaceBright = ChameleonColors.grey850;
  static const Color surfaceContainer = ChameleonColors.grey800;
  static const Color surfaceDim = ChameleonColors.grey1000;
  static const Color scrim = ChameleonColors.grey850Alpha20;

  /// See [ChameleonSemanticColors.surfaceInverse] — unused today (the
  /// toast never consults this class), kept as a correct mirror.
  static const Color surfaceInverse = ChameleonColors.grey100;

  /// A translucent white wash instead of light's grey one — over a dark
  /// base surface, a mid-grey wash would read as unintentionally bright.
  static const Color surfaceChoiceCard = Color(0x33FFFFFF);

  /// A deep brand yellow instead of light's cream — trades the wash for
  /// an opaque brand fill either way, just picked from the dark end.
  static const Color surfaceChoiceCardSelected = ChameleonColors.yellow900;

  // Typography / content.
  static const Color textPrimary = ChameleonColors.grey100;
  static const Color textPrimaryInverse = ChameleonColors.grey900;
  static const Color textSecondary = ChameleonColors.grey400;
  static const Color textHelper = ChameleonColors.grey500;
  static const Color textDisabled = ChameleonColors.grey600;
  static const Color textStepIndicator = ChameleonColors.grey450;
  static const Color textLink = ChameleonColors.blue400;
  static const Color textBrandBold = ChameleonColors.yellow400;

  // Borders / outlines.
  static const Color outline = ChameleonColors.grey600;
  static const Color outlineVariant = ChameleonColors.grey700;
  static const Color outlineChoiceCard = ChameleonColors.grey550;

  // Feedback states.
  static const Color success = ChameleonColors.green600;
  static const Color onSuccessContainer = ChameleonColors.green200;
  static const Color successContainer = ChameleonColors.green900;
  static const Color error = ChameleonColors.red600;
  static const Color onErrorContainer = ChameleonColors.red200;
  static const Color errorContainer = ChameleonColors.red900;
  static const Color warning = ChameleonColors.yellow700;
  static const Color onWarningContainer = ChameleonColors.orange200;
  static const Color warningContainer = ChameleonColors.orange900;
  static const Color info = ChameleonColors.blue600;
  static const Color infoContainer = ChameleonColors.blue900;

  // Financial data (money in / money out).
  static const Color amountPositive = ChameleonColors.green600;
  static const Color amountNegative = ChameleonColors.grey200;

  // Inputs.
  static const Color inputBorderDefault = ChameleonColors.grey600;
  static const Color inputBorderFocus = ChameleonColors.yellow500;
  static const Color inputContainer = ChameleonColors.grey850;
  static const Color inputLabel = ChameleonColors.grey400;

  // Navigation.
  static const Color navBarIconActive = ChameleonColors.grey100;
  static const Color navBarIconInactive = ChameleonColors.grey500;
  static const Color navBarContainer = ChameleonColors.grey850;
  static const Color tabIndicatorActive = ChameleonColors.yellow500;

  // Icons.
  static const Color iconDefault = ChameleonColors.grey300;
  static const Color iconAction = ChameleonColors.yellow500;
  static const Color iconDisabled = ChameleonColors.grey700;
}
