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
  fixed to Inter), `ChameleonMotion` (durations and curves), and
  [`ChameleonBreakpoints`](lib/src/tokens/chameleon_breakpoints.dart) /
  `ChameleonWindowSizeClass` (phone/tablet/foldable responsive tiers).
- **Theme** — `ChameleonTheme.light`/`.dark` build a `ThemeData` from the
  semantic color tokens (`ChameleonSemanticColors`/`ChameleonSemanticColorsDark`),
  so widgets never hardcode a `Color` or `TextStyle` directly. A
  `ChameleonSemanticColorsExtension` (a `ThemeExtension`) carries the
  handful of roles `chameleon_ui`'s own bespoke components need that
  `ColorScheme` doesn't cover, so those components render correctly under
  both themes too.
- **Components** — `ChameleonToastMessenger`/`ChameleonToastHost` (5 toast
  types with bundled SVG icons), `ChameleonLoadingDialog`,
  [`ChameleonBottomSheet`](lib/src/components/chameleon_bottom_sheet.dart),
  [`ChameleonConfirmationDialog`](lib/src/components/chameleon_confirmation_dialog.dart),
  [`ChameleonEmptyState`](lib/src/components/chameleon_empty_state.dart),
  [`ChameleonSkeleton`](lib/src/components/chameleon_skeleton.dart) (rect/
  circle/text-line shimmering placeholders), the loader group
  (`ChameleonMark`, `ChameleonSpinner`, `ChameleonLoaderCubit`),
  `FlavorBanner`, `ActivityDetector` (idle/foreground/background detection
  via `Listener`, not `GestureDetector`, so it never steals gestures from
  the gesture arena), `GlobalGlassSurface`/`AuthGlassSurface`,
  `DismissKeyboard`.
- **`StringX` extension** — `'Welcome back'.asHeading2()`, `.asBody1()`,
  `.toPrimaryButton(onPressed: ...)`, and one method per typography ramp
  entry, so call sites never inline a font size or weight.

## Usage

Apply the theme once, at boot — `darkTheme`/`themeMode: ThemeMode.system`
gets you system dark mode with no other wiring:

```dart
import 'package:chameleon_ui/chameleon_ui.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ChameleonTheme.light,
      darkTheme: ChameleonTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    ),
  );
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

`show`/`error`/`success` also take optional `duration` (how long the toast
stays up — already existed), `backgroundColor`/`foregroundColor` (override
the surface and text colors; the description uses `foregroundColor` at 70%
opacity), and `transitionDuration`/`transitionCurve` (override the
entrance/exit animation's speed and easing, otherwise
`ChameleonMotion.fast`/`emphasizedDecelerate`). All default to today's
fixed look, so existing calls are unaffected:

```dart
ChameleonToastMessenger.show(
  title: 'Reward unlocked',
  description: 'You earned 500 points.',
  backgroundColor: ChameleonColors.yellow900,
  foregroundColor: ChameleonColors.yellow100,
  transitionDuration: const Duration(milliseconds: 350),
  transitionCurve: Curves.easeOutBack,
);
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

Branch a layout on the current window size class — phone, tablet, or
foldable (a folded foldable's cover screen reads as `phone`; an unfolded
inner display reads as `tablet`/`foldable` depending on orientation, no
special-casing needed):

```dart
switch (ChameleonBreakpoints.of(context)) {
  ChameleonWindowSizeClass.phone => const SingleColumnLayout(),
  ChameleonWindowSizeClass.tablet => const TwoColumnLayout(),
  ChameleonWindowSizeClass.foldable => const ThreeColumnLayout(),
}
```

Ask for confirmation before a destructive action — `show()` resolves to a
plain `bool`, never `null`, even if the user dismisses via the barrier or
back gesture:

```dart
final confirmed = await ChameleonConfirmationDialog.show(
  context,
  title: 'Delete account?',
  message: 'This cannot be undone.',
  confirmLabel: 'Delete',
  isDestructive: true,
);
if (confirmed) { ... }
```

Open a bottom sheet — content shifts for the keyboard and a gesture-nav
safe area automatically:

```dart
final selected = await ChameleonBottomSheet.show<String>(
  context,
  child: const FilterOptions(),
);
```

Show an empty state (composes directly as a sealed bloc state's `builder`):

```dart
ChameleonEmptyState(
  title: 'No transactions yet',
  description: 'Your activity will show up here.',
  actionLabel: 'Refresh',
  onAction: () => context.read<TransactionsCubit>().refresh(),
);
```

Placeholder content that's still loading, in three shapes:

```dart
ChameleonSkeleton.circle(size: 40),               // an avatar
ChameleonSkeleton.textLine(width: 120),           // a line of text
ChameleonSkeleton.rect(width: 200, height: 80),   // a card/image
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
