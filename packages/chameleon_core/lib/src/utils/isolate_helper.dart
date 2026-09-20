import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../config/flavor_config.dart';

// Wraps Flutter's compute() for running data-layer work off the UI thread.
Future<R> runInIsolate<Q, R>(
  ComputeCallback<Q, R> callback,
  Q message,
) => compute(callback, message);

/// Captured on the root isolate, passed into compute() args, then used at the
/// top of each worker function via [initIsolateBinaryMessenger].
RootIsolateToken get rootIsolateToken => RootIsolateToken.instance!;

/// Call as the FIRST line of every compute() worker that goes through Chopper
/// (or any other plugin that uses MethodChannels). Without this, the auth
/// interceptor's secure-storage writes/refresh paths crash with
/// "BackgroundIsolateBinaryMessenger.instance value is invalid".
///
/// Also re-seeds [FlavorConfig] when a [flavor] snapshot is supplied. Statics
/// are per-isolate, so without this the worker's flavor is unset and
/// `ChameleonLogger.logAPI` — called by the network interceptor on every
/// response — would log nothing, silently dropping the request/response trail
/// for every call that runs off the root isolate.
void initIsolateBinaryMessenger(
  RootIsolateToken token, [
  FlavorSnapshot? flavor,
]) {
  BackgroundIsolateBinaryMessenger.ensureInitialized(token);
  if (flavor != null) FlavorConfig.restoreOnIsolate(flavor);
}

/// Everything a worker needs to perform one API call: the service to call
/// through, the request body, the root token that re-enables platform channels
/// on the worker side, and the flavor snapshot that keeps network logging
/// working there.
///
/// Bundled into one object because [compute] takes a single message
/// argument. All parts are sendable — the chopper service graph copies across
/// the isolate boundary intact, including the interceptors and their
/// secure-storage handles.
typedef ApiCall<S, B> = ({
  S service,
  B body,
  RootIsolateToken token,
  FlavorSnapshot? flavor,
});

/// Runs [endpoint] against `call.service` on a worker isolate, keeping JSON
/// decode and model mapping off the UI thread.
///
/// [endpoint] must be a **top-level or static** function: `compute()` cannot
/// ship an instance-method closure, so repositories pass a top-level worker
/// rather than a method tear-off.
///
/// Note the request body is *copied* into the worker. That is cheap for the
/// small JSON bodies these endpoints take, but a large payload (e.g. a base64
/// image) can cost more to copy than the decode saves — call such endpoints
/// directly on the root isolate instead.
Future<R> runApiCall<S, B, R>(
  ApiCall<S, B> call,
  Future<R> Function(ApiCall<S, B> call) endpoint,
) => compute(endpoint, call);
