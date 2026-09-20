/// Chameleon spacing scale.
///
/// Use these named constants for padding, margins, and gaps so layout
/// rhythm stays consistent with the design system.
abstract final class ChameleonSpacing {
  /// 0
  static const double zero = 0;

  /// 1
  static const double px = 1;

  /// 2
  static const double xxs = 2;

  /// 4
  static const double xs2 = 4;

  /// 8
  static const double xs = 8;

  /// 12
  static const double sm = 12;

  /// 16 — base unit.
  static const double base = 16;

  /// 20
  static const double md = 20;

  /// 24
  static const double lg = 24;

  /// 28
  static const double xl = 28;

  /// 32
  static const double xl2 = 32;

  /// 40
  static const double xl3 = 40;

  /// 48
  static const double xl4 = 48;

  /// 60
  static const double xl5 = 60;

  /// 72
  static const double xl6 = 72;
}

/// Chameleon corner-radius scale.
///
/// [full] produces a pill/circle shape when applied to any element.
abstract final class ChameleonRadius {
  /// 0
  static const double none = 0;

  /// 2
  static const double sm = 2;

  /// 4
  static const double md = 4;

  /// 8
  static const double lg = 8;

  /// 12
  static const double xl = 12;

  /// 16
  static const double xl2 = 16;

  /// 24
  static const double xl3 = 24;

  /// 32
  static const double xl4 = 32;

  /// 48
  static const double xl5 = 48;

  /// 999 — fully rounded (pill / circle).
  static const double full = 999;
}
