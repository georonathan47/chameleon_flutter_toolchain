import 'dart:io';

import 'package:chameleon_lints/chameleon_lints.dart';
import 'package:test/test.dart';

void main() {
  test(
    'flags BlocProvider(create: ...) resolving a @lazySingleton via getIt, '
    'but not one resolving an @injectable factory',
    () async {
      final errors = await const BlocProviderValueForDi().testAnalyzeAndRun(
        File(
          'test/fixtures/bloc_provider_value_for_di_fixture.dart',
        ).absolute,
      );

      expect(errors, hasLength(1));
      expect(
        errors.single.diagnosticCode.name,
        'chameleon_bloc_provider_value_for_di',
      );
    },
  );
}
