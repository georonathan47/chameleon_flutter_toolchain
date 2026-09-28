import 'dart:io';

import 'package:chameleon_lints/chameleon_lints.dart';
import 'package:test/test.dart';

void main() {
  test(
    'flags a chopper Response.body read with no isSuccessful/error check, '
    'and nothing else',
    () async {
      final errors = await const ChopperRequiresErrorCheck().testAnalyzeAndRun(
        File(
          'test/fixtures/chopper_requires_error_check_fixture.dart',
        ).absolute,
      );

      expect(errors, hasLength(2));
      for (final error in errors) {
        expect(
          error.diagnosticCode.name,
          'chameleon_chopper_requires_error_check',
        );
      }
    },
  );
}
