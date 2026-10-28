import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../theme/theme_context.dart';

/// Friendly error message with a Retry button.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 64,
            color: context.appColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.m),
          Text('Oops!', style: context.textStyles.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.secondaryBodyStyle,
          ),
          const SizedBox(height: AppSpacing.l),
          SizedBox(
            width: 160,
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Retry'),
            ),
          ),
        ],
      ),
    ),
  );
}
