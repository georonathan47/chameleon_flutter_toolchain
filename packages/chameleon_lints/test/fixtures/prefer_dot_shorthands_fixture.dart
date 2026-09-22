// This fixture exists only to give PreferDotShorthands something to
// analyze.
//
// avoid_print/prefer_final_locals/omit_local_variable_types are suppressed
// file-wide: several of the three tracked positions below (a typed local
// variable, in particular) only exist to demonstrate a pattern
// very_good_analysis's own style rules would otherwise want removed — not
// relevant to what's under test here.
// ignore_for_file: avoid_print, prefer_final_locals, omit_local_variable_types

enum FlavorType { dev, staging, production }

void takesFlavor(FlavorType flavor) {}

FlavorType returnsFlavor() {
  return FlavorType.dev; // triggers chameleon_prefer_dot_shorthands
}

FlavorType arrowFlavor() =>
    FlavorType.staging; // triggers chameleon_prefer_dot_shorthands

void flagsExplicitlyTypedVariable() {
  FlavorType flavor =
      FlavorType.dev; // triggers chameleon_prefer_dot_shorthands
  print(flavor);
}

void flagsTypedArgument() {
  takesFlavor(
    FlavorType.production,
  ); // triggers chameleon_prefer_dot_shorthands
}

void doesNotFlagInferredVariable() {
  var flavor = FlavorType.dev; // no explicit type annotation — not flagged
  print(flavor);
}

void doesNotFlagAlreadyShorthand() {
  FlavorType flavor = .dev; // already a dot shorthand — a different AST node
  print(flavor);
}

void doesNotFlagUnrelatedPosition() {
  // FlavorType.dev is the receiver of a property access here, not one of
  // the three tracked positions (typed variable/argument/return) — not
  // flagged.
  final label = FlavorType.dev.name;
  print(label);
}
