import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/result.dart';
import '../../../products/domain/entities/product_page.dart';
import '../../../products/presentation/provider/paged_products_provider.dart';
import '../../domain/usecases/get_products_by_category_usecase.dart';

/// Products of one category, paginated like the Home list.
class CategoryProductsProvider extends PagedProductsProvider {
  CategoryProductsProvider(this._getProductsByCategory, {super.minLoadingTime});

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
  );
}
