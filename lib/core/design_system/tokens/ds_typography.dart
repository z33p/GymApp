import 'package:flutter/material.dart';

@immutable
class DsTypography {
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle caption;

  const DsTypography({
    required this.titleLarge,
    required this.titleMedium,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.caption,
  });

  factory DsTypography.regular(
      {required Color color, required Color mutedColor}) {
    return DsTypography(
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color,
      ),
      caption: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: mutedColor,
      ),
    );
  }

  DsTypography lerp(DsTypography? other, double t) {
    if (other == null) return this;
    return DsTypography(
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }
}
