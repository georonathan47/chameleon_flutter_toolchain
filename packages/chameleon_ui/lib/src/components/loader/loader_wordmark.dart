import 'dart:async';

import 'package:flutter/material.dart';

import '../../tokens/chameleon_motion.dart';

/// A wordmark, revealed by sliding up out of a clip.
///
/// Motion spec: the text starts fully below a
/// [ChameleonMotion.wordmarkClipHeight] window with `overflow: hidden`, so
/// nothing shows at rest. It then travels [ChameleonMotion.wordmarkRise] px
/// upward on a bouncy curve to sit in place — typically beneath a loader
/// mark, following it up after [delay].
///
/// The clip is what makes the reveal read as the text emerging from behind
/// something else rather than simply sliding on screen, so the [ClipRect] is
/// load-bearing and not decorative.
///
/// Stateful only to own its [AnimationController]; the controller drives
/// rebuilds through [AnimatedBuilder], so there is no `setState` here.
class LoaderWordmark extends StatefulWidget {
  const LoaderWordmark({
    required this.text,
    this.style,
    this.delay = ChameleonMotion.wordmarkDelay,
    super.key,
  });

  final String text;
  final TextStyle? style;

  /// Held before the slide begins, so the wordmark follows a preceding mark's
  /// build-in instead of competing with it.
  final Duration delay;

  @override
  State<LoaderWordmark> createState() => _LoaderWordmarkState();
}

class _LoaderWordmarkState extends State<LoaderWordmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slide;
  late final Animation<double> _rise;

  @override
  void initState() {
    super.initState();
    _slide = AnimationController(
      vsync: this,
      duration: ChameleonMotion.wordmarkSlide,
    );

    // 1 → 0 so the text begins a full rise below its resting place and
    // arrives at zero offset. The bouncy curve overshoots slightly past the
    // target before settling, which is the intended "spring into place".
    _rise = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _slide, curve: ChameleonMotion.bouncyDecelerate),
    );

    unawaited(_startAfterDelay());
  }

  /// Waits out [LoaderWordmark.delay], then plays the slide.
  ///
  /// Guarded on `mounted` because the loader redirects on a timer — the screen
  /// can be torn down before the delay elapses.
  Future<void> _startAfterDelay() async {
    await Future<void>.delayed(widget.delay);
    if (!mounted) return;
    await _slide.forward();
  }

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ChameleonMotion.wordmarkClipHeight,
      // Clips the text out of view at rest and crops the bouncy curve's
      // overshoot, so the reveal never spills past the window.
      child: ClipRect(
        // Anchored to the bottom edge, not centred: the spec hides the text
        // entirely at rest, and only a bottom anchor puts it fully below the
        // window before the rise. Centring it would leave the upper half
        // showing through, because the rise is shorter than half the clip.
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedBuilder(
            animation: _rise,
            // Built once and reused every frame: only the offset changes, so
            // rebuilding the glyphs each tick would be wasted work.
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: widget.style,
            ),
            builder: (context, child) => Transform.translate(
              // Starts a full rise below its resting place and travels up to
              // zero; the bouncy curve briefly carries it past, and the clip
              // crops that overshoot.
              offset: Offset(0, _rise.value * ChameleonMotion.wordmarkRise),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
