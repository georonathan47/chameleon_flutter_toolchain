import 'dart:io';

import 'package:chameleon_lints/chameleon_lints.dart';
import 'package:test/test.dart';

void main() {
  test(
    'flags a non-sealed abstract class with 2+ same-file subtypes via '
    'extends or implements, and nothing else',
    () async {
      final errors = await const PreferSealedClass().testAnalyzeAndRun(
        File('test/fixtures/prefer_sealed_class_fixture.dart').absolute,
      );

      // 3, not 2: UnsealedState and Shape are the two genuine violations
      // this rule should catch; OpenFailure also structurally qualifies
      // (its own subtypes all live in this same file) but carries a
      // `// ignore: chameleon_prefer_sealed_class` comment demonstrating
      // the real suppression path for a deliberately-open hierarchy.
      // testAnalyzeAndRun talks to the rule directly via a raw diagnostic
      // listener — it doesn't apply standard ignore-comment filtering the
      // way `dart run custom_lint`/an IDE does, so OpenFailure still shows
      // up here even though it would be suppressed in real usage.
      expect(errors, hasLength(3));
      for (final error in errors) {
        expect(error.diagnosticCode.name, 'chameleon_prefer_sealed_class');
      }
    },
  );
}
