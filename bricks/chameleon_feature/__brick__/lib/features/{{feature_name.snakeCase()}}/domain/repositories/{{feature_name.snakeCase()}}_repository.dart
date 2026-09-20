import 'package:chameleon_core/chameleon_core.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/{{feature_name.snakeCase()}}.dart';

abstract interface class {{feature_name.pascalCase()}}Repository {
  TaskEither<Failure, List<{{feature_name.pascalCase()}}>> get{{feature_name.pascalCase()}}();
}
