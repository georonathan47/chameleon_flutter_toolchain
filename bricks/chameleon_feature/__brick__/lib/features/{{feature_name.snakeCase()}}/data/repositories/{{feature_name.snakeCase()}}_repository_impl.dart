import 'package:chameleon_core/chameleon_core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/{{feature_name.snakeCase()}}.dart';
import '../../domain/repositories/{{feature_name.snakeCase()}}_repository.dart';
import '../datasources/{{feature_name.snakeCase()}}_remote_data_source.dart';
import '../models/{{feature_name.snakeCase()}}_model.dart';

@LazySingleton(as: {{feature_name.pascalCase()}}Repository)
class {{feature_name.pascalCase()}}RepositoryImpl
    implements {{feature_name.pascalCase()}}Repository {
  {{feature_name.pascalCase()}}RepositoryImpl(this._remoteDataSource);

  final {{feature_name.pascalCase()}}RemoteDataSource _remoteDataSource;

  @override
  TaskEither<Failure, List<{{feature_name.pascalCase()}}>> get{{feature_name.pascalCase()}}() =>
      TaskEither.tryCatch(() async {
        final models = await _remoteDataSource.get{{feature_name.pascalCase()}}();
        return models.map((model) => model.toEntity()).toList();
      }, _mapError);

  // Models the failure shape a real chopper client actually produces —
  // NetworkException/ServerException from the datasource, not a stubbed
  // shortcut (tasks/lessons.md guardrail #8).
  Failure _mapError(Object error, StackTrace stackTrace) => switch (error) {
    NetworkException(:final message) => NetworkFailure.withDebug(
      debugMessage: message,
      stackTrace: stackTrace,
    ),
    ServerException(:final message) => ServerFailure.withDebug(
      debugMessage: message,
      stackTrace: stackTrace,
    ),
    _ => UnexpectedFailure.withDebug(
      debugMessage: '$error',
      stackTrace: stackTrace,
    ),
  };
}
