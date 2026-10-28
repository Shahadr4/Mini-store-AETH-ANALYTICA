import '../../../../core/error/result.dart';
import '../entities/product_page.dart';
import '../entities/product_sort.dart';
import '../repositories/products_repository.dart';

class GetProductsUseCase {
  const GetProductsUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<ProductPage>> call({
    required int skip,
    required int limit,
    ProductSort sort = ProductSort.none,
  }) => _repository.getProducts(skip: skip, limit: limit, sort: sort);
}
