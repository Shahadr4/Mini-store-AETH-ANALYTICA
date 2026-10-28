import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/debouncer.dart';
import '../../domain/entities/product_page.dart';
import '../../domain/entities/product_sort.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import 'paged_products_provider.dart';

/// Home tab: paginated list, debounced search and sorting.
class ProductListProvider extends PagedProductsProvider {
  ProductListProvider({
    required GetProductsUseCase getProducts,
    required SearchProductsUseCase searchProducts,
    Debouncer? debouncer,
    super.minLoadingTime,
  }) : _getProducts = getProducts,
       _searchProducts = searchProducts,
       _debouncer = debouncer ?? Debouncer();

  final GetProductsUseCase _getProducts;
  final SearchProductsUseCase _searchProducts;
  final Debouncer _debouncer;

  String _query = '';
  ProductSort _sort = ProductSort.none;

  String get query => _query;
  ProductSort get sort => _sort;

  @override
  Future<Result<ProductPage>> fetchPage(int skip) {
    const limit = ApiConstants.pageSize;
    if (_query.isEmpty) {
      return _getProducts(skip: skip, limit: limit, sort: _sort);
    }
    return _searchProducts(
      query: _query,
      skip: skip,
      limit: limit,
      sort: _sort,
    );
  }

  /// Called on every keystroke; the search runs 500 ms after the last one.
  void search(String text) => _debouncer.run(() => _applyQuery(text.trim()));

  /// Clearing the search shows the normal list again right away.
  void clearSearch() {
    _debouncer.cancel();
    _applyQuery('');
  }

  void setSort(ProductSort sort) {
    if (sort == _sort) return;
    _sort = sort;
    loadFirstPage();
  }

  void _applyQuery(String query) {
    if (query == _query) return;
    _query = query;
    loadFirstPage();
  }

  @override
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }
}
