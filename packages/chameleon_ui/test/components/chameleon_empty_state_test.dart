import 'package:chameleon_ui/chameleon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) =>
      tester.pumpWidget(MaterialApp(home: Material(child: child)));

  testWidgets('renders title only when nothing else is given', (
    tester,
  ) async {
    await pump(tester, const ChameleonEmptyState(title: 'No results'));

    expect(find.text('No results'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('renders description when given', (tester) async {
    await pump(
      tester,
      const ChameleonEmptyState(
        title: 'No transactions yet',
        description: 'Your activity will show up here.',
      ),
    );

    expect(find.text('No transactions yet'), findsOneWidget);
    expect(find.text('Your activity will show up here.'), findsOneWidget);
  });

  testWidgets('renders the icon slot when given', (tester) async {
    await pump(
      tester,
      const ChameleonEmptyState(
        title: 'No results',
        icon: Icon(Icons.search_off),
      ),
    );

    expect(find.byIcon(Icons.search_off), findsOneWidget);
  });

  testWidgets(
    'renders an action button only when both label and callback are given',
    (tester) async {
      await pump(
        tester,
        const ChameleonEmptyState(title: 'No results', actionLabel: 'Retry'),
      );
      expect(find.byType(ElevatedButton), findsNothing);

      var tapped = false;
      await pump(
        tester,
        ChameleonEmptyState(
          title: 'No results',
          actionLabel: 'Retry',
          onAction: () => tapped = true,
        ),
      );
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(tapped, isTrue);
    },
  );
}
