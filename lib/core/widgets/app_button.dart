import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';

/// Full-width 48 px button. Shows a spinner and ignores taps while [isLoading].
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.destructive = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;

  /// Uses the error colour (outlined buttons only), e.g. for Logout.
  final bool destructive;
  final IconData? icon;

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: double.infinity, child: _buildButton(context));

  Widget _buildButton(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null && !isLoading;
    final foreground = outlined
        ? (destructive ? scheme.error : scheme.primary)
        : scheme.onPrimary;

    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.s),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    if (outlined) {
      return OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: destructive
            ? OutlinedButton.styleFrom(
                foregroundColor: scheme.error,
                side: BorderSide(color: scheme.error),
              )
            : null,
        child: child,
      );
    }
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      // While loading the button is disabled but keeps the primary look.
      style: isLoading
          ? FilledButton.styleFrom(
              disabledBackgroundColor: scheme.primary,
              disabledForegroundColor: scheme.onPrimary,
            )
          : null,
      child: child,
    );
  }
}
