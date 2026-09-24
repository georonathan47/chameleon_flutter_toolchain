// This fixture exists only to give TaskEitherRequiresSafeConstruction
// something to analyze.

import 'package:fpdart/fpdart.dart';

abstract base class Failure {
  const Failure(this.message);
  final String message;
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

Failure _toFailure(Object error, StackTrace stackTrace) =>
    ServerFailure('$error');

// Good: arrow body rooted directly at a safe TaskEither constructor.
TaskEither<Failure, int> safeArrow() =>
    TaskEither.tryCatch(() async => 1, _toFailure);

// Good: chained off a safe root constructor.
TaskEither<Failure, int> safeChained() =>
    TaskEither.tryCatch(() async => 1, _toFailure).map((value) => value + 1);

// Good: a block whose sole statement returns a safe construction — treated
// the same as the arrow form.
TaskEither<Failure, int> safeBlockSingleReturn() {
  return TaskEither.tryCatch(() async => 1, _toFailure);
}

// Bad: extra statements before the safe return mean something could throw
// before ever reaching TaskEither.tryCatch's own catch.
// triggers chameleon_task_either_requires_safe_construction
TaskEither<Failure, int> unsafeMultiStatementBlock() {
  const precomputed = 1;
  return TaskEither.tryCatch(() async => precomputed, _toFailure);
}

// Bad: delegates to a helper instead of constructing safely itself — this
// rule only inspects a method's own body, not what it calls into.
// triggers chameleon_task_either_requires_safe_construction
TaskEither<Failure, int> unsafeArrowDelegatesToHelper() => _safeHelper();

TaskEither<Failure, int> _safeHelper() =>
    TaskEither.tryCatch(() async => 1, _toFailure);

// Good: an abstract interface method has no body to construct unsafely —
// found for real against chameleon_feature's own generated
// `WidgetsRepository.getWidgets()`, which this rule flagged before this
// case was handled.
// ignore: one_member_abstracts
abstract interface class SafeRepository {
  TaskEither<Failure, int> fetch();
}
