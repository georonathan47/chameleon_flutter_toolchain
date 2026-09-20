import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'chameleon_mark.dart';

/// Chameleon's busy indicator: [ChameleonMark] on a continuous, stylized
/// rotation with a subtle scale pulse.
///
/// A chameleon does not literally spin in nature — this is a deliberately
/// abstract, tasteful loop rather than a literal animation, playing the same
/// role the branded spinner in the source design system played: something to
/// look at while the app is waiting on work.
class ChameleonSpinner extends StatefulWidget {
  const ChameleonSpinner({this.size = 48, this.color, super.key});

  /// Side of the (square) box the mark is painted into.
  final double size;

  /// Forwarded to [ChameleonMark.color].
  final Color? color;

  /// One full rotation.
  static const Duration cycle = Duration(milliseconds: 1600);

  @override
  State<ChameleonSpinner> createState() => _ChameleonSpinnerState();
}

class _ChameleonSpinnerState extends State<ChameleonSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: ChameleonSpinner.cycle,
    );
    unawaited(_controller.repeat());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: ChameleonMark(size: widget.size, color: widget.color),
      builder: (context, child) {
        final turns = _controller.value;
        // Two gentle pulses per revolution, so the mark breathes as it spins
        // rather than just rotating flatly in place.
        final pulse = 1 + 0.06 * math.sin(turns * 2 * math.pi * 2);
        return Transform.rotate(
          angle: turns * 2 * math.pi,
          child: Transform.scale(scale: pulse, child: child),
        );
      },
    );
  }
}
