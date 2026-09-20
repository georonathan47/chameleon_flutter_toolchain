class ServerException implements Exception {
  const ServerException(this.message);
  final String message;

  @override
  String toString() => message;
}

class StateException implements Exception {
  const StateException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection.']);
  final String message;

  @override
  String toString() => message;
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class LivenessException implements Exception {
  const LivenessException(this.message);
  final String message;

  @override
  String toString() => message;
}

class CacheException implements Exception {
  const CacheException(this.message);
  final String message;

  @override
  String toString() => message;
}

class LinkExpiredException implements Exception {
  const LinkExpiredException([this.message = 'Login link has expired.']);
  final String message;

  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  const NotFoundException([this.message = 'Resource not found.']);
  final String message;

  @override
  String toString() => message;
}
