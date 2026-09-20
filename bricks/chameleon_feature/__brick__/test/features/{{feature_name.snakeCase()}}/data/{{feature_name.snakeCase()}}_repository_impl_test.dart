import 'package:chameleon_core/chameleon_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:{{project_name.snakeCase()}}/features/{{feature_name.snakeCase()}}/data/datasources/{{feature_name.snakeCase()}}_remote_data_source.dart';
import 'package:{{project_name.snakeCase()}}/features/{{feature_name.snakeCase()}}/data/models/{{feature_name.snakeCase()}}_model.dart';
import 'package:{{project_name.snakeCase()}}/features/{{feature_name.snakeCase()}}/data/repositories/{{feature_name.snakeCase()}}_repository_impl.dart';

class _MockRemoteDataSource extends Mock
    implements {{feature_name.pascalCase()}}RemoteDataSource {}

void main() {
  late _MockRemoteDataSource dataSource;
  late {{feature_name.pascalCase()}}RepositoryImpl repository;

  setUp(() {
    dataSource = _MockRemoteDataSource();
    repository = {{feature_name.pascalCase()}}RepositoryImpl(dataSource);
  });

  test('maps a successful fetch to Right(entities)', () async {
    const model = {{feature_name.pascalCase()}}Model(id: '1', name: 'Alex');
    when(
      () => dataSource.get{{feature_name.pascalCase()}}(),
    ).thenAnswer((_) async => [model]);

    final result = await repository.get{{feature_name.pascalCase()}}().run();

    expect(result.toNullable()?.single.name, 'Alex');
  });

  test('maps a ServerException from the datasource to ServerFailure', () async {
    when(
      () => dataSource.get{{feature_name.pascalCase()}}(),
    ).thenThrow(const ServerException('boom'));

    final result = await repository.get{{feature_name.pascalCase()}}().run();

    expect(result.getLeft().toNullable(), isA<ServerFailure>());
  });

  test('maps a NetworkException from the datasource to NetworkFailure', () async {
    when(
      () => dataSource.get{{feature_name.pascalCase()}}(),
    ).thenThrow(const NetworkException());

    final result = await repository.get{{feature_name.pascalCase()}}().run();

    expect(result.getLeft().toNullable(), isA<NetworkFailure>());
  });
}
