import 'package:chameleon_core/chameleon_core.dart';
import 'package:flutter_test/flutter_test.dart';

// An app-specific failure, exactly as a consuming app's own failures file
// would define one — proves `Failure` is genuinely extensible from outside
// this package now that it's `abstract base class` rather than `sealed`.
final class _LoginFailure extends Failure {
  const _LoginFailure([super.message = 'Attempt to login failed.']);
}

void main() {
  test('an app can define its own Failure subclass outside this package', () {
    const failure = _LoginFailure();
    expect(failure.message, 'Attempt to login failed.');
    expect(failure, isA<Failure>());
  });

  test('ValidationFailure.withDebug carries the field list through', () {
    final failure = ValidationFailure.withDebug(
      validationFields: const ['email', 'phone'],
    );
    expect(failure.validationFields, ['email', 'phone']);
  });

  test('every generic failure carries a sensible default message', () {
    const failures = <Failure>[
      NetworkFailure(),
      ServerFailure(),
      UnauthorizedFailure(),
      NotFoundFailure(),
      UnexpectedFailure(),
      UnknownFailure(),
      CacheFailure(),
      ValidationFailure(),
    ];

    for (final failure in failures) {
      expect(failure.message, isNotEmpty);
    }
  });
}
