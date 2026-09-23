import 'package:flutter/material.dart';

import '../tokens/chameleon_colors.dart';
import '../tokens/chameleon_spacing.dart';
import '../tokens/chameleon_typography.dart';
import 'loader/chameleon_mark.dart';

/// A "nothing here yet" placeholder for an empty list/collection screen.
///
/// [icon] is a plain [Widget], not an [IconData] — it stays composable
/// with an [Icon], an [Image], an SVG, or [ChameleonMark], rather than
/// baking in one icon set.
///
/// Composes naturally as the widget a sealed bloc state's `builder`
/// returns for its empty case:
///
/// ```dart
/// switch (state) {
///   TransactionsEmpty() => const ChameleonEmptyState(
///       title: 'No transactions yet',
///       description: 'Your activity will show up here.',
///     ),
///   ...
/// }
/// ```
class ChameleonEmptyState extends StatelessWidget {
  const ChameleonEmptyState({
    required this.title,
    this.description,
    this.icon,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? description;
  final Widget? icon;

  /// Both [actionLabel] and [onAction] must be set for the action button
  /// to render — either alone renders nothing.
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    final onPressed = onAction;

    return Padding(
      padding: const EdgeInsets.all(ChameleonSpacing.xl2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(height: ChameleonSpacing.lg),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: ChameleonTypography.subheading2,
          ),
          if (description != null) ...[
            const SizedBox(height: ChameleonSpacing.xs),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: ChameleonTypography.body2.copyWith(
                color: ChameleonSemanticColors.textSecondary,
              ),
            ),
          ],
          if (label != null && onPressed != null) ...[
            const SizedBox(height: ChameleonSpacing.lg),
            ElevatedButton(onPressed: onPressed, child: Text(label)),
          ],
        ],
      ),
    );
  }
}
