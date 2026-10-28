import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/rating_badge.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../domain/entities/product.dart';
import '../provider/product_details_provider.dart';
import '../widgets/add_to_cart_bar.dart';
import '../widgets/image_carousel.dart';
import '../widgets/product_card.dart';
import '../widgets/review_tile.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => sl<ProductDetailsProvider>()..load(productId),
    child: _DetailsView(productId: productId),
  );
}

class _DetailsView extends StatelessWidget {
  const _DetailsView({required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context) => Consumer<ProductDetailsProvider>(
    builder: (context, details, _) {
      final product = details.product;
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          toolbarHeight: 64,
          titleSpacing: AppSpacing.screenPadding,
          title: Align(
            alignment: Alignment.centerLeft,
            child: _RoundButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back',
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
        body: switch (details.status) {
          DetailsStatus.loading => const _DetailsSkeleton(),
          DetailsStatus.failure => SafeArea(
            child: ErrorView(
              message: details.errorMessage ?? 'Could not load the product.',
              onRetry: () =>
                  context.read<ProductDetailsProvider>().load(productId),
            ),
          ),
          DetailsStatus.success => _DetailsContent(product: product!),
        },
        bottomNavigationBar: product == null
            ? null
            : AddToCartBar(product: product),
      );
    },
  );
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surface,
      shape: BoxShape.circle,
      boxShadow: context.softShadow,
    ),
    child: IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      icon: Icon(icon, color: context.colors.onSurface),
    ),
  );
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final images = product.images.isNotEmpty
        ? product.images
        : [product.thumbnail];
    final topInset = MediaQuery.paddingOf(context).top + 64;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ImageCarousel(images: images, topInset: topInset),
        // The panel is pulled up so its rounded top overlaps the carousel.
        Transform.translate(
          offset: const Offset(0, -ImageCarousel.overlap),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.l,
                AppSpacing.screenPadding,
                AppSpacing.l,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetaRow(product: product),
                  const SizedBox(height: AppSpacing.m),
                  Text(product.title, style: context.textStyles.titleLarge),
                  if (product.brand != null)
                    Text(
                      'by ${product.brand}',
                      style: context.secondaryBodyStyle,
                    ),
                  const SizedBox(height: AppSpacing.m),
                  _PriceRow(product: product),
                  const SizedBox(height: AppSpacing.l),
                  Text('Description', style: context.textStyles.titleMedium),
                  const SizedBox(height: AppSpacing.s),
                  Text(product.description, style: context.secondaryBodyStyle),
                  const SizedBox(height: AppSpacing.l),
                  _Reviews(product: product),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _CategoryChip(label: prettifySlug(product.category)),
      const SizedBox(width: AppSpacing.s),
      RatingBadge(rating: product.rating, iconSize: 18),
      const Spacer(),
      _StockLabel(product: product),
    ],
  );
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSpacing.s),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        label,
        style: context.textStyles.bodySmall!.copyWith(
          color: context.colors.primary,
        ),
      ),
    ),
  );
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.s,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(
        formatPrice(product.price),
        style: context.priceStyle.copyWith(fontSize: 22),
      ),
      if (product.hasDiscount) ...[
        Text(
          formatPrice(product.originalPrice),
          style: context.secondaryBodyStyle.copyWith(
            decoration: TextDecoration.lineThrough,
          ),
        ),
        DiscountTag(percentage: product.discountPercentage, suffix: ' OFF'),
      ],
    ],
  );
}

class _StockLabel extends StatelessWidget {
  const _StockLabel({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = product.isOutOfStock
        ? (context.colors.error, Icons.cancel_outlined)
        : product.availabilityStatus.toLowerCase() == 'low stock'
        ? (context.appColors.accent, Icons.warning_amber_rounded)
        : (context.appColors.success, Icons.check_circle_outline_rounded);
    final label = product.isOutOfStock
        ? 'Out of Stock'
        : product.availabilityStatus.toLowerCase() == 'low stock'
        ? 'Only ${product.stock} left'
        : 'In Stock';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.s),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: context.textStyles.bodySmall!.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Reviews extends StatelessWidget {
  const _Reviews({required this.product});

  final Product product;

  double get _average => product.reviews.isEmpty
      ? 0
      : product.reviews.fold<int>(0, (sum, r) => sum + r.rating) /
            product.reviews.length;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Customer Reviews',
              style: context.textStyles.titleMedium,
            ),
          ),
          if (product.reviews.isNotEmpty) ...[
            RatingBadge(rating: _average, iconSize: 18),
            Text('  (${product.reviews.length})', style: context.captionStyle),
          ],
        ],
      ),
      const SizedBox(height: AppSpacing.s),
      if (product.reviews.isEmpty)
        Text('No reviews yet.', style: context.secondaryBodyStyle)
      else
        for (final review in product.reviews) ...[
          ReviewTile(review: review),
          const SizedBox(height: AppSpacing.s),
        ],
    ],
  );
}

class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) => const SingleChildScrollView(
    physics: NeverScrollableScrollPhysics(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(width: double.infinity, height: 300, radius: 0),
        Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 240, height: 24),
              SizedBox(height: AppSpacing.m),
              ShimmerBox(width: 160, height: 16),
              SizedBox(height: AppSpacing.m),
              ShimmerBox(width: 120, height: 24),
              SizedBox(height: AppSpacing.l),
              ShimmerBox(width: double.infinity, height: 14),
              SizedBox(height: AppSpacing.s),
              ShimmerBox(width: double.infinity, height: 14),
              SizedBox(height: AppSpacing.s),
              ShimmerBox(width: 200, height: 14),
            ],
          ),
        ),
      ],
    ),
  );
}
