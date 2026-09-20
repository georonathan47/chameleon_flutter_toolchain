import 'dart:async';

import 'package:flutter/material.dart';

import '../tokens/chameleon_colors.dart';
import '../tokens/chameleon_spacing.dart';
import '../tokens/chameleon_typography.dart';
import 'loader/chameleon_spinner.dart';

/// A blocking "please wait" dialog for work the user must not interrupt —
/// submitting a sign-up step, say.
///
/// Shows the [ChameleonSpinner] over a scrim, with an optional line of copy
/// explaining what is happening. It cannot be dismissed: neither the barrier
/// nor the system back gesture closes it, because closing it would leave the
/// in-flight request running with no indication on screen.
///
/// Open it with [show] and close it with the handle that returns:
///
/// ```dart
/// final loader = ChameleonLoadingDialog.show(context, message: 'Verifying…');
/// try {
///   await doWork();
/// } finally {
///   loader.close();
/// }
/// ```
class ChameleonLoadingDialog extends StatelessWidget {
  const ChameleonLoadingDialog({this.message, super.key});

  /// What the app is doing, shown beneath the spinner. Omit for a bare
  /// spinner.
  final String? message;

  /// Diameter of the spinning mark.
  static const double _spinnerSize = 64;

  /// Puts the dialog on screen and returns the handle that closes it again.
  ///
  /// The returned [ChameleonLoadingDialogHandle] captures the navigator up
  /// front, so it stays safe to close after an `await` — by which point the
  /// calling widget's `context` may no longer be mounted.
  static ChameleonLoadingDialogHandle show(
    BuildContext context, {
    String? message,
  }) {
    final navigator = Navigator.of(context, rootNavigator: true);

    // Not awaited: the route's future completes when the dialog closes, which
    // is the *result* of the work finishing — awaiting it here would deadlock.
    unawaited(
      showDialog<void>(
        context: context,
        // The work owns this dialog's lifetime; a stray tap must not strand a
        // request that is still in flight.
        barrierDismissible: false,
        barrierColor: ChameleonSemanticColors.scrim,
        builder: (_) => ChameleonLoadingDialog(message: message),
      ),
    );

    return ChameleonLoadingDialogHandle._(navigator);
  }

  @override
  Widget build(BuildContext context) {
    // Traps the OS back gesture: this dialog closes when the work finishes,
    // not before.
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: ChameleonSemanticColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ChameleonRadius.xl3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(ChameleonSpacing.xl2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ChameleonSpinner(size: _spinnerSize),
              if (message != null) ...[
                const SizedBox(height: ChameleonSpacing.md),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: ChameleonTypography.body2.copyWith(
                    color: ChameleonSemanticColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Closes a [ChameleonLoadingDialog] that [ChameleonLoadingDialog.show]
/// opened.
///
/// Holds the navigator rather than a `BuildContext` so it works after an
/// `await`, and closes at most once — a second [close] is a no-op, so a
/// `finally` block and an error path cannot pop the screen underneath.
class ChameleonLoadingDialogHandle {
  ChameleonLoadingDialogHandle._(this._navigator);

  final NavigatorState _navigator;
  bool _closed = false;

  /// Dismisses the dialog if it is still showing.
  void close() {
    if (_closed) return;
    _closed = true;
    if (_navigator.canPop()) _navigator.pop();
  }
}
