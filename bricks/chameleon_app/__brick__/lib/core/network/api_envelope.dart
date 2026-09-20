import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_envelope.freezed.dart';
part 'api_envelope.g.dart';

/// This app's response envelope. Every feature's chopper service declares
/// its endpoints as `Future<Response<ApiEnvelope<Payload>>>` and registers a
/// factory for `Payload` in the `envelopeFactories` map its DI module passes
/// to `createChopperClient` (see `chameleon_core`'s
/// `chopper_client_factory.dart` — a cross-cutting infra package can't know
/// this shape, so it lives here instead).
///
/// `genericArgumentFactories: true` is what lets `ApiEnvelope<T>.fromJson`
/// take a `fromJsonT` for the generic `data` field — freezed can't otherwise
/// generate JSON code for a type parameter it doesn't know at codegen time.
@Freezed(genericArgumentFactories: true)
abstract class ApiEnvelope<T> with _$ApiEnvelope<T> {
  const factory ApiEnvelope({
    required bool success,
    String? message,
    T? data,
  }) = _ApiEnvelope<T>;

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiEnvelopeFromJson(json, fromJsonT);
}
