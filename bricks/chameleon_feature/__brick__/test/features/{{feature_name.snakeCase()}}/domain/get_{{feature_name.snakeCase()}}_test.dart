import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:{{project_name.snakeCase()}}/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}.dart';
import 'package:{{project_name.snakeCase()}}/features/{{feature_name.snakeCase()}}/domain/repositories/{{feature_name.snakeCase()}}_repository.dart';
import 'package:{{project_name.snakeCase()}}/features/{{feature_name.snakeCase()}}/domain/usecases/get_{{feature_name.snakeCase()}}.dart';

class _MockRepository extends Mock implements {{feature_name.pascalCase()}}Repository {}

void main() {
  late _MockRepository repository;
  late Get{{feature_name.pascalCase()}} useCase;

  setUp(() {
    repository = _MockRepository();
    useCase = Get{{feature_name.pascalCase()}}(repository);
  });

  test('delegates to the repository', () async {
    const item = {{feature_name.pascalCase()}}(id: '1', name: 'Alex');
    when(
      () => repository.get{{feature_name.pascalCase()}}(),
    ).thenReturn(TaskEither.right([item]));

    final result = await useCase().run();

    expect(result.toNullable(), [item]);
    verify(() => repository.get{{feature_name.pascalCase()}}()).called(1);
  });
}
