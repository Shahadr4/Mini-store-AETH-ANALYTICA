import '../../../../core/error/result.dart';
import '../entities/product_page.dart';
import '../entities/product_sort.dart';
import '../repositories/products_repository.dart';

class SearchProductsUseCase {
  const SearchProductsUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<ProductPage>> call({
    required String query,
    required int skip,
    required int limit,
    ProductSort sort = ProductSort.none,
  }) => _repository.searchProducts(
    query: query,
    skip: skip,
    limit: limit,
    sort: sort,
  );
}
