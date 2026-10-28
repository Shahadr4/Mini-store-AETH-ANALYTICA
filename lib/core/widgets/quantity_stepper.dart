import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../theme/theme_context.dart';

/// "- 2 +" control with 44 px tap targets.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      border: Border.all(color: context.appColors.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Decrease quantity',
          onPressed: onDecrement,
          icon: Icon(
            quantity <= 1 ? Icons.delete_outline_rounded : Icons.remove,
            size: 20,
          ),
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: context.textStyles.titleMedium,
          ),
        ),
        IconButton(
          tooltip: 'Increase quantity',
          onPressed: onIncrement,
          icon: const Icon(Icons.add, size: 20),
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        ),
      ],
    ),
  );
}
