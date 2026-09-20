part of 'connectivity_bloc.dart';

sealed class ConnectivityState extends Equatable {
  const ConnectivityState();
}

final class ConnectivityInitial extends ConnectivityState {
  const ConnectivityInitial();

  @override
  List<Object?> get props => [];
}

final class ConnectivityOnline extends ConnectivityState {
  const ConnectivityOnline();

  @override
  List<Object?> get props => [];
}

final class ConnectivityOffline extends ConnectivityState {
  const ConnectivityOffline();

  @override
  List<Object?> get props => [];
}
