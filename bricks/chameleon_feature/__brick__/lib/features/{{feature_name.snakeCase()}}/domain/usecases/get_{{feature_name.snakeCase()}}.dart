import 'package:chameleon_core/chameleon_core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../entities/{{feature_name.snakeCase()}}.dart';
import '../repositories/{{feature_name.snakeCase()}}_repository.dart';

@injectable
class Get{{feature_name.pascalCase()}} {
  const Get{{feature_name.pascalCase()}}(this._repository);

  final {{feature_name.pascalCase()}}Repository _repository;

  // chameleon_task_either_requires_safe_construction only inspects a
  // method's own body, deliberately not what it delegates to (see that
  // rule's own doc comment) — this use case is an intentionally thin
  // pass-through by clean-architecture convention, not somewhere that
  // itself needs a safe TaskEither constructor; the repository
  // implementation it delegates to (data/repositories/
  // {{feature_name.snakeCase()}}_repository_impl.dart) is what the rule
  // actually needs to (and does) verify.
  // ignore: chameleon_task_either_requires_safe_construction
  TaskEither<Failure, List<{{feature_name.pascalCase()}}>> call() =>
      _repository.get{{feature_name.pascalCase()}}();
}
