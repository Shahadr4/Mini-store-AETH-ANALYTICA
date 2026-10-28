import 'package:flutter/material.dart';

/// Poppins text styles from the design guide, mapped to Material text roles:
///
/// * screen title        -> titleLarge   (22 / 600)
/// * section / card title-> titleMedium  (16 / 600)
/// * body                -> bodyMedium   (14 / 400)
/// * caption / hint      -> bodySmall    (12 / 400)
/// * button              -> labelLarge   (14 / 600)
///
/// The price style (16 / 700, primary colour) is `context.priceStyle`.
class AppTextStyles {
  const AppTextStyles._();

  static const String fontFamily = 'Poppins';

  static TextStyle _style(double size, FontWeight weight, Color color) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.4,
      );

  static TextTheme textTheme(Color color) {
    final screenTitle = _style(22, FontWeight.w600, color);
    final cardTitle = _style(16, FontWeight.w600, color);
    final body = _style(14, FontWeight.w400, color);
    final caption = _style(12, FontWeight.w400, color);
    final button = _style(14, FontWeight.w600, color);
    return TextTheme(
      displayLarge: screenTitle,
      displayMedium: screenTitle,
      displaySmall: screenTitle,
      headlineLarge: screenTitle,
      headlineMedium: screenTitle,
      headlineSmall: screenTitle,
      titleLarge: screenTitle,
      titleMedium: cardTitle,
      titleSmall: button,
      bodyLarge: body,
      bodyMedium: body,
      bodySmall: caption,
      labelLarge: button,
      labelMedium: caption,
      labelSmall: caption,
    );
  }

  static TextStyle price(Color primary) => _style(16, FontWeight.w700, primary);
}
