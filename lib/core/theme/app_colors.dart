import 'package:flutter/material.dart';

/// The only place colours are defined.
class AppPalette {
  const AppPalette({
    required this.brightness,
    required this.primary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.success,
    required this.error,
  });

  final Brightness brightness;
  final Color primary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color success;
  final Color error;

  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Palette required by the task.
  static const light = AppPalette(
    brightness: Brightness.light,
    primary: Color(0xFF2563EB),
    accent: Color(0xFFF59E0B),
    background: Color(0xFFF9FAFB),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1F2937),
    textSecondary: Color(0xFF6B7280),
    border: Color(0xFFE5E7EB),
    success: Color(0xFF16A34A),
    error: Color(0xFFDC2626),
  );

  /// Dark variant of the same palette (bonus feature).
  static const dark = AppPalette(
    brightness: Brightness.dark,
    primary: Color(0xFF2563EB),
    accent: Color(0xFFF59E0B),
    background: Color(0xFF111827),
    surface: Color(0xFF1F2937),
    textPrimary: Color(0xFFF9FAFB),
    textSecondary: Color(0xFF9CA3AF),
    border: Color(0xFF374151),
    success: Color(0xFF16A34A),
    error: Color(0xFFDC2626),
  );
}

/// Palette roles that have no slot in [ColorScheme].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.accent,
    required this.textSecondary,
    required this.border,
    required this.success,
  });

  final Color accent;
  final Color textSecondary;
  final Color border;
  final Color success;

  factory AppColors.fromPalette(AppPalette p) => AppColors(
    accent: p.accent,
    textSecondary: p.textSecondary,
    border: p.border,
    success: p.success,
  );

  @override
  AppColors copyWith({
    Color? accent,
    Color? textSecondary,
    Color? border,
    Color? success,
  }) => AppColors(
    accent: accent ?? this.accent,
    textSecondary: textSecondary ?? this.textSecondary,
    border: border ?? this.border,
    success: success ?? this.success,
  );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      accent: Color.lerp(accent, other.accent, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}
