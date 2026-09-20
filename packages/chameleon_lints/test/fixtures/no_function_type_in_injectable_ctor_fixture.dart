// This fixture exists only to give NoFunctionTypeInInjectableCtor something
// to analyze — the unused constructor parameters are the point, not an
// oversight.
// ignore_for_file: avoid_unused_constructor_parameters

// Minimal stand-ins for injectable's annotations — the rule checks
// annotation names syntactically, so a real dependency on package:injectable
// isn't needed here.
class _LazySingleton {
  const _LazySingleton();
}

const lazySingleton = _LazySingleton();

@lazySingleton
class BadService {
  // expect_lint: chameleon_no_function_type_in_injectable_ctor
  BadService({DateTime Function()? now});
}

@lazySingleton
class GoodService {
  GoodService();

  GoodService.withClock(this._now);

  DateTime Function()? _now;

  DateTime? now() => _now?.call();
}

@lazySingleton
class BadFieldShorthandService {
  // expect_lint: chameleon_no_function_type_in_injectable_ctor
  BadFieldShorthandService(this._now);

  final DateTime Function()? _now;

  DateTime? now() => _now?.call();
}

// Not annotated — a function-type constructor parameter here is fine,
// injectable never looks at this class.
class PlainClass {
  PlainClass({DateTime Function()? now});
}
