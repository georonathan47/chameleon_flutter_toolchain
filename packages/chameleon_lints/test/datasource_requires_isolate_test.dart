import 'dart:io';

import 'package:chameleon_lints/chameleon_lints.dart';
import 'package:test/test.dart';

const _fixtures = 'test/fixtures/datasource_requires_isolate/features/sample';

Future<List<Object>> _run(String relativePath) =>
    const DatasourceRequiresIsolate().testAnalyzeAndRun(
      File('$_fixtures/$relativePath').absolute,
    );

void main() {
  group('DatasourceRequiresIsolate', () {
    test(
      'flags a datasource method that runs on the calling isolate',
      () async {
        final errors = await _run(
          'data/datasources/bad_datasource_fixture.dart',
        );

        expect(errors, hasLength(1));
      },
    );

    test(
      'does not flag runApiCall/runInIsolate/Isolate.run, abstract, '
      'private, static, or getter members',
      () async {
        final errors = await _run(
          'data/datasources/good_datasource_fixture.dart',
        );

        expect(errors, isEmpty);
      },
    );

    test('does not flag a file outside data/datasources/', () async {
      final errors = await _run('domain/not_a_datasource_fixture.dart');

      expect(errors, isEmpty);
    });
  });
}
