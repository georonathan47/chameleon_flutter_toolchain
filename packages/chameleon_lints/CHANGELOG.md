## 0.3.0

- Added `chameleon_no_print`: flags a bare `print(...)`/`debugPrint(...)`
  call — output belongs in the logging service (`ChameleonLogger`). A
  user-defined function of the same name and a file named
  `logging_service.dart` are exempt.
- Added `chameleon_datasource_requires_isolate`: flags a public datasource
  method (files under `data/datasources/`) whose body doesn't route through
  `runApiCall`/`runInIsolate`/`compute`/`Isolate.run`/`Isolate.spawn`.
- Added `chameleon_chopper_requires_error_check`: flags a chopper
  `Response.body` read where the same variable's `.isSuccessful`/`.error` is
  never checked in that function.

## 0.2.1

- Fixed `chameleon_task_either_requires_safe_construction` flagging an
  abstract interface method (no body to construct unsafely) — found
  against `chameleon_feature`'s own generated
  `WidgetsRepository.getWidgets()`, the first time this rule ever ran
  against real generated output (e2e coverage for `chameleon feature`
  didn't exist until now).

## 0.2.0

- Added `chameleon_prefer_dot_shorthands`: flags a qualified `Type.member`
  access in a typed variable, argument, or return position where Dart's
  dot-shorthand (`.member`) syntax already applies.
- Added `chameleon_prefer_barrel_imports`: flags an import reaching past a
  feature's barrel file into one of its internal layers from outside that
  feature.
- Added `chameleon_prefer_sealed_class`: flags a non-sealed abstract class
  whose subtypes are all declared in the same file; suppress a deliberately
  open hierarchy with `// ignore: chameleon_prefer_sealed_class`.
- Added `chameleon_task_either_requires_safe_construction`: flags a
  `TaskEither<Failure, ...>`-returning method/function not built from a
  safe `TaskEither` constructor (`tryCatch`/`of`/`right`/`left`/
  `fromEither`/`fromTask`/`fromOption`).

## 0.1.0

- Initial version.
