import 'package:flutter/material.dart';

import '../../../../core/state/safe_change_notifier.dart';
import '../../domain/usecases/get_theme_usecase.dart';
import '../../domain/usecases/save_theme_usecase.dart';

/// Light / dark mode. The saved choice is restored at start-up.
class ThemeProvider extends SafeChangeNotifier {
  ThemeProvider({
    required GetThemeUseCase getTheme,
    required SaveThemeUseCase saveTheme,
  }) : _saveTheme = saveTheme,
       _mode = getTheme() ? ThemeMode.dark : ThemeMode.light;

  final SaveThemeUseCase _saveTheme;
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  Future<void> setDarkMode(bool isDark) async {
    _mode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _saveTheme(isDark);
  }
}
