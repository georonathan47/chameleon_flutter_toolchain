## 0.4.0

- Added `ChameleonBottomSheet`: a themed `showModalBottomSheet` wrapper —
  rounded top corners, a drag handle, and padding that shifts for the
  keyboard and a gesture-nav safe area automatically.
- Added `ChameleonConfirmationDialog`: a themed "are you sure?" dialog.
  `show()` always resolves to a plain, non-nullable `bool` — a barrier tap
  or back gesture counts as cancelling, same as tapping the cancel button.
  `isDestructive` recolors the confirm button to the error color.
- Added `ChameleonEmptyState`: an icon/title/description/action placeholder
  for an empty list or collection screen, composable directly as a sealed
  bloc state's `builder`.
- Added `ChameleonSkeleton`: a self-contained shimmering placeholder (no
  third-party shimmer package) in three shapes — `.rect`, `.circle`,
  `.textLine`.
- `ChameleonMotion` gained `shimmerSweep` (1200ms), `ChameleonSkeleton`'s
  sweep cycle.

## 0.3.0

- Added `ChameleonBreakpoints`/`ChameleonWindowSizeClass`: a three-tier
  responsive breakpoint system (phone/tablet/foldable) with a
  `ChameleonBreakpoints.of(context)` helper. Foldables aren't a separate
  tier — a folded cover screen lands in `phone`, an unfolded inner display
  lands in `tablet`/`foldable` by orientation, purely from measured width.

## 0.2.0

- `ChameleonToast`/`ChameleonToastMessenger.show`/`error`/`success` gained
  optional `backgroundColor`, `foregroundColor`, `transitionDuration`, and
  `transitionCurve` — the surface color, text color, and entrance/exit
  animation speed/easing are all overridable now, defaulting to today's
  fixed look. Visible `duration` was already a parameter.

## 0.1.0

- Initial release: design tokens (`ChameleonColors`, `ChameleonSemanticColors`,
  `ChameleonSpacing`, `ChameleonRadius`, `ChameleonTypography`,
  `ChameleonMotion`), `ChameleonTheme`, and shared components (toast, loading
  dialog, `ChameleonMark`/`ChameleonSpinner`, `FlavorBanner`,
  `ActivityDetector`, glass surfaces, `StringX` extension).
- No brand assets: typography is fixed to a single typeface (Inter) instead
  of a flavor-driven typeface swap, and the loading indicator is an original
  chameleon mark instead of a bank logo.
