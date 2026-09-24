import 'package:chameleon_core/chameleon_core.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/{{feature_name.snakeCase()}}.dart';

sealed class {{feature_name.pascalCase()}}State extends Equatable {
  const {{feature_name.pascalCase()}}State();

  @override
  List<Object?> get props => [];
}

final class {{feature_name.pascalCase()}}Initial extends {{feature_name.pascalCase()}}State {
  const {{feature_name.pascalCase()}}Initial();
}

final class {{feature_name.pascalCase()}}Loading extends {{feature_name.pascalCase()}}State {
  const {{feature_name.pascalCase()}}Loading();
}

final class {{feature_name.pascalCase()}}Loaded extends {{feature_name.pascalCase()}}State {
  const {{feature_name.pascalCase()}}Loaded(this.items);

  final List<{{feature_name.pascalCase()}}> items;

  @override
  List<Object?> get props => [items];
}

final class {{feature_name.pascalCase()}}LoadError extends {{feature_name.pascalCase()}}State {
  const {{feature_name.pascalCase()}}LoadError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
