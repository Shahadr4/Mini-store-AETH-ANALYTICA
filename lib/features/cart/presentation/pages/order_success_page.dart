import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../domain/entities/order_summary.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key, required this.order});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) => PopScope(
    // Back goes to Home, never back into the (now empty) cart.
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) context.go(AppRoutes.home);
    },
    child: Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _AnimatedCheck(),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    'Order placed!',
                    textAlign: TextAlign.center,
                    style: context.textStyles.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Thank you for shopping with Mini Store.',
                    textAlign: TextAlign.center,
                    style: context.secondaryBodyStyle,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  SoftCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Column(
                        children: [
                          _DetailRow(
                            label: 'Order number',
                            value: order.orderNumber,
                          ),
                          const Divider(height: AppSpacing.l),
                          _DetailRow(
                            label: 'Items',
                            value: '${order.itemCount}',
                          ),
                          const Divider(height: AppSpacing.l),
                          _DetailRow(
                            label: 'Total paid',
                            value: formatPrice(order.totalPaid),
                            highlight: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  AppButton(
                    label: 'Continue Shopping',
                    onPressed: () => context.go(AppRoutes.home),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: context.secondaryBodyStyle),
      Text(
        value,
        style: highlight ? context.priceStyle : context.textStyles.labelLarge,
      ),
    ],
  );
}

/// Success icon that pops in with a soft halo.
class _AnimatedCheck extends StatelessWidget {
  const _AnimatedCheck();

  @override
  Widget build(BuildContext context) {
    final success = context.appColors.success;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.elasticOut,
      builder: (context, t, child) => Transform.scale(scale: t, child: child),
      child: Center(
        child: Container(
          width: 144,
          height: 144,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: success.withValues(alpha: 0.12),
          ),
          child: Center(
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: success,
                boxShadow: [
                  BoxShadow(
                    color: success.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                size: 64,
                color: context.colors.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
