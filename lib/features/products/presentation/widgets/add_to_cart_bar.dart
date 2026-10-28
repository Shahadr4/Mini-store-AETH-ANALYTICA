import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../../cart/presentation/provider/cart_provider.dart';
import '../../domain/entities/product.dart';

/// Sticky bottom bar of the details page: price + "Add to Cart", or quantity
/// controls + "View Cart" when the product is already in the cart.
class AddToCartBar extends StatelessWidget {
  const AddToCartBar({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      boxShadow: context.softShadowUp,
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Selector<CartProvider, int>(
          selector: (_, cart) => cart.quantityOf(product.id),
          builder: (context, quantity, _) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: quantity == 0
                ? _AddRow(key: const ValueKey('add'), product: product)
                : _InCartRow(
                    key: const ValueKey('in-cart'),
                    product: product,
                    quantity: quantity,
                  ),
          ),
        ),
      ),
    ),
  );
}

class _AddRow extends StatelessWidget {
  const _AddRow({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Price', style: context.captionStyle),
          Text(formatPrice(product.price), style: context.priceStyle),
        ],
      ),
      const SizedBox(width: AppSpacing.l),
      Expanded(
        child: AppButton(
          label: product.isOutOfStock ? 'Out of Stock' : 'Add to Cart',
          icon: Icons.shopping_bag_outlined,
          onPressed: product.isOutOfStock
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  context.read<CartProvider>().add(product);
                },
        ),
      ),
    ],
  );
}

class _InCartRow extends StatelessWidget {
  const _InCartRow({super.key, required this.product, required this.quantity});

  final Product product;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Row(
      children: [
        QuantityStepper(
          quantity: quantity,
          onIncrement: () => cart.increment(product.id),
          onDecrement: () => cart.decrement(product.id),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: AppButton(
            label: 'View Cart',
            icon: Icons.shopping_cart_checkout_rounded,
            onPressed: () => context.go(AppRoutes.cart),
          ),
        ),
      ],
    );
  }
}
