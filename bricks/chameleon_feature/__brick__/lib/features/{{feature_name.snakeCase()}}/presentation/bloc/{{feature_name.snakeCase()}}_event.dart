import 'package:equatable/equatable.dart';

sealed class {{feature_name.pascalCase()}}Event extends Equatable {
  const {{feature_name.pascalCase()}}Event();

  @override
  List<Object?> get props => [];
}

final class {{feature_name.pascalCase()}}Requested extends {{feature_name.pascalCase()}}Event {
  const {{feature_name.pascalCase()}}Requested();
}
