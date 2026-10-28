import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

/// Star icon (accent colour) with a rating value.
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating, this.iconSize = 16});

  final double rating;
  final double iconSize;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.star_rounded, size: iconSize, color: context.appColors.accent),
      const SizedBox(width: 4),
      Text(rating.toStringAsFixed(1), style: context.captionStyle),
    ],
  );
}
