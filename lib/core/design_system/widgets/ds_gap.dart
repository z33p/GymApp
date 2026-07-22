import 'package:flutter/material.dart';

import '../ds_theme.dart';

class DsGap extends StatelessWidget {
  final double size;
  final bool isHorizontal;

  const DsGap.vertical(this.size, {super.key}) : isHorizontal = false;
  const DsGap.horizontal(this.size, {super.key}) : isHorizontal = true;

  factory DsGap.xxs(BuildContext context, {bool horizontal = false}) {
    final size = context.dsSpacing.xxs;
    return horizontal ? DsGap.horizontal(size) : DsGap.vertical(size);
  }

  factory DsGap.xs(BuildContext context, {bool horizontal = false}) {
    final size = context.dsSpacing.xs;
    return horizontal ? DsGap.horizontal(size) : DsGap.vertical(size);
  }

  factory DsGap.s(BuildContext context, {bool horizontal = false}) {
    final size = context.dsSpacing.s;
    return horizontal ? DsGap.horizontal(size) : DsGap.vertical(size);
  }

  factory DsGap.m(BuildContext context, {bool horizontal = false}) {
    final size = context.dsSpacing.m;
    return horizontal ? DsGap.horizontal(size) : DsGap.vertical(size);
  }

  factory DsGap.l(BuildContext context, {bool horizontal = false}) {
    final size = context.dsSpacing.l;
    return horizontal ? DsGap.horizontal(size) : DsGap.vertical(size);
  }

  factory DsGap.xl(BuildContext context, {bool horizontal = false}) {
    final size = context.dsSpacing.xl;
    return horizontal ? DsGap.horizontal(size) : DsGap.vertical(size);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isHorizontal ? size : 0,
      height: isHorizontal ? 0 : size,
    );
  }
}
