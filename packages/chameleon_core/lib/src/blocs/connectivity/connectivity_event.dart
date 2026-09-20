part of 'connectivity_bloc.dart';

sealed class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();
}

final class ConnectivityCheckRequested extends ConnectivityEvent {
  const ConnectivityCheckRequested();

  @override
  List<Object?> get props => [];
}

final class _ConnectivityChanged extends ConnectivityEvent {
  const _ConnectivityChanged({required this.isOnline});

  final bool isOnline;

  @override
  List<Object?> get props => [isOnline];
}
