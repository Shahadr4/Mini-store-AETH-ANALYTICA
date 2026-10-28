import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../theme/theme_context.dart';

/// Empty state: icon, title, message and an optional action.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 72, color: context.appColors.textSecondary),
          const SizedBox(height: AppSpacing.m),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textStyles.titleMedium,
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: context.secondaryBodyStyle,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.l),
            SizedBox(
              width: 200,
              child: FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
