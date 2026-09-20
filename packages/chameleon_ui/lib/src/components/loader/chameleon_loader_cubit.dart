import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

part 'chameleon_loader_state.dart';

/// Drives a loading screen's timed lifecycle.
///
/// Business logic (the hold-then-redirect timer) lives here rather than in
/// the widget: the view only reacts to state changes, typically showing a
/// `ChameleonSpinner` while [ChameleonLoaderInitial] is current. On creation
/// the cubit starts a timer; after [holdDuration] elapses it emits
/// [ChameleonLoaderCompleted], signalling the view to redirect to the next
/// route.
///
/// This orchestration is independent of any particular visual — it is a
/// generic "show something, then hand off" pattern, not tied to
/// `ChameleonMark`/`ChameleonSpinner` specifically.
class ChameleonLoaderCubit extends Cubit<ChameleonLoaderState> {
  ChameleonLoaderCubit() : super(const ChameleonLoaderInitial()) {
    _timer = Timer(holdDuration, _complete);
  }

  /// How long the loader stays on screen before redirecting.
  static const Duration holdDuration = Duration(milliseconds: 2000);

  late final Timer _timer;

  /// Emits [ChameleonLoaderCompleted] once the hold elapses. Guarded so a
  /// fast unmount (cubit closed before the timer fires) never emits after
  /// close.
  void _complete() {
    if (!isClosed) emit(const ChameleonLoaderCompleted());
  }

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}
