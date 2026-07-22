import 'package:flutter/foundation.dart';

@immutable
class DsSpacing {
  final double xxs;
  final double xs;
  final double s;
  final double m;
  final double l;
  final double xl;
  final double xxl;

  const DsSpacing({
    this.xxs = 4.0,
    this.xs = 8.0,
    this.s = 12.0,
    this.m = 16.0,
    this.l = 20.0,
    this.xl = 24.0,
    this.xxl = 32.0,
  });

  DsSpacing lerp(DsSpacing? other, double t) {
    if (other == null) return this;
    return DsSpacing(
      xxs: _lerpDouble(xxs, other.xxs, t),
      xs: _lerpDouble(xs, other.xs, t),
      s: _lerpDouble(s, other.s, t),
      m: _lerpDouble(m, other.m, t),
      l: _lerpDouble(l, other.l, t),
      xl: _lerpDouble(xl, other.xl, t),
      xxl: _lerpDouble(xxl, other.xxl, t),
    );
  }

  static double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
