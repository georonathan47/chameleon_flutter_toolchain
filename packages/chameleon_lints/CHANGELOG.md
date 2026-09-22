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
