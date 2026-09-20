import 'package:chameleon_core/chameleon_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:{{project_name.snakeCase()}}/app/app.dart';

import '../../helpers/di_harness.dart';

void main() {
  setUp(() {
    FlavorConfig.initialize(
      flavor: Flavor.dev,
      name: 'DEV',
      bannerColor: 0xFFD32F2F,
    );
    registerTestDependencies();
  });

  tearDown(getIt.reset);

  testWidgets('App builds without throwing and shows the placeholder home', (
    tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pump();

    expect(find.text('chameleon_app'), findsOneWidget);
  });

  testWidgets('the DEV flavor banner is shown', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pump();

    // Banner paints its message via a TextPainter inside a CustomPainter,
    // not as a discoverable Text widget — find.text('DEV') would never
    // match it. Check the widget's own property instead. A plain
    // find.byType(Banner) also matches Flutter's own debug-mode "DEBUG"
    // ribbon (debugShowCheckedModeBanner is on for the dev flavor), so this
    // narrows to the one carrying our message.
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Banner && widget.message == 'DEV',
      ),
      findsOneWidget,
    );
  });
}
