import 'package:chameleon_core/chameleon_core.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:{{project_name.snakeCase()}}/core/network/api_envelope.dart';
import 'package:{{project_name.snakeCase()}}/features/{{feature_name.snakeCase()}}/data/datasources/{{feature_name.snakeCase()}}_remote_data_source.dart';
import 'package:{{project_name.snakeCase()}}/features/{{feature_name.snakeCase()}}/data/models/{{feature_name.snakeCase()}}_model.dart';
import 'package:{{project_name.snakeCase()}}/features/{{feature_name.snakeCase()}}/data/services/{{feature_name.snakeCase()}}_api_client.dart';

class _MockApiClient extends Mock implements {{feature_name.pascalCase()}}ApiClient {}

void main() {
  // fetch{{feature_name.pascalCase()}} calls initIsolateBinaryMessenger,
  // which reads RootIsolateToken.instance — needs a binding, the same as
  // chameleon_core's own auth_interceptor_test.dart. Called directly here
  // (no compute(), no real isolate) so the mock api client never has to
  // survive an isolate boundary — see this file's own worker doc comment.
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockApiClient apiClient;

  setUp(() {
    apiClient = _MockApiClient();
  });

  ApiCall<{{feature_name.pascalCase()}}ApiClient, void> buildCall() => (
    service: apiClient,
    body: null,
    token: RootIsolateToken.instance!,
    flavor: null,
  );

  test('returns the decoded list from a successful envelope', () async {
    const model = {{feature_name.pascalCase()}}Model(id: '1', name: 'Alex');
    when(() => apiClient.get{{feature_name.pascalCase()}}()).thenAnswer(
      (_) async => Response(
        http.Response('', 200),
        const ApiEnvelope<List<{{feature_name.pascalCase()}}Model>>(
          success: true,
          data: [model],
        ),
      ),
    );

    final result = await fetch{{feature_name.pascalCase()}}(buildCall());

    expect(result, [model]);
  });

  test(
    'throws ServerException on a non-2xx response with no body — the shape '
    'chopper actually produces, not a stubbed shortcut (guardrail #8)',
    () async {
      when(() => apiClient.get{{feature_name.pascalCase()}}()).thenAnswer(
        (_) async => Response<ApiEnvelope<List<{{feature_name.pascalCase()}}Model>>>(
          http.Response('', 500),
          null,
          error: 'Internal Server Error',
        ),
      );

      expect(
        () => fetch{{feature_name.pascalCase()}}(buildCall()),
        throwsA(isA<ServerException>()),
      );
    },
  );
}
