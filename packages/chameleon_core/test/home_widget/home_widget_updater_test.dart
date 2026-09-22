import 'package:chameleon_core/chameleon_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoopHomeWidgetUpdater', () {
    const updater = NoopHomeWidgetUpdater();

    test('saveData() always reports failure', () async {
      expect(await updater.saveData('title', 'Hello'), isFalse);
    });

    test('updateWidget() always reports failure', () async {
      expect(await updater.updateWidget(), isFalse);
    });
  });
}
