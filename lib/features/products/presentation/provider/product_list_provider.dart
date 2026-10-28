import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/product_page.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import 'searchable_products_provider.dart';

/// Home tab: paginated list, debounced search and sorting.
class ProductListProvider extends SearchableProductsProvider {
  ProductListProvider({
    required GetProductsUseCase getProducts,
    required SearchProductsUseCase searchProducts,
    super.debouncer,
    super.minLoadingTime,
  }) : _getProducts = getProducts,
       _searchProducts = searchProducts;

  final GetProductsUseCase _getProducts;
  final SearchProductsUseCase _searchProducts;

  @override
  Future<Result<ProductPage>> fetchPage(int skip) {
    const limit = ApiConstants.pageSize;
    if (query.isEmpty) {
      return _getProducts(skip: skip, limit: limit, sort: sort);
    }
    return _searchProducts(query: query, skip: skip, limit: limit, sort: sort);
  }
}
