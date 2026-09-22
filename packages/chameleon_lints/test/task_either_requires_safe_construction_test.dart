import 'dart:io';

import 'package:chameleon_lints/chameleon_lints.dart';
import 'package:test/test.dart';

void main() {
  test(
    'flags a TaskEither<Failure, ...> method not safely constructed, and '
    'nothing else',
    () async {
      final errors = await const TaskEitherRequiresSafeConstruction()
          .testAnalyzeAndRun(
            File(
              'test/fixtures/'
              'task_either_requires_safe_construction_fixture.dart',
            ).absolute,
          );

      expect(errors, hasLength(2));
      for (final error in errors) {
        expect(
          error.diagnosticCode.name,
          'chameleon_task_either_requires_safe_construction',
        );
      }
    },
  );
}
