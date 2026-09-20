# chameleon_ui

Chameleon's design language as code — tokens, theme, and shared components,
so every app built on the Chameleon Flutter toolchain looks and moves the
same without copying widgets between repos. No brand assets required: this
package ships with zero logos, brand fonts, or brand colors baked in.

## Design philosophy

**A design-system package must not know what a flavor is.** Concretely:

- [`FlavorBanner`](lib/src/components/flavor_banner.dart) takes a plain
  `label`, `color`, and `shown` as constructor arguments — it has no idea
  what "dev" or "staging" means. The convention this toolchain uses (red for
  dev, blue for staging, transparent/none for production) lives in the
  *app* that wires up those arguments from its own flavor config, not in
  this package.
- Typography is built from a single, fixed typeface (Inter) rather than a
  per-flavor typeface swap. A build's environment should never change what
  fonts render — that kind of signal belongs in a widget like
  `FlavorBanner`, not silently baked into the type ramp.
- The loading mark (`ChameleonMark`/`ChameleonSpinner`) is an original,
  generic chameleon silhouette — not a bank logo, not any consuming app's
  brand mark. Apps that want their own brand on the loading state are
  expected to swap it in themselves.

## Features

- **Tokens** — [`ChameleonColors`](lib/src/tokens/chameleon_colors.dart)
  (raw palette) and `ChameleonSemanticColors` (role-based: `primary`,
  `textPrimary`, …), [`ChameleonSpacing`](lib/src/tokens/chameleon_spacing.dart)
  / `ChameleonRadius`, `ChameleonTypography` (the full text-style ramp,
  fixed to Inter), and `ChameleonMotion` (durations and curves).
- **Theme** — `ChameleonTheme.light` builds a `ThemeData` from the semantic
  color tokens, so widgets never hardcode a `Color` or `TextStyle` directly.
- **Components** — `ChameleonToastMessenger`/`ChameleonToastHost` (5 toast
  types with bundled SVG icons), `ChameleonLoadingDialog`, the loader group
  (`ChameleonMark`, `ChameleonSpinner`, `ChameleonLoaderCubit`),
  `FlavorBanner`, `ActivityDetector` (idle/foreground/background detection
  via `Listener`, not `GestureDetector`, so it never steals gestures from
  the gesture arena), `GlobalGlassSurface`/`AuthGlassSurface`,
  `DismissKeyboard`.
- **`StringX` extension** — `'Welcome back'.asHeading2()`, `.asBody1()`,
  `.toPrimaryButton(onPressed: ...)`, and one method per typography ramp
  entry, so call sites never inline a font size or weight.

## Usage

Apply the theme once, at boot:

```dart
import 'package:chameleon_ui/chameleon_ui.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(theme: ChameleonTheme.light, home: const HomePage()));
}
```

Style text through the ramp instead of inline `TextStyle`s:

```dart
'Welcome back'.asHeading2();
'A Chameleon account, built for you.'.asBody2(color: ChameleonSemanticColors.textSecondary);
'Continue'.toPrimaryButton(onPressed: () {});
```

Show a toast (mount `ChameleonToastHost` once, near the root, above your
navigator):

```dart
MaterialApp(
  builder: (context, child) => ChameleonToastHost(child: child!),
  // ...
);

ChameleonToastMessenger.success('Transfer complete.');
ChameleonToastMessenger.error('Check your connection.');
```

Flag a non-production build (the app owns the flavor → color/label mapping;
this package only draws the ribbon):

```dart
FlavorBanner(
  label: isDev ? 'DEV' : isStaging ? 'STAGING' : null,
  color: isDev ? Colors.red : isStaging ? Colors.blue : null,
  shown: !isProduction,
  child: const AppShell(),
);
```

## Requirements

- Flutter 3.44.0+
- `flutter_bloc`, `flutter_svg`, `google_fonts` (pulled in transitively)

## Contributing

Part of the `chameleon_flutter_toolchain` monorepo. Golden tests live under
`test/` (via `alchemist`) — run `melos run test` from the repo root, or
`flutter test` from this package.

## License

MIT — see [LICENSE](LICENSE).
