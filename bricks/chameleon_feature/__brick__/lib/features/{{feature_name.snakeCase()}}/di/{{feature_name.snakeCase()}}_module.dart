import 'package:chameleon_core/chameleon_core.dart';
import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';

import '../../../core/config/env.dart';
import '../../../core/network/api_envelope.dart';
import '../data/models/{{feature_name.snakeCase()}}_model.dart';
import '../data/services/{{feature_name.snakeCase()}}_api_client.dart';

/// Builds this feature's own `ChopperClient` rather than sharing one across
/// features. `createChopperClient`'s `envelopeFactories` map is keyed by
/// payload `Type` for the whole client it's given to — a per-feature client
/// means two features can never collide on a reused model-type name, and
/// generating a feature never needs to know what other features registered.
/// The cost is one extra `ChopperClient` (and its connection) per feature,
/// negligible for a mobile app's API surface. `AuthInterceptor`,
/// `IdempotencyInterceptor`, and `RetryInterceptor` are still shared
/// singletons — only the client and its envelope-factory map are
/// per-feature. `RetryInterceptor` is listed last, after
/// `IdempotencyInterceptor`: it decides whether a non-`GET` request is safe
/// to retry by checking for the `Idempotency-Key` header, which must
/// already be attached by the time it runs.
///
/// `@Named('{{feature_name.snakeCase()}}')` on both the provider and the
/// consuming parameter below is required, not decorative: get_it/injectable
/// register by TYPE, and every feature's module produces a plain
/// `ChopperClient` — with no qualifier, a second feature's `ChopperClient`
/// registration collides with the first one's ("registered more than once
/// under the same environment or scope"), a real error surfaced by actually
/// generating two features into one app, not assumed.
@module
abstract class {{feature_name.pascalCase()}}Module {
  @Named('{{feature_name.snakeCase()}}')
  @lazySingleton
  ChopperClient {{feature_name.camelCase()}}ChopperClient(
    AuthInterceptor authInterceptor,
    IdempotencyInterceptor idempotencyInterceptor,
    RetryInterceptor retryInterceptor,
  ) => createChopperClient(
    baseUrl: Env.current,
    interceptors: [authInterceptor, idempotencyInterceptor, retryInterceptor],
    services: [{{feature_name.pascalCase()}}ApiClient.create()],
    envelopeFactories: {
      {{feature_name.pascalCase()}}Model:
          (json) => ApiEnvelope<List<{{feature_name.pascalCase()}}Model>>.fromJson(
            json,
            (data) => (data! as List<dynamic>)
                .map(
                  (item) => {{feature_name.pascalCase()}}Model.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList(),
          ),
    },
  );

  @lazySingleton
  {{feature_name.pascalCase()}}ApiClient {{feature_name.camelCase()}}ApiClient(
    @Named('{{feature_name.snakeCase()}}') ChopperClient client,
  ) => client.getService<{{feature_name.pascalCase()}}ApiClient>();
}
