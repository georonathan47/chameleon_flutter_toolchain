import 'package:flutter/material.dart';

/// Dismisses the on-screen keyboard when the user taps away from a field.
///
/// Wraps the whole app, so no individual page has to repeat the
/// `GestureDetector` + `unfocus()` pairing.
///
/// Two details make this safe to hoist app-wide:
///
/// * It unfocuses via [FocusManager], not `FocusScope.of(context)`. This sits
///   above the [Navigator], so its own context resolves to the root scope
///   rather than the focused page's — `FocusManager.instance.primaryFocus`
///   reaches whichever field actually holds focus.
/// * [HitTestBehavior.translucent] also claims taps that land on transparent
///   gaps, which `deferToChild` would let fall through. Buttons and other
///   tappables are unaffected either way: a child that wants the tap wins it
///   in the gesture arena regardless of this setting.
class DismissKeyboard extends StatelessWidget {
  const DismissKeyboard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      // Resolved on tap, not at build time — the focused field changes as the
      // user moves through a form.
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}
