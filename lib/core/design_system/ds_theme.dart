import 'package:flutter/material.dart';

import 'tokens/ds_colors.dart';
import 'tokens/ds_spacing.dart';
import 'tokens/ds_typography.dart';

@immutable
class DsTheme extends ThemeExtension<DsTheme> {
  final DsColors colors;
  final DsSpacing spacing;
  final DsTypography typography;

  const DsTheme({
    required this.colors,
    required this.spacing,
    required this.typography,
  });

  factory DsTheme.light() {
    final colors = DsColors.light();
    return DsTheme(
      colors: colors,
      spacing: const DsSpacing(),
      typography: DsTypography.regular(
        color: colors.onBackground,
        mutedColor: colors.textMuted,
      ),
    );
  }

  factory DsTheme.dark() {
    final colors = DsColors.dark();
    return DsTheme(
      colors: colors,
      spacing: const DsSpacing(),
      typography: DsTypography.regular(
        color: colors.onBackground,
        mutedColor: colors.textMuted,
      ),
    );
  }

  @override
  DsTheme copyWith({
    DsColors? colors,
    DsSpacing? spacing,
    DsTypography? typography,
  }) {
    return DsTheme(
      colors: colors ?? this.colors,
      spacing: spacing ?? this.spacing,
      typography: typography ?? this.typography,
    );
  }

  @override
  DsTheme lerp(ThemeExtension<DsTheme>? other, double t) {
    if (other is! DsTheme) return this;
    return DsTheme(
      colors: colors.lerp(other.colors, t),
      spacing: spacing.lerp(other.spacing, t),
      typography: typography.lerp(other.typography, t),
    );
  }
}

extension DsThemeContextExtension on BuildContext {
  DsTheme get dsTheme {
    final theme = Theme.of(this).extension<DsTheme>();
    assert(
      theme != null,
      'DsTheme não foi encontrado no ThemeData. Verifique se adicionou extensions: [DsTheme.light()] no seu MaterialApp theme.',
    );
    return theme ?? DsTheme.light();
  }

  DsColors get dsColors => dsTheme.colors;
  DsSpacing get dsSpacing => dsTheme.spacing;
  DsTypography get dsTypography => dsTheme.typography;
}
