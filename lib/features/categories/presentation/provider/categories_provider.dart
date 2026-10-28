import '../../../../core/state/safe_change_notifier.dart';
import '../../../../core/utils/min_duration.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/get_categories_usecase.dart';

enum CategoriesStatus { loading, success, failure }

class CategoriesProvider extends SafeChangeNotifier {
  CategoriesProvider(
    this._getCategories, {
    this.minLoadingTime = const Duration(milliseconds: 600),
  });

  final GetCategoriesUseCase _getCategories;

  /// The shimmer is shown at least this long, even if the reply is instant.
  final Duration minLoadingTime;

  CategoriesStatus _status = CategoriesStatus.loading;
  List<Category> _categories = [];
  String? _errorMessage;

  CategoriesStatus get status => _status;
  List<Category> get categories => _categories;
  String? get errorMessage => _errorMessage;
  bool get isEmpty =>
      _status == CategoriesStatus.success && _categories.isEmpty;

  /// Shows the shimmer and loads the categories. If a [refresh] fails, the old
  /// categories stay and the error message is returned.
  Future<String?> load({bool refresh = false}) async {
    final oldCategories = _categories;
    _status = CategoriesStatus.loading;
    _categories = [];
    notifyListeners();

    final result = await withMinDuration(_getCategories(), minLoadingTime);

    String? refreshError;
    result.when(
      success: (categories) {
        _status = CategoriesStatus.success;
        _categories = categories;
      },
      failure: (failure) {
        if (refresh && oldCategories.isNotEmpty) {
          _status = CategoriesStatus.success;
          _categories = oldCategories;
          refreshError = failure.message;
        } else {
          _status = CategoriesStatus.failure;
          _errorMessage = failure.message;
        }
      },
    );
    notifyListeners();
    return refreshError;
  }
}
