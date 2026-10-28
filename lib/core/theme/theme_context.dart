import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Shortcuts so widgets read colours and text styles from the theme only.
extension ThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;

  /// Caption / hint text (12 / 400, secondary colour).
  TextStyle get captionStyle =>
      textStyles.bodySmall!.copyWith(color: appColors.textSecondary);

  /// Body text in secondary colour.
  TextStyle get secondaryBodyStyle =>
      textStyles.bodyMedium!.copyWith(color: appColors.textSecondary);

  /// Soft elevation used by cards and bars.
  List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Theme.of(this).shadowColor.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  /// Same shadow, cast upwards (bottom bars).
  List<BoxShadow> get softShadowUp => [
    BoxShadow(
      color: Theme.of(this).shadowColor.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, -4),
    ),
  ];

  /// Price (16 / 700, primary colour).
  TextStyle get priceStyle => AppTextStyles.price(colors.primary);
}
