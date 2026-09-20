import 'dart:async';

import 'package:chameleon_core/chameleon_core.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

/// Plays back one scripted outcome per `proceed()` call — either a status
/// code or a thrown exception — and counts how many times it was called, so
/// a test can assert exactly how many attempts `RetryInterceptor` made.
class _ScriptedChain<BodyType> implements Chain<BodyType> {
  _ScriptedChain(this.request, this._script);

  @override
  final Request request;

  final List<Object> _script;
  int callCount = 0;

  @override
  FutureOr<Response<BodyType>> proceed(Request request) async {
    final outcome = _script[callCount];
    callCount++;
    if (outcome is Exception) throw outcome;
    final base = http.Response('', outcome as int);
    return Response<BodyType>(base, null);
  }
}

Request _request({required String method}) =>
    Request(method, Uri.parse('https://api.chameleon.test/x'), Uri());

Request _requestWithHeaders(String method, Map<String, String> headers) =>
    Request(
      method,
      Uri.parse('https://api.chameleon.test/x'),
      Uri(),
      headers: headers,
    );

void main() {
  group('RetryInterceptor', () {
    test('retries a GET on repeated 500s, up to maxAttempts', () async {
      final interceptor = RetryInterceptor();
      final chain = _ScriptedChain<String>(
        _request(method: 'GET'),
        [500, 500, 500],
      );

      final response = await interceptor.intercept(chain);

      expect(chain.callCount, equals(3));
      expect(response.statusCode, equals(500));
    });

    test('stops retrying a GET once a non-5xx response arrives', () async {
      final interceptor = RetryInterceptor();
      final chain = _ScriptedChain<String>(
        _request(method: 'GET'),
        [500, 200],
      );

      final response = await interceptor.intercept(chain);

      expect(chain.callCount, equals(2));
      expect(response.statusCode, equals(200));
    });

    test('never retries a bare POST with no Idempotency-Key', () async {
      final interceptor = RetryInterceptor();
      final chain = _ScriptedChain<String>(
        _request(method: 'POST'),
        [500, 500, 500],
      );

      final response = await interceptor.intercept(chain);

      expect(chain.callCount, equals(1));
      expect(response.statusCode, equals(500));
    });

    test('retries a POST that already carries an Idempotency-Key', () async {
      final interceptor = RetryInterceptor();
      final chain = _ScriptedChain<String>(
        _requestWithHeaders('POST', const {'Idempotency-Key': 'device-1'}),
        [500, 200],
      );

      final response = await interceptor.intercept(chain);

      expect(chain.callCount, equals(2));
      expect(response.statusCode, equals(200));
    });

    test('retries a thrown transport exception, then gives up', () async {
      final interceptor = RetryInterceptor(maxAttempts: 2);
      final chain = _ScriptedChain<String>(_request(method: 'GET'), [
        Exception('socket closed'),
        Exception('socket closed'),
      ]);

      await expectLater(
        () => interceptor.intercept(chain),
        throwsA(isException),
      );
      expect(chain.callCount, equals(2));
    });
  });
}
