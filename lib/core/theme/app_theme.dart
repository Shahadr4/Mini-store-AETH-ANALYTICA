import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(AppPalette.light);
  static ThemeData get dark => _build(AppPalette.dark);

  static ThemeData _build(AppPalette p) {
    final scheme = ColorScheme(
      brightness: p.brightness,
      primary: p.primary,
      onPrimary: AppPalette.onPrimary,
      secondary: p.primary,
      onSecondary: AppPalette.onPrimary,
      tertiary: p.accent,
      onTertiary: AppPalette.light.textPrimary,
      error: p.error,
      onError: AppPalette.onPrimary,
      surface: p.surface,
      onSurface: p.textPrimary,
      onSurfaceVariant: p.textSecondary,
      outline: p.border,
      outlineVariant: p.border,
    );
    final textTheme = AppTextStyles.textTheme(p.textPrimary);
    final captionStyle = textTheme.bodySmall!.copyWith(color: p.textSecondary);
    final radius = BorderRadius.circular(AppSpacing.radius);

    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: scheme,
      fontFamily: AppTextStyles.fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: p.background,
      shadowColor: p.brightness == Brightness.light
          ? p.textPrimary
          : Colors.black,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      dividerTheme: DividerThemeData(color: p.border, space: 1, thickness: 1),
      extensions: [AppColors.fromPalette(p)],
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: AppSpacing.screenPadding,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: p.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: AppPalette.onPrimary,
          minimumSize: const Size(64, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primary,
          minimumSize: const Size(64, AppSpacing.buttonHeight),
          side: BorderSide(color: p.primary),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          minimumSize: const Size(64, 44),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.m,
        ),
        hintStyle: captionStyle.copyWith(fontSize: 14),
        labelStyle: textTheme.bodyMedium!.copyWith(color: p.textSecondary),
        errorStyle: textTheme.bodySmall!.copyWith(color: p.error),
        prefixIconColor: p.textSecondary,
        suffixIconColor: p.textSecondary,
        border: border(p.border),
        enabledBorder: border(p.border),
        focusedBorder: border(p.primary),
        errorBorder: border(p.error),
        focusedErrorBorder: border(p.error),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.primary.withValues(alpha: 0.12),
        height: 64,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? p.primary
                : p.textSecondary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => captionStyle.copyWith(
            color: states.contains(WidgetState.selected)
                ? p.primary
                : p.textSecondary,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: p.error,
        textColor: AppPalette.onPrimary,
        textStyle: textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w600),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: radius),
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.textPrimary,
        contentTextStyle: textTheme.bodyMedium!.copyWith(color: p.surface),
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppPalette.onPrimary
              : p.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? p.primary : p.border,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        textStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: p.border),
        ),
      ),
    );
  }
}
