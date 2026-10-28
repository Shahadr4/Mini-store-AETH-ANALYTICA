import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/rating_badge.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../cart/presentation/provider/cart_provider.dart';
import '../../domain/entities/product.dart';

/// Grid card used on Home, Search and Category screens.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => SoftCard(
    onTap: () => context.push(AppRoutes.productDetails(product.id)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _ImageArea(product: product)),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                prettifySlug(product.category),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.captionStyle,
              ),
              Text(
                product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              _PriceLine(product: product),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(text: formatPrice(product.price), style: context.priceStyle),
        if (product.hasDiscount) ...[
          const TextSpan(text: '  '),
          TextSpan(
            text: formatPrice(product.originalPrice),
            style: context.captionStyle.copyWith(
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

class _ImageArea extends StatelessWidget {
  const _ImageArea({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      ColoredBox(
        color: context.colors.outline.withValues(alpha: 0.3),
        child: AppNetworkImage(url: product.thumbnail, fit: BoxFit.cover),
      ),
      if (product.isOutOfStock)
        ColoredBox(
          color: context.colors.surface.withValues(alpha: 0.7),
          child: Center(
            child: Text(
              'Out of Stock',
              style: context.textStyles.labelLarge!.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
        ),
      if (product.hasDiscount)
        Positioned(
          top: AppSpacing.s,
          left: AppSpacing.s,
          child: DiscountTag(percentage: product.discountPercentage),
        ),
      Positioned(
        left: AppSpacing.s,
        bottom: AppSpacing.s,
        child: _RatingPill(rating: product.rating),
      ),
      if (!product.isOutOfStock)
        Positioned(
          right: 0,
          bottom: 0,
          child: _QuickAddButton(product: product),
        ),
    ],
  );
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surface.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(AppSpacing.s),
      boxShadow: context.softShadow,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      child: RatingBadge(rating: rating, iconSize: 14),
    ),
  );
}

/// Round "+" button: adds one unit; shows the quantity once in the cart.
class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => Selector<CartProvider, int>(
    selector: (_, cart) => cart.quantityOf(product.id),
    builder: (context, quantity, _) => Semantics(
      button: true,
      label: 'Add ${product.title} to cart',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          context.read<CartProvider>().add(product);
        },
        child: SizedBox(
          width: 52,
          height: 52,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.colors.primary,
                shape: BoxShape.circle,
                boxShadow: context.softShadow,
              ),
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: quantity == 0
                    ? Icon(
                        Icons.add_rounded,
                        key: const ValueKey('add'),
                        size: 20,
                        color: context.colors.onPrimary,
                      )
                    : Text(
                        '$quantity',
                        key: ValueKey(quantity),
                        style: context.textStyles.labelLarge!.copyWith(
                          color: context.colors.onPrimary,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Small accent-coloured "-12%" label.
class DiscountTag extends StatelessWidget {
  const DiscountTag({super.key, required this.percentage, this.suffix = ''});

  final double percentage;
  final String suffix;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.tertiary,
      borderRadius: BorderRadius.circular(AppSpacing.s),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        '-${percentage.round()}%$suffix',
        style: context.textStyles.bodySmall!.copyWith(
          color: context.colors.onTertiary,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

/// Skeleton shown while a product card is loading.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => SoftCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(child: ShimmerBox(width: double.infinity, radius: 0)),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ShimmerBox(width: 60, height: 12),
              SizedBox(height: AppSpacing.xs),
              ShimmerBox(width: 110, height: 14),
              SizedBox(height: AppSpacing.s),
              ShimmerBox(width: 70, height: 16),
            ],
          ),
        ),
      ],
    ),
  );
}
