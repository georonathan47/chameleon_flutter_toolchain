import 'package:flutter/widgets.dart';

import '../../tokens/chameleon_colors.dart';

/// The visual states the toast ships with.
///
/// Each state pairs an icon with the tint behind it. The surface, typography
/// and layout are identical across all five — only the leading glyph and its
/// tile colour change — so the variants live here as data rather than as five
/// near-identical widgets.
///
/// [announcement] is the default: it is the one state that carries no outcome,
/// so a caller who passes only a title and description is not implicitly
/// reporting success or failure.
enum ChameleonToastType {
  /// General notice. The neutral default.
  announcement(
    assetName: 'announcement',
    // Designed as a translucent wash over the dark surface rather than a solid
    // container colour, so the tile reads as lit from within.
    tileColor: Color(0x30DFF7FF),
  ),

  /// Something went wrong.
  error(
    assetName: 'error',
    tileColor: ChameleonSemanticColors.errorContainer,
  ),

  /// Something finished successfully.
  success(
    assetName: 'success',
    tileColor: Color(0x17E0F9E9),
  ),

  /// Money moved.
  payment(
    assetName: 'payment',
    tileColor: ChameleonSemanticColors.warningContainer,
  ),

  /// A date-bound reminder.
  appointment(
    assetName: 'appointment',
    tileColor: Color(0x14F3FFC8),
  );

  const ChameleonToastType({required this.assetName, required this.tileColor});

  /// Basename of the exported SVG in `assets/svg/toast/`.
  final String assetName;

  /// Fill behind the leading icon.
  final Color tileColor;

  /// Path to the icon.
  ///
  /// Resolved via the `chameleon_ui` package's own asset bundle
  /// (`packages/chameleon_ui/assets/svg/toast/...`) so the host app does not
  /// need to ship these SVGs itself.
  String get iconPath => 'packages/chameleon_ui/assets/svg/toast/$assetName.svg';
}
