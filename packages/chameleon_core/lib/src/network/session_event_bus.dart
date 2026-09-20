import 'dart:async';

import 'package:injectable/injectable.dart';

/// One-way signal from the auth interceptor (network layer) to the auth
/// bloc (presentation layer) when a session becomes unrecoverable.
///
/// Fired by `AuthInterceptor._wipeSession()` after a failed refresh.
/// `AuthBloc` subscribes and emits `AuthUnauthenticated`, which routes the
/// user back to `/login` via the existing splash → router redirect chain.
/// Keeping the channel here means the network layer never imports from
/// the presentation layer.
@lazySingleton
class SessionEventBus {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get onSessionExpired => _controller.stream;

  void notifySessionExpired() {
    if (!_controller.isClosed) _controller.add(null);
  }

  @disposeMethod
  Future<void> dispose() => _controller.close();
}
