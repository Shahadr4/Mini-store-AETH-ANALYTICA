import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../provider/cart_provider.dart';
import '../widgets/cart_item_tile.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late final CartProvider _cart;

  @override
  void initState() {
    super.initState();
    _cart = context.read<CartProvider>();
    _cart.addListener(_showError);
  }

  @override
  void dispose() {
    _cart.removeListener(_showError);
    super.dispose();
  }

  /// Shows the error message (if there is one) as a snackbar.
  void _showError() {
    final message = _cart.errorMessage;
    if (message == null) return;
    _cart.clearError();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Consumer<CartProvider>(
    builder: (context, cart, _) => Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('My Cart')),
          body: _body(context, cart),
          bottomNavigationBar: cart.isEmpty ? null : _CartSummary(cart: cart),
        ),
        if (cart.isPlacingOrder) const _PlacingOrderOverlay(),
      ],
    ),
  );

  Widget _body(BuildContext context, CartProvider cart) {
    if (cart.isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
        itemBuilder: (_, _) =>
            const ShimmerBox(width: double.infinity, height: 104),
      );
    }
    if (cart.isEmpty) {
      return EmptyView(
        icon: Icons.shopping_cart_outlined,
        title: 'Your cart is empty',
        message: 'Looks like you have not added anything yet.',
        actionLabel: 'Start Shopping',
        onAction: () => context.go(AppRoutes.home),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: cart.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
      itemBuilder: (_, index) {
        final item = cart.items[index];
        return CartItemTile(
          key: ValueKey(item.productId),
          item: item,
          onIncrement: () => cart.increment(item.productId),
          onDecrement: () => cart.decrement(item.productId),
          onRemove: () => cart.remove(item.productId),
        );
      },
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.cart});

  final CartProvider cart;

  Future<void> _placeOrder(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Place order?',
      message:
          'You are about to order ${cart.totalQuantity} item(s) for ${formatPrice(cart.totalPrice)}.',
      confirmLabel: 'Place Order',
    );
    if (!confirmed || !context.mounted) return;
    final order = await context.read<CartProvider>().placeOrder();
    if (order != null && context.mounted) {
      context.go(AppRoutes.orderSuccess, extra: order);
    }
  }

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SummaryRow(label: 'Total items', value: '${cart.totalQuantity}'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s),
              child: Divider(),
            ),
            _SummaryRow(
              label: 'Total price',
              value: formatPrice(cart.totalPrice),
              emphasized: true,
            ),
            const SizedBox(height: AppSpacing.m),
            AppButton(
              label: 'Place Order',
              onPressed: () => _placeOrder(context),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: context.secondaryBodyStyle),
      Text(
        value,
        style: emphasized ? context.priceStyle : context.textStyles.labelLarge,
      ),
    ],
  );
}

class _PlacingOrderOverlay extends StatelessWidget {
  const _PlacingOrderOverlay();

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Material(
      color: Colors.black54,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.m),
                Text(
                  'Placing your order...',
                  style: context.textStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
