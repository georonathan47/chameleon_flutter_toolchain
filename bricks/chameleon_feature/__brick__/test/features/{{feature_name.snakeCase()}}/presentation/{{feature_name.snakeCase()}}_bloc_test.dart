import 'package:bloc_test/bloc_test.dart';
import 'package:chameleon_core/chameleon_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:{{project_name.snakeCase()}}/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}.dart';
import 'package:{{project_name.snakeCase()}}/features/{{feature_name.snakeCase()}}/domain/usecases/get_{{feature_name.snakeCase()}}.dart';
import 'package:{{project_name.snakeCase()}}/features/{{feature_name.snakeCase()}}/presentation/bloc/{{feature_name.snakeCase()}}_bloc.dart';
import 'package:{{project_name.snakeCase()}}/features/{{feature_name.snakeCase()}}/presentation/bloc/{{feature_name.snakeCase()}}_event.dart';
import 'package:{{project_name.snakeCase()}}/features/{{feature_name.snakeCase()}}/presentation/bloc/{{feature_name.snakeCase()}}_state.dart';

class _MockGet{{feature_name.pascalCase()}} extends Mock implements Get{{feature_name.pascalCase()}} {}

void main() {
  late _MockGet{{feature_name.pascalCase()}} useCase;

  setUp(() {
    useCase = _MockGet{{feature_name.pascalCase()}}();
  });

  blocTest<{{feature_name.pascalCase()}}Bloc, {{feature_name.pascalCase()}}State>(
    'emits [Loading, Loaded] on a successful fetch',
    setUp: () {
      when(() => useCase()).thenReturn(
        TaskEither.right(const [{{feature_name.pascalCase()}}(id: '1', name: 'Alex')]),
      );
    },
    build: () => {{feature_name.pascalCase()}}Bloc(useCase),
    act: (bloc) => bloc.add(const {{feature_name.pascalCase()}}Requested()),
    expect: () => const [
      {{feature_name.pascalCase()}}Loading(),
      {{feature_name.pascalCase()}}Loaded([{{feature_name.pascalCase()}}(id: '1', name: 'Alex')]),
    ],
  );

  blocTest<{{feature_name.pascalCase()}}Bloc, {{feature_name.pascalCase()}}State>(
    'emits [Loading, LoadError] when the repository fails',
    setUp: () {
      when(() => useCase()).thenReturn(TaskEither.left(const ServerFailure()));
    },
    build: () => {{feature_name.pascalCase()}}Bloc(useCase),
    act: (bloc) => bloc.add(const {{feature_name.pascalCase()}}Requested()),
    expect: () => [
      const {{feature_name.pascalCase()}}Loading(),
      isA<{{feature_name.pascalCase()}}LoadError>(),
    ],
  );
}
