import 'package:alchemist/alchemist.dart';
import 'package:chameleon_ui/chameleon_ui.dart';
import 'package:flutter/material.dart';

void main() {
  goldenTest(
    'ChameleonTheme renders the component gallery',
    fileName: 'chameleon_theme_gallery',
    builder: () => Theme(
      data: ChameleonTheme.light,
      child: Material(
        color: Colors.transparent,
        child: GoldenTestGroup(
          columns: 2,
          children: [
            GoldenTestScenario(
              name: 'elevated button',
              child: const _Padded(child: _ElevatedButtonSample()),
            ),
            GoldenTestScenario(
              name: 'text field',
              child: const _Padded(child: _TextFieldSample()),
            ),
            GoldenTestScenario(
              name: 'toast — error',
              child: const _Padded(
                child: _ToastSample(ChameleonToastType.error),
              ),
            ),
            GoldenTestScenario(
              name: 'toast — success',
              child: const _Padded(
                child: _ToastSample(ChameleonToastType.success),
              ),
            ),
            GoldenTestScenario(
              name: 'toast — custom colors',
              child: const _Padded(
                child: _ToastSample(
                  ChameleonToastType.announcement,
                  backgroundColor: ChameleonColors.blue900,
                  foregroundColor: ChameleonColors.blue100,
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'type ramp',
              child: const _Padded(child: _TypeRampSample()),
            ),
            GoldenTestScenario(
              name: 'bottom sheet content',
              // Rendered directly, not via .show() — same reasoning as
              // _ToastSample above: this stays free of any Navigator/
              // animation, so it's golden-safe.
              child: const _Padded(
                child: ChameleonBottomSheet(child: Text('Filter options')),
              ),
            ),
            GoldenTestScenario(
              name: 'confirmation dialog',
              // Dialog (unlike ChameleonToast/ChameleonBottomSheet's own
              // build()) internally centers itself via Align and carries
              // its own default insetPadding (40 horizontal / 24
              // vertical), which needs a wider, bounded box than _Padded's
              // fixed 320 to lay out without overflowing — normally none
              // of this matters, since showDialog() renders into the full
              // viewport.
              child: const SizedBox(
                width: 400,
                height: 320,
                child: ChameleonConfirmationDialog(
                  title: 'Delete account?',
                  message: 'This cannot be undone.',
                  confirmLabel: 'Delete',
                  isDestructive: true,
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'empty state',
              child: _Padded(
                child: ChameleonEmptyState(
                  title: 'No transactions yet',
                  description: 'Your activity will show up here.',
                  icon: const Icon(Icons.receipt_long_outlined, size: 40),
                  actionLabel: 'Refresh',
                  onAction: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Padded extends StatelessWidget {
  const _Padded({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(ChameleonSpacing.base),
    child: SizedBox(width: 320, child: child),
  );
}

class _ElevatedButtonSample extends StatelessWidget {
  const _ElevatedButtonSample();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () {}, child: const Text('Continue'));
  }
}

class _TextFieldSample extends StatelessWidget {
  const _TextFieldSample();

  @override
  Widget build(BuildContext context) {
    return const TextField(
      decoration: InputDecoration(labelText: 'Phone number'),
    );
  }
}

class _ToastSample extends StatelessWidget {
  const _ToastSample(this.type, {this.backgroundColor, this.foregroundColor});

  final ChameleonToastType type;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return ChameleonToast(
      title: type == ChameleonToastType.error ? 'Something went wrong' : 'Done',
      description: type == ChameleonToastType.error
          ? 'Incorrect password.'
          : 'Your payment was sent.',
      type: type,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      onDismiss: () {},
    );
  }
}

class _TypeRampSample extends StatelessWidget {
  const _TypeRampSample();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Style('Heading 1', ChameleonTypography.heading1),
        _Style('Subheading 2', ChameleonTypography.subheading2),
        _Style('Body 1', ChameleonTypography.body1),
        _Style('Label 1', ChameleonTypography.label1),
      ],
    );
  }
}

class _Style extends StatelessWidget {
  const _Style(this.label, this.style);

  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Text(label, style: style);
}
