import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';

/// Retries a request on a transient failure (a thrown transport exception,
/// or a `>= 500` response) with exponential backoff.
///
/// **Never retries a bare `POST`/`PATCH`/`DELETE`.** A blind retry after a
/// network drop cannot tell whether the server already received and acted
/// on the original attempt — for a sensitive app (e.g. banking), that is a
/// duplicate-transaction risk, not just a wasted call. Retrying is only safe
/// when either the method is inherently idempotent (`GET`) or the request
/// already carries an `Idempotency-Key` header, which requires
/// `IdempotencyInterceptor` to run earlier in the chain than this one (see
/// `createChopperClient` / a feature's own `interceptors` list — this
/// interceptor is meant to sit last, closest to the actual network call).
@lazySingleton
class RetryInterceptor implements Interceptor {
  /// `@ignoreParam` keeps [maxAttempts] out of the generated registration —
  /// injectable resolves every constructor parameter from the DI container,
  /// optional ones included, and would otherwise look for a bare `int`
  /// registered in it and fail (the same failure mode `DeviceIdentity`'s
  /// `fetchDeviceId` and `AuthInterceptor`'s own doc comment already document
  /// for this codebase).
  RetryInterceptor({@ignoreParam this.maxAttempts = 3});

  /// Total attempts including the first — `maxAttempts: 3` means up to 2
  /// retries after the initial try.
  final int maxAttempts;

  static const _idempotencyHeader = 'Idempotency-Key';

  bool _isRetryable(Request request) =>
      request.method == 'GET' ||
      request.headers.containsKey(_idempotencyHeader);

  Duration _backoff(int attempt) =>
      Duration(milliseconds: 300 * (1 << attempt));

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final request = chain.request;
    if (!_isRetryable(request)) return chain.proceed(request);

    var attempt = 0;
    while (true) {
      try {
        final response = await chain.proceed(request);
        final shouldRetry = response.statusCode >= 500;
        if (!shouldRetry || attempt >= maxAttempts - 1) return response;
      } on Object {
        if (attempt >= maxAttempts - 1) rethrow;
      }
      await Future<void>.delayed(_backoff(attempt));
      attempt++;
    }
  }
}
