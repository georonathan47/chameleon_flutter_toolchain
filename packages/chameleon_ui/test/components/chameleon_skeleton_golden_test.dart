import 'package:alchemist/alchemist.dart';
import 'package:chameleon_ui/chameleon_ui.dart';
import 'package:flutter/material.dart';

void main() {
  goldenTest(
    'ChameleonSkeleton renders each shape',
    fileName: 'chameleon_skeleton_gallery',
    // The shimmer's AnimationController repeats indefinitely — alchemist's
    // default pumpBeforeTest is pumpAndSettle, which would hang forever
    // waiting for it to stop. pumpOnce captures a single, deterministic
    // frame instead.
    pumpBeforeTest: pumpOnce,
    builder: () => Theme(
      data: ChameleonTheme.light,
      child: Material(
        color: Colors.transparent,
        child: GoldenTestGroup(
          columns: 3,
          children: [
            GoldenTestScenario(
              name: 'rect',
              child: const Padding(
                padding: EdgeInsets.all(ChameleonSpacing.base),
                child: ChameleonSkeleton.rect(width: 120, height: 80),
              ),
            ),
            GoldenTestScenario(
              name: 'circle',
              child: const Padding(
                padding: EdgeInsets.all(ChameleonSpacing.base),
                child: ChameleonSkeleton.circle(size: 56),
              ),
            ),
            GoldenTestScenario(
              name: 'text line',
              child: const Padding(
                padding: EdgeInsets.all(ChameleonSpacing.base),
                child: ChameleonSkeleton.textLine(width: 140),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
