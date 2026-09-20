import 'package:chameleon_ui/chameleon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpHost(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      home: ChameleonToastHost(child: Container()),
    ),
  );

  testWidgets('show() with no host mounted does nothing (asserts in debug)', (
    tester,
  ) async {
    expect(ChameleonToastMessenger.isShowing, isFalse);
  });

  testWidgets('show() displays a toast, dismiss() removes it', (
    tester,
  ) async {
    await pumpHost(tester);

    ChameleonToastMessenger.show(title: 'Title', description: 'Description');
    await tester.pump();

    expect(ChameleonToastMessenger.isShowing, isTrue);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);

    ChameleonToastMessenger.dismiss();
    // Let the exit animation and its whenComplete teardown run.
    await tester.pumpAndSettle();

    expect(ChameleonToastMessenger.isShowing, isFalse);
    expect(find.text('Title'), findsNothing);
  });

  testWidgets('a second show() replaces the first rather than stacking', (
    tester,
  ) async {
    await pumpHost(tester);

    ChameleonToastMessenger.show(title: 'First', description: 'One');
    await tester.pump();
    ChameleonToastMessenger.show(title: 'Second', description: 'Two');
    await tester.pump();

    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);

    // A toast is still showing (with a live timer/animation) at test end;
    // reset() tears it down synchronously rather than animating an exit,
    // per its own doc comment on exactly this scenario.
    ChameleonToastMessenger.reset();
  });

  testWidgets('error() and success() set the expected default titles', (
    tester,
  ) async {
    await pumpHost(tester);

    ChameleonToastMessenger.error('Bad thing happened');
    await tester.pump();
    expect(find.text('Something went wrong'), findsOneWidget);

    ChameleonToastMessenger.success('Good thing happened');
    await tester.pump();
    expect(find.text('Done'), findsOneWidget);

    ChameleonToastMessenger.reset();
  });

  testWidgets('auto-dismisses after its duration elapses', (tester) async {
    await pumpHost(tester);

    ChameleonToastMessenger.show(
      title: 'Title',
      description: 'Description',
      duration: const Duration(milliseconds: 500),
    );
    await tester.pump();
    expect(ChameleonToastMessenger.isShowing, isTrue);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(ChameleonToastMessenger.isShowing, isFalse);
  });
}
