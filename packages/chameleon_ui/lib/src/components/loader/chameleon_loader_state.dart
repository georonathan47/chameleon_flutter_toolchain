part of 'chameleon_loader_cubit.dart';

/// Presentation states for a timed loader screen.
///
/// Sealed so the UI can exhaustively handle every case: the loader is either
/// still showing ([ChameleonLoaderInitial]) or has finished its hold and is
/// ready to hand off to the next route ([ChameleonLoaderCompleted]).
sealed class ChameleonLoaderState {
  const ChameleonLoaderState();
}

/// The loader is being displayed; its timed hold has not yet elapsed.
final class ChameleonLoaderInitial extends ChameleonLoaderState {
  const ChameleonLoaderInitial();
}

/// The timed hold has elapsed; the app should redirect away from the loader.
final class ChameleonLoaderCompleted extends ChameleonLoaderState {
  const ChameleonLoaderCompleted();
}
