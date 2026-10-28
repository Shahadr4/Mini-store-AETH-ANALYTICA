import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../domain/entities/product_sort.dart';
import '../provider/searchable_products_provider.dart';

extension ProductSortLabel on ProductSort {
  String get label => switch (this) {
    ProductSort.none => 'Default',
    ProductSort.priceLowToHigh => 'Price: Low to High',
    ProductSort.priceHighToLow => 'Price: High to Low',
    ProductSort.topRated => 'Top Rated',
  };
}

/// Sort / filter button: opens a menu with the [ProductSort] options of the
/// [SearchableProductsProvider] [T] above it. A dot shows when a sort is on.
class ProductSortButton<T extends SearchableProductsProvider>
    extends StatelessWidget {
  const ProductSortButton({super.key, this.bordered = false});

  /// Adds a border, for use on a plain background instead of the header.
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<T>();
    return Selector<T, ProductSort>(
      selector: (_, products) => products.sort,
      builder: (context, sort, _) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: bordered ? Border.all(color: context.appColors.border) : null,
        ),
        child: PopupMenuButton<ProductSort>(
          tooltip: 'Sort',
          initialValue: sort,
          onSelected: provider.setSort,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: Badge(
            isLabelVisible: sort != ProductSort.none,
            smallSize: 8,
            child: Icon(Icons.tune_rounded, color: context.colors.primary),
          ),
          itemBuilder: (_) => [
            for (final option in ProductSort.values)
              CheckedPopupMenuItem(
                value: option,
                checked: option == sort,
                child: Text(option.label),
              ),
          ],
        ),
      ),
    );
  }
}
