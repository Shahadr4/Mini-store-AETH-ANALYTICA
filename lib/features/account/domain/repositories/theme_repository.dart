import '../../../../core/error/result.dart';

abstract class ThemeRepository {
  /// Saved preference; light when nothing is saved.
  bool get isDarkMode;

  Future<Result<void>> setDarkMode(bool isDark);
}
