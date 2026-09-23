import 'package:chameleon_ui/chameleon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget appWithTrigger({
    required void Function(Future<bool> result) onResult,
    bool isDestructive = false,
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: theme ?? ChameleonTheme.light,
      home: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () {
              onResult(
                ChameleonConfirmationDialog.show(
                  context,
                  title: 'Delete account?',
                  message: 'This cannot be undone.',
                  confirmLabel: 'Delete',
                  isDestructive: isDestructive,
                ),
              );
            },
            child: const Text('Open'),
          );
        },
      ),
    );
  }

  testWidgets('show() displays the title, message, and labels', (
    tester,
  ) async {
    await tester.pumpWidget(appWithTrigger(onResult: (_) {}));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Delete account?'), findsOneWidget);
    expect(find.text('This cannot be undone.'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('tapping cancel resolves false and closes the dialog', (
    tester,
  ) async {
    late Future<bool> result;
    await tester.pumpWidget(
      appWithTrigger(onResult: (future) => result = future),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await result, isFalse);
    expect(find.text('Delete account?'), findsNothing);
  });

  testWidgets('tapping confirm resolves true and closes the dialog', (
    tester,
  ) async {
    late Future<bool> result;
    await tester.pumpWidget(
      appWithTrigger(onResult: (future) => result = future),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(await result, isTrue);
    expect(find.text('Delete account?'), findsNothing);
  });

  testWidgets('a barrier tap resolves false, not null', (tester) async {
    late Future<bool> result;
    await tester.pumpWidget(
      appWithTrigger(onResult: (future) => result = future),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Tap well outside the centered dialog card.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(await result, isFalse);
  });

  testWidgets('isDestructive recolors the confirm button', (tester) async {
    await tester.pumpWidget(
      appWithTrigger(isDestructive: true, onResult: (_) {}),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    final resolvedColor = button.style?.backgroundColor?.resolve({});

    expect(resolvedColor, ChameleonTheme.light.colorScheme.error);
  });

  testWidgets('under ChameleonTheme.dark, surface and text resolve dark', (
    tester,
  ) async {
    await tester.pumpWidget(
      appWithTrigger(onResult: (_) {}, theme: ChameleonTheme.dark),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final dialog = tester.widget<Dialog>(find.byType(Dialog));
    expect(dialog.backgroundColor, ChameleonSemanticColorsDark.surface);

    final title = tester.widget<Text>(find.text('Delete account?'));
    expect(title.style?.color, ChameleonSemanticColorsDark.textPrimary);
  });
}
