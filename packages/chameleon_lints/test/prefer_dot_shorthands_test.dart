import 'dart:io';

import 'package:chameleon_lints/chameleon_lints.dart';
import 'package:test/test.dart';

void main() {
  test('flags qualified access in a typed variable, argument, and return '
      'position, and nowhere else', () async {
    final errors = await const PreferDotShorthands().testAnalyzeAndRun(
      File('test/fixtures/prefer_dot_shorthands_fixture.dart').absolute,
    );

    expect(errors, hasLength(4));
    for (final error in errors) {
      expect(error.diagnosticCode.name, 'chameleon_prefer_dot_shorthands');
    }
  });
}
