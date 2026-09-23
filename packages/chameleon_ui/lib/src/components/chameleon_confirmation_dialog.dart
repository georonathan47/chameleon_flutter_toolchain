import 'package:flutter/material.dart';

import '../tokens/chameleon_colors.dart';
import '../tokens/chameleon_spacing.dart';
import '../tokens/chameleon_typography.dart';
import 'chameleon_loading_dialog.dart';

/// A themed "are you sure?" dialog — destructive actions, sign-out,
/// discarding changes.
///
/// Unlike [ChameleonLoadingDialog] (which guards in-flight work and can't
/// be dismissed), this one has nothing to protect: the barrier and the
/// system back gesture both count as cancelling.
///
/// Open it with [show], which always resolves to a plain `bool` — a
/// barrier tap or back gesture resolves to `false`, same as tapping
/// [cancelLabel], so a caller never has to handle `null`:
///
/// ```dart
/// final confirmed = await ChameleonConfirmationDialog.show(
///   context,
///   title: 'Delete account?',
///   message: 'This cannot be undone.',
///   confirmLabel: 'Delete',
///   isDestructive: true,
/// );
/// if (confirmed) { ... }
/// ```
class ChameleonConfirmationDialog extends StatelessWidget {
  const ChameleonConfirmationDialog({
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  /// Recolors the confirm button to [ChameleonSemanticColors.error] — a
  /// delete/remove/sign-out action, not an ordinary confirmation.
  final bool isDestructive;

  /// Puts the dialog on screen and returns whether the user confirmed.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ChameleonConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ChameleonSemanticColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ChameleonRadius.xl3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ChameleonSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: ChameleonTypography.subheading2),
            const SizedBox(height: ChameleonSpacing.xs),
            Text(
              message,
              style: ChameleonTypography.body2.copyWith(
                color: ChameleonSemanticColors.textSecondary,
              ),
            ),
            const SizedBox(height: ChameleonSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(cancelLabel),
                ),
                const SizedBox(width: ChameleonSpacing.xs),
                FilledButton(
                  // ChameleonTheme.light's filledButtonTheme sets
                  // minimumSize: Size.fromHeight(52) — infinite width, for
                  // a full-width screen CTA. A Row gives its children
                  // unbounded width, so that default has to be overridden
                  // here or layout throws; a dialog's action button is a
                  // compact, inline control, not a full-width CTA, anyway.
                  style: FilledButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: ChameleonSpacing.lg,
                      vertical: ChameleonSpacing.sm,
                    ),
                    backgroundColor: isDestructive
                        ? ChameleonSemanticColors.error
                        : null,
                    foregroundColor: isDestructive
                        ? ChameleonColors.white
                        : null,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(confirmLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
