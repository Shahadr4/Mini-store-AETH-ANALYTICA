import '../../../../core/error/result.dart';
import '../repositories/theme_repository.dart';

class SaveThemeUseCase {
  const SaveThemeUseCase(this._repository);

  final ThemeRepository _repository;

  Future<Result<void>> call(bool isDark) => _repository.setDarkMode(isDark);
}
