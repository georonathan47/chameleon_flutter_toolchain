import 'package:chameleon_core/chameleon_core.dart';
import 'package:injectable/injectable.dart';

import '../models/{{feature_name.snakeCase()}}_model.dart';
import '../services/{{feature_name.snakeCase()}}_api_client.dart';

// Top-level, not a method tear-off: compute() cannot ship an instance
// closure (tasks/lessons.md — isolate workers must be top-level or static).
// Not private: this is called directly (no compute(), no isolate) from
// this feature's datasource test, which is how the envelope/failure-shape
// logic gets unit-tested without needing a sendable mock service to
// survive a real isolate boundary.
Future<List<{{feature_name.pascalCase()}}Model>> fetch{{feature_name.pascalCase()}}(
  ApiCall<{{feature_name.pascalCase()}}ApiClient, void> call,
) async {
  // FIRST line: re-enables platform channels and re-seeds FlavorConfig on
  // this worker isolate — without it, network logging silently drops every
  // request/response that runs off the root isolate (chameleon_core's own
  // isolate_helper.dart doc comment).
  initIsolateBinaryMessenger(call.token, call.flavor);
  final response = await call.service.get{{feature_name.pascalCase()}}();
  final envelope = response.body;
  if (!response.isSuccessful || envelope == null || !envelope.success || envelope.data == null) {
    throw ServerException(
      envelope?.message ?? 'Request failed with status ${response.statusCode}',
    );
  }
  return envelope.data!;
}

abstract interface class {{feature_name.pascalCase()}}RemoteDataSource {
  Future<List<{{feature_name.pascalCase()}}Model>> get{{feature_name.pascalCase()}}();
}

@LazySingleton(as: {{feature_name.pascalCase()}}RemoteDataSource)
class {{feature_name.pascalCase()}}RemoteDataSourceImpl
    implements {{feature_name.pascalCase()}}RemoteDataSource {
  {{feature_name.pascalCase()}}RemoteDataSourceImpl(this._apiClient);

  final {{feature_name.pascalCase()}}ApiClient _apiClient;

  @override
  Future<List<{{feature_name.pascalCase()}}Model>> get{{feature_name.pascalCase()}}() =>
      runApiCall(
        (
          service: _apiClient,
          body: null,
          token: rootIsolateToken,
          flavor: FlavorConfig.snapshot,
        ),
        fetch{{feature_name.pascalCase()}},
      );
}
