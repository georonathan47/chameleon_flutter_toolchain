import 'package:chameleon_ui/chameleon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [widget] wrapped the way `App` wraps every screen — themed, and
/// with `ChameleonToastHost` mounted — so a widget test that triggers
/// `ChameleonToastMessenger.show()` doesn't hit the "no host mounted"
/// assertion, and so screens relying on `Theme.of(context)` render
/// correctly.
extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) {
    return pumpWidget(
      MaterialApp(
        theme: ChameleonTheme.light,
        home: ChameleonToastHost(child: widget),
      ),
    );
  }
}
