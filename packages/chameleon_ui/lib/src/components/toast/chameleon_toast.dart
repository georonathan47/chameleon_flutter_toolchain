import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import '../../tokens/chameleon_colors.dart';
import '../../tokens/chameleon_spacing.dart';
import '../../tokens/chameleon_typography.dart';
import '../glass_surface.dart';
import 'chameleon_toast_type.dart';

/// The toast surface.
///
/// Presentation only — it renders a title, a description and a dismiss
/// affordance, and knows nothing about timers, overlays or how it got on
/// screen. `ChameleonToastMessenger` owns that. Keeping the two apart is what
/// lets this be pumped directly in a widget test.
class ChameleonToast extends StatelessWidget {
  const ChameleonToast({
    required this.title,
    required this.description,
    required this.onDismiss,
    this.type = ChameleonToastType.announcement,
    super.key,
  });

  /// The headline, in the inverse text color.
  final String title;

  /// The supporting line beneath it.
  final String description;

  /// Invoked by the close button. Removes the toast entirely.
  final VoidCallback onDismiss;

  /// Chooses the leading icon and its tile color.
  final ChameleonToastType type;

  /// Width of the toast in the design.
  ///
  /// Applied as a *maximum* rather than a fixed width so the toast still fits
  /// a narrow device, where 362 would overflow.
  static const double maxWidth = 362;

  /// Side of the leading glyph.
  static const double _iconSize = 24;

  /// Side of the close glyph.
  static const double _closeIconSize = 15;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: '$title. $description',
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: Material(
          color: ChameleonSemanticColors.surfaceInverse,
          borderRadius: BorderRadius.circular(ChameleonRadius.xl),
          child: Padding(
            padding: const EdgeInsets.all(ChameleonSpacing.base),
            child: Row(
              children: [
                _IconTile(type: type),
                const SizedBox(width: ChameleonSpacing.xs2),
                // Takes the slack so the close button stays pinned right and
                // long copy wraps instead of overflowing.
                Expanded(
                  child: _Copy(title: title, description: description),
                ),
                const SizedBox(width: ChameleonSpacing.sm),
                _CloseButton(onPressed: onDismiss),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The tinted square holding the state's icon.
class _IconTile extends StatelessWidget {
  const _IconTile({required this.type});

  /// Inset around the 24px glyph, giving the design's 44x44 tile.
  ///
  /// Not on the spacing scale — it sits between `xs` (8) and `sm` (12) — so it
  /// is named here rather than rounded to a token that would change the tile's
  /// designed size.
  static const double _tilePadding = 10;

  final ChameleonToastType type;

  @override
  Widget build(BuildContext context) {
    return GlobalGlassSurface(
      fillColor: ChameleonColors.white.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(ChameleonRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(_tilePadding),
        decoration: BoxDecoration(
          color: type.tileColor,
          borderRadius: BorderRadius.circular(ChameleonRadius.xl),
        ),
        child: SizedBox.square(
          dimension: ChameleonToast._iconSize,
          child: Center(
            child: SvgPicture.asset(
              type.iconPath,
              width: ChameleonToast._iconSize,
              height: ChameleonToast._iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

/// Title over description.
class _Copy extends StatelessWidget {
  const _Copy({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ChameleonTypography.subheading3.copyWith(
            color: ChameleonSemanticColors.textPrimaryInverse,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.25,
          ),
          // One line each, per the design: a toast is glanced at, not read.
          // Longer copy ellipsizes rather than growing the surface.
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: ChameleonSpacing.xxs),
        Text(
          description,
          style: ChameleonTypography.body2.copyWith(
            color: ChameleonSemanticColors.textDisabled,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// The circular close affordance.
///
/// Dismisses the toast outright — there is no undo, so it is deliberately a
/// small target sitting away from the copy rather than a full-width action.
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  /// Side of the close button's frame, per the design.
  static const double _closeButtonSize = 30;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Dismiss notification',
      // 30x30 per the design. The glyph itself is 15px, so the surrounding
      // frame doubles as the tap target; `MaterialTapTargetSize.shrinkWrap`
      // would fight the design's geometry, so the frame is sized explicitly
      // and the hit test allowed to fill it.
      child: SizedBox.square(
        dimension: _closeButtonSize,
        child: GlobalGlassSurface(
          fillColor: ChameleonColors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(70),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Center(
              child: SvgPicture.asset(
                'packages/chameleon_ui/assets/svg/toast/close.svg',
                width: ChameleonToast._closeIconSize,
                height: ChameleonToast._closeIconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
