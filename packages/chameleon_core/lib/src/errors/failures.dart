/// Base class for every domain failure in an app built on this package.
///
/// `abstract base class` rather than `sealed`: a package cannot enumerate
/// every failure an app will ever need (app-specific failures — a liveness
/// SDK's spoof/deepfake detections, a login-flow failure, etc. — extend this
/// from the app itself), so the exhaustive-switch guarantee `sealed` buys
/// isn't available here regardless. `base` still blocks `implements`, so
/// every failure remains a genuine subclass that carries this constructor's
/// fields.
abstract base class Failure {
  const Failure(
    this.message, {
    this.statusCode,
    this.debugMessage,
    this.stackTrace,
    this.validationFields,
  });

  /// What the USER sees ("Check your connection").
  final String message;

  /// What YOU see ("GET /movies → SocketException").
  final String? debugMessage;

  /// HTTP status code, if applicable.
  final int? statusCode;
  final StackTrace? stackTrace;
  final List<String>? validationFields;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Check your internet connection']);

  NetworkFailure.withDebug({
    String message = 'Check your internet connection',
    String? debugMessage,
    StackTrace? stackTrace,
  }) : super(message, debugMessage: debugMessage, stackTrace: stackTrace);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error, try again later']);

  ServerFailure.withDebug({
    String message = 'Server error, try again later',
    int? statusCode,
    String? debugMessage,
    StackTrace? stackTrace,
  }) : super(
         message,
         statusCode: statusCode,
         debugMessage: debugMessage,
         stackTrace: stackTrace,
       );
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expired']);

  UnauthorizedFailure.withDebug({
    String message = 'Session expired, please login again!',
    int? statusCode,
    String? debugMessage,
    StackTrace? stackTrace,
  }) : super(
         message,
         statusCode: statusCode,
         debugMessage: debugMessage,
         stackTrace: stackTrace,
       );
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Content not found']);

  NotFoundFailure.withDebug({
    String message = 'Content not found.',
    int? statusCode,
    String? debugMessage,
    StackTrace? stackTrace,
  }) : super(
         message,
         statusCode: statusCode,
         debugMessage: debugMessage,
         stackTrace: stackTrace,
       );
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Unexpected error occurred']);

  UnexpectedFailure.withDebug({
    String message = 'An unexpected error occurred, please try again!',
    int? statusCode,
    String? debugMessage,
    StackTrace? stackTrace,
  }) : super(
         message,
         statusCode: statusCode,
         debugMessage: debugMessage,
         stackTrace: stackTrace,
       );
}

/// A failure that did not match any known category.
/// Carries the original reason.
final class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'An unknown error occurred. Please try again.',
  ]);

  const UnknownFailure.withDebug({
    String message = 'An unknown error occurred. Please try again.',
    int? statusCode,
    String? debugMessage,
    StackTrace? stackTrace,
  }) : super(
         message,
         statusCode: statusCode,
         debugMessage: debugMessage,
         stackTrace: stackTrace,
       );
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error.']);

  CacheFailure.withDebug({
    String message = 'Cache error occurred',
    int? statusCode,
    String? debugMessage,
    StackTrace? stackTrace,
  }) : super(
         message,
         statusCode: statusCode,
         debugMessage: debugMessage,
         stackTrace: stackTrace,
       );
}

final class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'Please make sure that the fields have valid inputs',
  ]);

  ValidationFailure.withDebug({
    String message = 'Please make sure that the fields have valid inputs',
    int? statusCode,
    String? debugMessage,
    StackTrace? stackTrace,
    List<String>? validationFields,
  }) : super(
         message,
         statusCode: statusCode,
         debugMessage: debugMessage,
         stackTrace: stackTrace,
         validationFields: validationFields,
       );
}
