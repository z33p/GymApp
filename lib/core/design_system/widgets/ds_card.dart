import 'package:flutter/material.dart';

import '../ds_theme.dart';

class DsCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const DsCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;

    final cardChild = Padding(
      padding: padding ?? EdgeInsets.all(spacing.m),
      child: child,
    );

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spacing.s),
        side: BorderSide(color: colors.border),
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(spacing.s),
              child: cardChild,
            )
          : cardChild,
    );
  }
}
