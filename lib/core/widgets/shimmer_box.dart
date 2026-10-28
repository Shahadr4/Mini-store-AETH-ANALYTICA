import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_spacing.dart';

/// A rounded grey placeholder that shimmers. Building block of skeleton loaders.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.radius = AppSpacing.radius,
  });

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.outline,
      highlightColor: scheme.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: scheme.outline,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
