import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';

import 'device_identity.dart';

/// Attaches `Idempotency-Key: <device id>` to requests whose endpoint
/// requires it, so a duplicated submission (double-tap, transport retry)
/// collapses into one server-side operation.
///
/// The key is the stable device id from [DeviceIdentity] — deliberately not a
/// per-attempt UUID: the same retry of the same step should carry the same
/// key.
///
/// [configureRequiredPaths] sets which endpoints require the header. This is
/// a settable field rather than a constructor parameter or a package-level
/// constant, for the same reason as `AuthInterceptor.configureNoAuthPaths`:
/// a cross-cutting infra package cannot hard-code one app's API contract, and
/// injectable's generator would try to resolve a bare constructor parameter
/// from the DI container rather than accept a literal. Starts empty, so an
/// app that forgets to configure this simply sends no idempotency keys rather
/// than accidentally reusing another app's endpoint list.
@lazySingleton
// A long-lived singleton configured once after DI wiring, not a value type —
// see configureRequiredPaths below for why _requiredPathSuffixes is mutable.
// ignore: must_be_immutable
class IdempotencyInterceptor implements Interceptor {
  IdempotencyInterceptor(this._deviceIdentity);

  final DeviceIdentity _deviceIdentity;

  // Deliberately mutable — see the class doc on configureRequiredPaths. This
  // interceptor is a long-lived `@lazySingleton` configured once after DI
  // wiring, not a value type, so chopper's `@immutable` on `Interceptor`
  // doesn't apply here.
  Set<String> _requiredPathSuffixes = const {};

  /// Sets the endpoint suffixes (matched via [String.endsWith]) that require
  /// an `Idempotency-Key` header, per the app's own API contract.
  // ignore: use_setters_to_change_properties
  void configureRequiredPaths(Set<String> suffixes) =>
      _requiredPathSuffixes = suffixes;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final request = chain.request;
    final requiresKey = _requiredPathSuffixes.any(request.uri.path.endsWith);
    if (!requiresKey) return chain.proceed(request);

    final deviceId = await _deviceIdentity.deviceId;
    return chain.proceed(
      applyHeader(request, 'Idempotency-Key', deviceId),
    );
  }
}
