import 'dart:io';

import 'package:chameleon_lints/chameleon_lints.dart';
import 'package:test/test.dart';

void main() {
  test('flags a bare setState() call', () async {
    final errors = await const NoSetState().testAnalyzeAndRun(
      File('test/fixtures/no_set_state_fixture.dart').absolute,
    );

    expect(errors, hasLength(1));
    expect(errors.single.diagnosticCode.name, 'chameleon_no_set_state');
  });
}
