import '../../../../core/error/error_handler.dart';
import '../../../../core/error/result.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_data_source.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  const ThemeRepositoryImpl(this._local);

  final ThemeLocalDataSource _local;

  @override
  bool get isDarkMode => _local.isDarkMode;

  @override
  Future<Result<void>> setDarkMode(bool isDark) =>
      guard(() => _local.setDarkMode(isDark));
}
