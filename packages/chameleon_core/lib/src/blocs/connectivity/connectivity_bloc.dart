import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../network/network_info.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

// Singleton-scoped so every consumer — the app's `MultiBlocProvider`, a
// lifecycle hook in `_AppState`, and any feature bloc's constructor
// injection — shares one instance. Factory scope (`@injectable`) would
// silently hand each call a fresh bloc whose state diverges from what the UI
// shows.
@lazySingleton
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc(this._networkInfo) : super(const ConnectivityInitial()) {
    on<ConnectivityCheckRequested>(_onCheckRequested);
    on<_ConnectivityChanged>(_onChanged);
    _subscription = _networkInfo.onConnectivityChanged.listen(
      (isOnline) => add(_ConnectivityChanged(isOnline: isOnline)),
    );
  }

  final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _subscription;

  Future<void> _onCheckRequested(
    ConnectivityCheckRequested event,
    Emitter<ConnectivityState> emit,
  ) async {
    final isOnline = await _networkInfo.isConnected;
    emit(isOnline ? const ConnectivityOnline() : const ConnectivityOffline());
  }

  // Treat the stream event as a hint, not ground truth. connectivity_plus can
  // emit offline-without-online on a same-transport flap (wifi reassociates
  // without re-emitting); re-checking via `isConnected` here means a missed
  // recovery edge is corrected as soon as any later transition fires.
  Future<void> _onChanged(
    _ConnectivityChanged event,
    Emitter<ConnectivityState> emit,
  ) async {
    final isOnline = await _networkInfo.isConnected;
    emit(isOnline ? const ConnectivityOnline() : const ConnectivityOffline());
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
