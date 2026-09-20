import 'dart:convert';

import 'package:chopper/chopper.dart';

import 'network_logging_interceptor.dart';

/// Decodes a JSON payload into the app's envelope type for one payload type —
/// e.g. `(json) => ApiEnvelope<LoginData>.fromJson(json, LoginData.fromJson)`.
typedef EnvelopeFactory = Object Function(Map<String, dynamic> json);

/// Builds the app's [ChopperClient].
///
/// [envelopeFactories] maps each **payload type** (the inner type argument a
/// generated chopper service calls `send<Envelope, Payload>` with — not the
/// envelope type itself) to the function that decodes a JSON response body
/// into that envelope. This is supplied by the app rather than hard-coded
/// here: a cross-cutting infra package cannot know about the app's feature
/// models, and every payload type the app's chopper services use must have an
/// entry or [ChameleonAppJsonConverter] throws a [StateError] on first use.
ChopperClient createChopperClient({
  required String baseUrl,
  required List<Interceptor> interceptors,
  required Iterable<ChopperService> services,
  required Map<Type, EnvelopeFactory> envelopeFactories,
}) {
  final converter = ChameleonAppJsonConverter(envelopeFactories);

  return ChopperClient(
    baseUrl: Uri.parse(baseUrl),
    services: services,
    converter: converter,
    errorConverter: converter,
    interceptors: [...interceptors, const NetworkLoggingInterceptor()],
  );
}

/// Decodes every response through the envelope-factory map given to its
/// constructor, keyed by the inner (payload) type a generated chopper
/// service's `send<Envelope, Payload>` call carries.
class ChameleonAppJsonConverter extends JsonConverter {
  const ChameleonAppJsonConverter(this._envelopeFactories);

  final Map<Type, EnvelopeFactory> _envelopeFactories;

  @override
  Response<BodyType> convertResponse<BodyType, InnerType>(
    Response<dynamic> response,
  ) => _decodeEnvelope<BodyType, InnerType>(response);

  @override
  Response<BodyType> convertError<BodyType, InnerType>(
    Response<dynamic> response,
  ) => _decodeEnvelope<BodyType, InnerType>(response);

  Response<BodyType> _decodeEnvelope<BodyType, InnerType>(
    Response<dynamic> response,
  ) {
    final bytes = response.bodyBytes;
    final raw = bytes.isNotEmpty ? utf8.decode(bytes) : response.bodyString;
    if (raw.isEmpty) return _emptyBody<BodyType>(response);

    final factory = _envelopeFactories[InnerType];
    if (factory == null) {
      throw StateError(
        'No envelope factory registered for payload type $InnerType. '
        'Pass one in the envelopeFactories map given to createChopperClient.',
      );
    }

    final Object decoded;
    try {
      decoded = jsonDecode(raw) as Object;
    } on FormatException {
      return _emptyBody<BodyType>(response);
    }

    final envelope = factory(decoded as Map<String, dynamic>);
    // The envelope's shape is guaranteed by the factory registered for this
    // InnerType, so this cast is safe by construction rather than by luck.
    return response.copyWith<BodyType>(body: envelope as BodyType);
  }

  Response<BodyType> _emptyBody<BodyType>(Response<dynamic> response) =>
      Response<BodyType>(response.base, null, error: response.error);
}
