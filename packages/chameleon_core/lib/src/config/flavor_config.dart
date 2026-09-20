import 'package:flutter/foundation.dart';

enum Flavor { dev, stg, prod }

/// The active flavor in plain sendable form, for shipping across an isolate
/// boundary. [FlavorConfig] itself holds only sendable fields today, but this
/// keeps the crossing explicit and independent of that staying true.
@immutable
class FlavorSnapshot {
  const FlavorSnapshot({
    required this.flavor,
    required this.name,
    required this.bannerColor,
  });

  final Flavor flavor;
  final String name;
  final int bannerColor;
}

@immutable
class FlavorConfig {
  const FlavorConfig._({
    required this.flavor,
    required this.name,
    required this.bannerColor,
  });

  static FlavorConfig? _instance;

  static FlavorConfig get instance {
    assert(_instance != null, 'FlavorConfig must be initialized before use');
    return _instance!;
  }

  /// The active flavor, or `null` when [initialize] hasn't run.
  ///
  /// Unlike [instance] this never asserts, so presentation-layer code that
  /// merely *varies* by flavor can fall back to a sensible default instead of
  /// requiring every widget test to bootstrap a flavor first. Use [instance]
  /// wherever a missing flavor is genuinely a programming error.
  static Flavor? get flavorOrNull => _instance?.flavor;

  static void initialize({
    required Flavor flavor,
    required String name,
    required int bannerColor,
  }) {
    _instance = FlavorConfig._(
      flavor: flavor,
      name: name,
      bannerColor: bannerColor,
    );
  }

  /// Re-seeds the flavor on a worker isolate.
  ///
  /// Statics are per-isolate: a worker started by `compute()` begins with
  /// `_instance` null, so anything reading [instance] there — notably
  /// `ChameleonLogger.logAPI` from the network interceptor — would assert in
  /// debug and throw on the null check in release. Data-layer isolate workers
  /// call this first (via `initIsolateBinaryMessenger`) so logging behaves
  /// exactly as it does on the root isolate.
  ///
  /// Idempotent, and a no-op once the flavor is already set, so it is safe to
  /// call at the top of every worker.
  static void restoreOnIsolate(FlavorSnapshot snapshot) {
    _instance ??= FlavorConfig._(
      flavor: snapshot.flavor,
      name: snapshot.name,
      bannerColor: snapshot.bannerColor,
    );
  }

  /// The active flavor as a plain sendable value, or null when [initialize]
  /// hasn't run. Captured on the root isolate and shipped to workers.
  static FlavorSnapshot? get snapshot {
    final current = _instance;
    if (current == null) return null;
    return FlavorSnapshot(
      flavor: current.flavor,
      name: current.name,
      bannerColor: current.bannerColor,
    );
  }

  final Flavor flavor;
  final String name;
  final int bannerColor;

  bool get isDev => flavor == Flavor.dev;
  bool get isStg => flavor == Flavor.stg;
  bool get isProd => flavor == Flavor.prod;
  bool get isPreProd => flavor == Flavor.stg;
  bool get isNotProd => flavor != Flavor.prod;
  bool get isConsoleLoggingEnabled => flavor != Flavor.prod;
}
