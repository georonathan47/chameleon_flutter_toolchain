import 'package:equatable/equatable.dart';

sealed class {{bloc_name.pascalCase()}}State extends Equatable {
  const {{bloc_name.pascalCase()}}State();

  @override
  List<Object?> get props => [];
}

final class {{bloc_name.pascalCase()}}Initial extends {{bloc_name.pascalCase()}}State {
  const {{bloc_name.pascalCase()}}Initial();
}

final class {{bloc_name.pascalCase()}}InProgress extends {{bloc_name.pascalCase()}}State {
  const {{bloc_name.pascalCase()}}InProgress();
}

final class {{bloc_name.pascalCase()}}Success extends {{bloc_name.pascalCase()}}State {
  const {{bloc_name.pascalCase()}}Success();
}

final class {{bloc_name.pascalCase()}}Failure extends {{bloc_name.pascalCase()}}State {
  const {{bloc_name.pascalCase()}}Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
