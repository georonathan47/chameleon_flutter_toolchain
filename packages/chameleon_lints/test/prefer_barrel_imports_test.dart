import 'dart:io';

import 'package:chameleon_lints/chameleon_lints.dart';
import 'package:test/test.dart';

void main() {
  group('PreferBarrelImports', () {
    test('does not flag an import reaching into the same feature', () async {
      final errors = await const PreferBarrelImports().testAnalyzeAndRun(
        File(
          'test/fixtures/prefer_barrel_imports/features/sample/'
          'same_feature_import_fixture.dart',
        ).absolute,
      );

      expect(errors, isEmpty);
    });

    test('flags a cross-feature import reaching past the barrel', () async {
      final errors = await const PreferBarrelImports().testAnalyzeAndRun(
        File(
          'test/fixtures/prefer_barrel_imports/features/other/'
          'cross_feature_bad_import_fixture.dart',
        ).absolute,
      );

      expect(errors, hasLength(1));
      expect(
        errors.single.diagnosticCode.name,
        'chameleon_prefer_barrel_imports',
      );
    });

    test('does not flag a cross-feature import of the barrel itself', () async {
      final errors = await const PreferBarrelImports().testAnalyzeAndRun(
        File(
          'test/fixtures/prefer_barrel_imports/features/other/'
          'cross_feature_good_import_fixture.dart',
        ).absolute,
      );

      expect(errors, isEmpty);
    });
  });
}
