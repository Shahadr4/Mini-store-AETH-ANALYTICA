import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/result.dart';
import '../../../products/domain/entities/product_page.dart';
import '../../../products/presentation/provider/searchable_products_provider.dart';
import '../../domain/usecases/get_products_by_category_usecase.dart';

/// Products of one category: paginated, searchable and sortable like Home.
class CategoryProductsProvider extends SearchableProductsProvider {
  CategoryProductsProvider(
    this._getProductsByCategory, {
    super.debouncer,
    super.minLoadingTime,
  });

  final GetProductsByCategoryUseCase _getProductsByCategory;
  late final String _slug;

  Future<String?> start(String slug) {
    _slug = slug;
    return loadFirstPage();
  }

  @override
  Future<Result<ProductPage>> fetchPage(int skip) => _getProductsByCategory(
    slug: _slug,
    skip: skip,
    limit: ApiConstants.pageSize,
    query: query,
    sort: sort,
  );
}
