import 'package:chameleon_core/chameleon_core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../entities/{{feature_name.snakeCase()}}.dart';
import '../repositories/{{feature_name.snakeCase()}}_repository.dart';

@injectable
class Get{{feature_name.pascalCase()}} {
  const Get{{feature_name.pascalCase()}}(this._repository);

  final {{feature_name.pascalCase()}}Repository _repository;

  TaskEither<Failure, List<{{feature_name.pascalCase()}}>> call() =>
      _repository.get{{feature_name.pascalCase()}}();
}
