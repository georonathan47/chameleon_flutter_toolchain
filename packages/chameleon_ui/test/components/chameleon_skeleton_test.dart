import 'package:chameleon_ui/chameleon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Never pumpAndSettle here — the shimmer's AnimationController repeats
  // indefinitely and pumpAndSettle would hang waiting for it to stop.
  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(child: Center(child: child)),
      ),
    );
    await tester.pump();
  }

  testWidgets('.rect renders at the given width and height', (tester) async {
    await pump(tester, const ChameleonSkeleton.rect(width: 200, height: 80));

    expect(tester.getSize(find.byType(ChameleonSkeleton)), const Size(200, 80));
  });

  testWidgets('.rect defaults to height 16', (tester) async {
    await pump(tester, const ChameleonSkeleton.rect(width: 100));

    expect(tester.getSize(find.byType(ChameleonSkeleton)).height, 16);
  });

  testWidgets('.circle renders as a square of the given size', (
    tester,
  ) async {
    await pump(tester, const ChameleonSkeleton.circle(size: 40));

    expect(tester.getSize(find.byType(ChameleonSkeleton)), const Size(40, 40));
  });

  testWidgets('.textLine renders at height 12', (tester) async {
    await pump(tester, const ChameleonSkeleton.textLine(width: 120));

    expect(tester.getSize(find.byType(ChameleonSkeleton)), const Size(120, 12));
  });

  testWidgets('advancing time does not throw or leak a pending timer', (
    tester,
  ) async {
    await pump(tester, const ChameleonSkeleton.rect(width: 100));

    // Several sweep cycles' worth of frames — proves the controller keeps
    // ticking without erroring, without ever needing pumpAndSettle.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }

    expect(find.byType(ChameleonSkeleton), findsOneWidget);
  });
}
