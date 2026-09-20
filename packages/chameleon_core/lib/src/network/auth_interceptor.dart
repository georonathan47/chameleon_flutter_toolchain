import 'dart:async';

import 'package:flutter/services.dart';

import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';

import 'session_cache.dart';
import 'session_event_bus.dart';
import 'token_storage.dart';

/// Attaches the stored access token to outgoing requests and ends the session
/// on a 401.
///
/// There is deliberately **no token refresh** in this base implementation: a
/// backend that issues an access token only (no refresh endpoint) makes every
/// 401 terminal, and the user signs in again. An app whose backend adds a
/// refresh endpoint should wrap or replace this interceptor with one that
/// single-flights a refresh so concurrent 401s share one renewal instead of
/// stampeding.
///
/// [configureNoAuthPaths] sets the endpoints the contract marks
/// unauthenticated — a 401 from one of those is a rejected credential, not an
/// expired session, and must not wipe a session the user may still hold.
/// Matched by suffix so a base URL with a path prefix still matches.
///
/// This is a settable field rather than a constructor parameter on purpose:
/// injectable's generator resolves **every** constructor parameter on an
/// `@lazySingleton` class from the DI container, optional ones included — a
/// bare `Set<String>` parameter would make the generator look for one
/// registered in the container and fail. The app calls [configureNoAuthPaths]
/// once after DI wiring completes (the same "set once at boot" pattern this
/// package uses elsewhere — see `ChameleonLogger.useCrashReporter`), starting
/// deliberately empty so an unconfigured app wipes on every 401 rather than
/// silently exempting endpoints it never declared.
@lazySingleton
// A long-lived singleton configured once after DI wiring, not a value type —
// see configureNoAuthPaths below for why _noAuthPathSuffixes is mutable.
// ignore: must_be_immutable
class AuthInterceptor implements Interceptor {
  AuthInterceptor(
    this._tokenStorage,
    this._sessionEventBus,
    this._sessionCache,
  );

  final TokenStorage _tokenStorage;
  final SessionEventBus _sessionEventBus;
  final SessionCache _sessionCache;

  Set<String> _noAuthPathSuffixes = const {};

  /// Sets the endpoints that carry no bearer token. See the class doc.
  // ignore: use_setters_to_change_properties
  void configureNoAuthPaths(Set<String> suffixes) =>
      _noAuthPathSuffixes = suffixes;

  Future<void> _wipeSession() async {
    await _tokenStorage.clearTokens();
    await _sessionCache.clear();
    _fireSessionExpiredIfRoot();
  }

  /// Fires [SessionEventBus.notifySessionExpired] only when running on the
  /// root isolate.
  ///
  /// The bus is held as a constructor-injected field rather than resolved
  /// from a service locator at call time, but it must still not be *used* on
  /// a worker isolate: [SessionEventBus] contains a `StreamController`, which
  /// is unsendable across isolates — this interceptor itself crosses into
  /// `compute()` as part of the chopper client graph, so `_sessionEventBus`
  /// exists on the worker's copy but has no listener there.
  ///
  /// Worker isolates simply skip the signal. Worker-side wipes still clear
  /// secure storage (process-wide), and the next root-side request that hits
  /// this interceptor will find no token and route the user through the
  /// normal unauthenticated flow.
  void _fireSessionExpiredIfRoot() {
    if (RootIsolateToken.instance == null) return;
    _sessionEventBus.notifySessionExpired();
  }

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final path = chain.request.uri.path;
    final isPublic = _noAuthPathSuffixes.any(path.endsWith);

    if (isPublic) return chain.proceed(chain.request);

    final token = await _tokenStorage.getAccessToken();
    if (token == null) return chain.proceed(chain.request);

    final authedRequest = applyHeader(
      chain.request,
      'Authorization',
      'Bearer $token',
    );
    final response = await chain.proceed(authedRequest);

    if (response.statusCode != 401) return response;

    await _wipeSession();
    return response;
  }
}
