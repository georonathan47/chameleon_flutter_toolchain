import 'package:flutter/material.dart';

import '../theme/chameleon_semantic_colors_extension.dart';
import '../tokens/chameleon_spacing.dart';

/// A themed modal bottom sheet — a rounded top edge, a drag handle, and
/// padding that gets out of the way of both the on-screen keyboard and a
/// gesture-nav safe area, so a form dropped straight into [child] doesn't
/// need to think about either.
///
/// Open it with [show]:
///
/// ```dart
/// final result = await ChameleonBottomSheet.show<String>(
///   context,
///   child: const FilterOptions(),
/// );
/// ```
class ChameleonBottomSheet extends StatelessWidget {
  const ChameleonBottomSheet({required this.child, super.key});

  /// The sheet's content, below the drag handle.
  final Widget child;

  /// Puts the sheet on screen and returns whatever it's popped with.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    final colors =
        Theme.of(
          context,
        ).extension<ChameleonSemanticColorsExtension>() ??
        ChameleonSemanticColorsExtension.light;

    return showModalBottomSheet<T>(
      context: context,
      // Content is arbitrary — a tall form, say — so the sheet has to be
      // free to grow past half the screen and shift for the keyboard,
      // which only happens with this on.
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        // Matches CardThemeData's own radius — this reads as a raised
        // surface, not a floating dialog (that's ChameleonRadius.xl3, see
        // ChameleonConfirmationDialog/ChameleonLoadingDialog).
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ChameleonRadius.xl2),
        ),
      ),
      builder: (_) => ChameleonBottomSheet(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(
          context,
        ).extension<ChameleonSemanticColorsExtension>() ??
        ChameleonSemanticColorsExtension.light;
    final bottomInset =
        MediaQuery.viewInsetsOf(context).bottom +
        MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        ChameleonSpacing.base,
        ChameleonSpacing.sm,
        ChameleonSpacing.base,
        ChameleonSpacing.base + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              borderRadius: BorderRadius.circular(ChameleonRadius.full),
            ),
          ),
          const SizedBox(height: ChameleonSpacing.sm),
          child,
        ],
      ),
    );
  }
}
