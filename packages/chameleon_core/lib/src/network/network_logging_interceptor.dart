import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';

import '../utils/logging/logging_service.dart';

/// Logs every network request and its response via [ChameleonLogger.logAPI],
/// which routes through `dart:developer.log` so each entry shows up in the
/// IDE/devtools log pane, tagged by source and colored by status emoji
/// (✅ 2xx, ❌ 4xx, 🚫 5xx).
///
/// Each entry includes: full URL, method, status code, request duration,
/// redacted request body (when present), and the **redacted response body**.
/// Capturing the response body is what makes downstream `fromJson` failures
/// diagnosable — when a model cast fails, the body that broke it sits in
/// the previous log line. Sensitive fields are redacted recursively so a
/// nested `accessToken` is caught regardless of nesting depth.
class NetworkLoggingInterceptor implements Interceptor {
  const NetworkLoggingInterceptor();

  /// JSON keys whose values are stripped before logging. Matched
  /// case-insensitively at any nesting depth.
  static const _sensitiveKeys = <String>{
    'password',
    'otp',
    'token',
    'access_token',
    'refresh_token',
    'accessToken',
    'refreshToken',
    'idToken',
    'bearerToken',
    'secret',
  };

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final request = chain.request;
    final method = request.method;
    final source = request.uri.path;
    final fullUrl = _fullUrl(request);

    final requestBody = _previewBody(request.body);

    final stopwatch = Stopwatch()..start();
    final response = await chain.proceed(request);
    final durationMs = stopwatch.elapsedMilliseconds;

    final responseBody = _previewResponseBody(response);
    final errorText = response.isSuccessful ? null : response.error?.toString();
    final tail = [
      responseBody,
      errorText,
    ].whereType<String>().where((part) => part.isNotEmpty).join(' | ');

    ChameleonLogger.logAPI(
      source,
      method,
      fullUrl,
      requestBody: requestBody,
      responseBody: tail.isEmpty ? null : tail,
      code: response.statusCode,
      durationMs: durationMs,
    );

    return response;
  }

  /// Resolves the request to an absolute URL so logs always include the
  /// base host, regardless of whether `request.uri` is already absolute or
  /// path-only in the running Chopper version.
  String _fullUrl(Request request) {
    final uri = request.uri;
    return uri.hasScheme
        ? uri.toString()
        : request.baseUri.resolveUri(uri).toString();
  }

  /// Returns a human-readable, redacted preview of [body], or null when there
  /// is nothing useful to log (null/empty body, GET requests, etc).
  String? _previewBody(Object? body) {
    if (body == null) return null;
    if (body is! String) return '<${body.runtimeType}>';
    if (body.isEmpty) return null;

    try {
      final decoded = json.decode(body);
      return json.encode(_redactDeep(decoded));
    } on FormatException {
      // Not JSON — log as-is (e.g. form-urlencoded).
      return body;
    }
  }

  /// Mirrors [_previewBody] but for the chopper response. Body may be a
  /// converted Map/List, a raw String, raw bytes (when the JSON converter
  /// skipped non-JSON error payloads), or some chopper internal stream type.
  /// Tries hardest to surface human-readable text — falls back to the
  /// runtime type only when nothing else works.
  String? _previewResponseBody(Response<dynamic> response) {
    final body = response.body;
    if (body == null) return null;
    if (body is String) return _previewBody(body);

    // Raw bytes — common when the backend returns a non-JSON error page
    // (HTML, plain text) and the JSON converter doesn't run.
    if (body is List<int>) {
      try {
        final decoded = utf8.decode(body);
        return _previewBody(decoded) ?? decoded;
      } on FormatException {
        return '<${body.length} bytes>';
      }
    }

    try {
      return json.encode(_redactDeep(body));
    } on Object {
      // Last resort: try toString() — often more informative than the
      // bare runtimeType for chopper internals like collected byte streams.
      final asString = body.toString();
      if (asString.isNotEmpty &&
          asString != '<${body.runtimeType}>' &&
          !asString.startsWith("Instance of '")) {
        return asString;
      }
      return '<${body.runtimeType}>';
    }
  }

  /// Recursively walks the decoded JSON value, replacing any value whose key
  /// matches [_sensitiveKeys] (case-insensitive) with `[REDACTED]`.
  Object? _redactDeep(Object? value) {
    if (value is Map) {
      final out = <String, dynamic>{};
      value.forEach((key, v) {
        final keyStr = key.toString();
        out[keyStr] = _isSensitive(keyStr) ? '[REDACTED]' : _redactDeep(v);
      });
      return out;
    }
    if (value is List) {
      return value.map(_redactDeep).toList(growable: false);
    }
    return value;
  }

  bool _isSensitive(String key) {
    final lower = key.toLowerCase();
    for (final sensitive in _sensitiveKeys) {
      if (sensitive.toLowerCase() == lower) return true;
    }
    return false;
  }
}
