import 'package:injectable/injectable.dart';

import '../services/device_service.dart';

/// Resolves and caches this device's stable identifier.
///
/// Wraps the static [DeviceService] so callers (and tests) depend on an
/// injectable instead of a static platform-channel call. The id is resolved
/// once per process and reused — it backs the `Idempotency-Key` header, which
/// must stay stable across retries of the same submission.
/// Resolves this device's id. Aliased so `injectable` can name the type — it
/// cannot resolve a bare function type in a constructor parameter.
typedef FetchDeviceId = Future<String> Function();

@lazySingleton
class DeviceIdentity {
  /// [fetchDeviceId] is overridable for tests; production uses
  /// [DeviceService.getDeviceId].
  ///
  /// `@ignoreParam` keeps it out of the generated registration — it is a test
  /// seam, not a dependency for the container to resolve.
  DeviceIdentity({@ignoreParam FetchDeviceId? fetchDeviceId})
    : _fetchDeviceId = fetchDeviceId ?? DeviceService.getDeviceId;

  final FetchDeviceId _fetchDeviceId;

  String? _cached;
  Future<String>? _inFlight;

  /// This device's id, resolved once and cached.
  Future<String> get deviceId {
    final cached = _cached;
    if (cached != null) return Future.value(cached);
    return _inFlight ??= _fetchDeviceId().then((id) {
      _cached = id;
      _inFlight = null;
      return id;
    });
  }
}
