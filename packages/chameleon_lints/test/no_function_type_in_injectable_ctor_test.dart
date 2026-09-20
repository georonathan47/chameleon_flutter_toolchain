import 'dart:io';

import 'package:chameleon_lints/chameleon_lints.dart';
import 'package:test/test.dart';

void main() {
  test(
    'flags a function-typed constructor parameter on an @lazySingleton class',
    () async {
      final errors = await const NoFunctionTypeInInjectableCtor()
          .testAnalyzeAndRun(
            File(
              'test/fixtures/no_function_type_in_injectable_ctor_fixture.dart',
            ).absolute,
          );

      // BadService's inline `{DateTime Function()? now}` and
      // BadFieldShorthandService's `this._now` shorthand — both resolve to
      // a function type on the default constructor. GoodService.withClock
      // (a named constructor injectable never calls by default) must not
      // be flagged.
      expect(errors, hasLength(2));
      expect(
        errors.map((error) => error.diagnosticCode.name),
        everyElement('chameleon_no_function_type_in_injectable_ctor'),
      );
    },
  );
}
