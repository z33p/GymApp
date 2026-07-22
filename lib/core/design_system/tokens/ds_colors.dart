import 'package:flutter/material.dart';

@immutable
class DsColors {
  final Color primary;
  final Color onPrimary;
  final Color surface;
  final Color onSurface;
  final Color background;
  final Color onBackground;
  final Color error;
  final Color onError;
  final Color textMuted;
  final Color border;

  const DsColors({
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.onSurface,
    required this.background,
    required this.onBackground,
    required this.error,
    required this.onError,
    required this.textMuted,
    required this.border,
  });

  factory DsColors.light() {
    return const DsColors(
      primary: Color(0xFF2563EB),
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF0F172A),
      background: Color(0xFFF8FAFC),
      onBackground: Color(0xFF0F172A),
      error: Color(0xFFDC2626),
      onError: Colors.white,
      textMuted: Color(0xFF64748B),
      border: Color(0xFFE2E8F0),
    );
  }

  factory DsColors.dark() {
    return const DsColors(
      primary: Color(0xFF3B82F6),
      onPrimary: Colors.white,
      surface: Color(0xFF1E293B),
      onSurface: Color(0xFFF8FAFC),
      background: Color(0xFF0F172A),
      onBackground: Color(0xFFF8FAFC),
      error: Color(0xFFEF4444),
      onError: Colors.white,
      textMuted: Color(0xFF94A3B8),
      border: Color(0xFF334155),
    );
  }

  DsColors lerp(DsColors? other, double t) {
    if (other == null) return this;
    return DsColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      background: Color.lerp(background, other.background, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}
