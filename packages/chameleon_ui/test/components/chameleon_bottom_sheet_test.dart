import 'package:chameleon_ui/chameleon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget appWithTrigger({
    bool isDismissible = true,
    bool enableDrag = true,
    void Function(Future<String?> result)? onResult,
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: theme ?? ChameleonTheme.light,
      home: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () {
              final result = ChameleonBottomSheet.show<String>(
                context,
                isDismissible: isDismissible,
                enableDrag: enableDrag,
                child: const Text('Sheet content'),
              );
              onResult?.call(result);
            },
            child: const Text('Open'),
          );
        },
      ),
    );
  }

  testWidgets('show() displays the given child', (tester) async {
    await tester.pumpWidget(appWithTrigger());

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Sheet content'), findsOneWidget);
  });

  testWidgets('tapping the barrier dismisses it by default', (tester) async {
    await tester.pumpWidget(appWithTrigger());

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Sheet content'), findsOneWidget);

    // Tap well above the sheet, which is anchored to the bottom.
    await tester.tapAt(const Offset(200, 10));
    await tester.pumpAndSettle();

    expect(find.text('Sheet content'), findsNothing);
  });

  testWidgets('isDismissible: false keeps the barrier from closing it', (
    tester,
  ) async {
    await tester.pumpWidget(appWithTrigger(isDismissible: false));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(200, 10));
    await tester.pumpAndSettle();

    expect(find.text('Sheet content'), findsOneWidget);
  });

  testWidgets('resolves with whatever the sheet is popped with', (
    tester,
  ) async {
    late Future<String?> result;
    await tester.pumpWidget(
      appWithTrigger(onResult: (future) => result = future),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    Navigator.of(
      tester.element(find.text('Sheet content')),
    ).pop('picked-value');
    await tester.pumpAndSettle();

    expect(await result, 'picked-value');
  });

  testWidgets(
    'under ChameleonTheme.dark, the drag handle resolves dark',
    (tester) async {
      await tester.pumpWidget(appWithTrigger(theme: ChameleonTheme.dark));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // The drag handle is the only 36x4 Container this widget renders —
      // matching on its exact size avoids depending on which Container in
      // the wider widget tree find.byType(Container).first would happen
      // to hit.
      final handle = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) => widget is Container && widget.constraints?.maxWidth == 36,
        ),
      );
      final decoration = handle.decoration! as BoxDecoration;
      expect(decoration.color, ChameleonSemanticColorsDark.outlineVariant);
    },
  );
}
