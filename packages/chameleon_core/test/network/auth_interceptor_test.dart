import 'dart:async';

import 'package:chameleon_core/chameleon_core.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockTokenStorage extends Mock implements TokenStorage {}

class _MockSessionCache extends Mock implements SessionCache {}

/// A minimal [Chain] that hands `request` straight to `AuthInterceptor` and,
/// on [proceed], plays the role of "the rest of the chain" — recording the
/// request that actually reached it (so a test can assert on headers
/// `AuthInterceptor` added) and returning a response with the given status,
/// shaped the way chopper actually builds one (an `http.Response` wrapped by
/// `Response`), not a shortcut a real client would never produce.
class _FakeChain<BodyType> implements Chain<BodyType> {
  _FakeChain(this.request, this._downstreamStatus);

  @override
  final Request request;

  final int _downstreamStatus;
  Request? lastProceededRequest;

  @override
  FutureOr<Response<BodyType>> proceed(Request request) async {
    lastProceededRequest = request;
    final base = http.Response('', _downstreamStatus);
    return Response<BodyType>(base, null);
  }
}

void main() {
  // AuthInterceptor's root-isolate check reads RootIsolateToken.instance,
  // which needs a binding — the root test isolate has one once this runs.
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockTokenStorage tokenStorage;
  late _MockSessionCache sessionCache;
  late SessionEventBus sessionEventBus;
  late AuthInterceptor interceptor;
  late _FakeChain<String> chain;

  setUp(() {
    tokenStorage = _MockTokenStorage();
    sessionCache = _MockSessionCache();
    sessionEventBus = SessionEventBus();
    interceptor = AuthInterceptor(tokenStorage, sessionEventBus, sessionCache);
    when(() => sessionCache.clear()).thenAnswer((_) async {});
    when(() => tokenStorage.clearTokens()).thenAnswer((_) async {});
  });

  Request buildRequest(String path) {
    final uri = Uri.parse('https://api.example.com$path');
    return Request('GET', uri, uri);
  }

  Future<Response<String>> run(Request request, int downstreamStatus) async {
    chain = _FakeChain<String>(request, downstreamStatus);
    return interceptor.intercept<String>(chain);
  }

  test('a public path is never given an Authorization header', () async {
    interceptor.configureNoAuthPaths({'/api/auth/login'});
    when(
      () => tokenStorage.getAccessToken(),
    ).thenAnswer((_) async => 'a-token');

    await run(buildRequest('/api/auth/login'), 401);

    expect(
      chain.lastProceededRequest!.headers.containsKey('Authorization'),
      false,
    );
    verifyNever(() => tokenStorage.getAccessToken());
  });

  test('a public path never wipes the session, even on 401', () async {
    interceptor.configureNoAuthPaths({'/api/auth/login'});

    await run(buildRequest('/api/auth/login'), 401);

    verifyNever(() => tokenStorage.clearTokens());
    verifyNever(() => sessionCache.clear());
  });

  test('a request with no stored token proceeds without a header', () async {
    when(() => tokenStorage.getAccessToken()).thenAnswer((_) async => null);

    await run(buildRequest('/api/accounts'), 200);

    expect(
      chain.lastProceededRequest!.headers.containsKey('Authorization'),
      false,
    );
  });

  test('a request with a stored token gets a Bearer header', () async {
    when(
      () => tokenStorage.getAccessToken(),
    ).thenAnswer((_) async => 'secret-token');

    await run(buildRequest('/api/accounts'), 200);

    expect(
      chain.lastProceededRequest!.headers['Authorization'],
      'Bearer secret-token',
    );
  });

  test(
    'a 401 on an authenticated path wipes tokens and the session cache '
    'and notifies SessionEventBus',
    () async {
      when(
        () => tokenStorage.getAccessToken(),
      ).thenAnswer((_) async => 'a-token');

      final expired = expectLater(
        sessionEventBus.onSessionExpired,
        emits(null),
      );

      await run(buildRequest('/api/accounts'), 401);

      verify(() => tokenStorage.clearTokens()).called(1);
      verify(() => sessionCache.clear()).called(1);
      await expired;
    },
  );

  test('a non-401 response does not wipe the session', () async {
    when(
      () => tokenStorage.getAccessToken(),
    ).thenAnswer((_) async => 'a-token');

    await run(buildRequest('/api/accounts'), 200);

    verifyNever(() => tokenStorage.clearTokens());
    verifyNever(() => sessionCache.clear());
  });
}
