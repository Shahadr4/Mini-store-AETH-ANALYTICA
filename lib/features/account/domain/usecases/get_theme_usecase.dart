import '../repositories/theme_repository.dart';

class GetThemeUseCase {
  const GetThemeUseCase(this._repository);

  final ThemeRepository _repository;

  bool call() => _repository.isDarkMode;
}
