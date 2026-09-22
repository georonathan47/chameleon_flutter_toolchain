// This fixture exists only to give PreferSealedClass something to analyze.

abstract class UnsealedState {} // triggers chameleon_prefer_sealed_class

class LoadingState extends UnsealedState {}

class LoadedState extends UnsealedState {}

sealed class AlreadySealedState {} // not flagged — already sealed

class SealedLoadingState extends AlreadySealedState {}

class SealedLoadedState extends AlreadySealedState {}

abstract class SingleSubtypeState {} // not flagged — fewer than 2 subtypes

class OnlyState extends SingleSubtypeState {}

abstract interface class Shape {} // triggers chameleon_prefer_sealed_class

class Circle implements Shape {}

class Square implements Shape {}

class NotAbstract {} // never a candidate — not abstract at all

class NotAbstractSubtypeOne extends NotAbstract {}

class NotAbstractSubtypeTwo extends NotAbstract {}

// A closed-by-subclass-count-today hierarchy that's deliberately left open
// for external subclassing — mirrors chameleon_core's real Failure class.
// ignore: chameleon_prefer_sealed_class
abstract base class OpenFailure {
  const OpenFailure(this.message);
  final String message;
}

final class NetworkOpenFailure extends OpenFailure {
  const NetworkOpenFailure() : super('network');
}

final class ServerOpenFailure extends OpenFailure {
  const ServerOpenFailure() : super('server');
}
