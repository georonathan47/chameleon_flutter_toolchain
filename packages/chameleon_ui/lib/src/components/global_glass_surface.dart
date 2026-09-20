import 'package:flutter/material.dart';

import 'glass_surface.dart';

/// A [GlobalGlassSurface] preconfigured for auth-flow choice cards and
/// similar surfaces — the common case where only the fill, radius, and tap
/// handler vary.
class AuthGlassSurface extends StatelessWidget {
  const AuthGlassSurface({
    required this.fillColor,
    required this.borderRadius,
    required this.child,
    this.blurSigma = 10,
    this.onTap,
    super.key,
  });

  final Color fillColor;
  final BorderRadius borderRadius;
  final Widget child;
  final double blurSigma;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlobalGlassSurface(
      fillColor: fillColor,
      borderRadius: borderRadius,
      blurSigma: blurSigma,
      onTap: onTap,
      child: child,
    );
  }
}
