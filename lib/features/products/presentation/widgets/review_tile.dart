import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../domain/entities/review.dart';

class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key, required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final name = review.reviewerName;
    return SoftCard(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: context.colors.primary.withValues(alpha: 0.12),
                child: Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: context.textStyles.labelLarge!.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.labelLarge,
                    ),
                    StarRow(rating: review.rating),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(review.comment, style: context.secondaryBodyStyle),
        ],
      ),
    );
  }
}

/// Five stars, [rating] of them filled (accent colour).
class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.rating, this.size = 16});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(
      5,
      (i) => Icon(
        i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
        size: size,
        color: i < rating
            ? context.appColors.accent
            : context.appColors.textSecondary,
      ),
    ),
  );
}
