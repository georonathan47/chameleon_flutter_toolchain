import 'dart:io';

import 'package:chameleon_lints/chameleon_lints.dart';
import 'package:test/test.dart';

void main() {
  test('flags a bare print() and nothing else', () async {
    final errors = await const NoPrint().testAnalyzeAndRun(
      File('test/fixtures/no_print_fixture.dart').absolute,
    );

    expect(errors, hasLength(1));
    expect(errors.single.diagnosticCode.name, 'chameleon_no_print');
  });

  test("exempts the logging service's own file", () async {
    final errors = await const NoPrint().testAnalyzeAndRun(
      File('test/fixtures/logging_service.dart').absolute,
    );

    expect(errors, isEmpty);
  });
}
