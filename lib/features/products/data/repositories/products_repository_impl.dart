import '../../../../core/error/error_handler.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_page.dart';
import '../../domain/entities/product_sort.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_data_source.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  const ProductsRepositoryImpl(this._remote);

  final ProductsRemoteDataSource _remote;

  @override
  Future<Result<ProductPage>> getProducts({
    required int skip,
    required int limit,
    ProductSort sort = ProductSort.none,
  }) => guard(() => _remote.getProducts(skip: skip, limit: limit, sort: sort));

  @override
  Future<Result<ProductPage>> searchProducts({
    required String query,
    required int skip,
    required int limit,
    ProductSort sort = ProductSort.none,
  }) => guard(
    () => _remote.searchProducts(
      query: query,
      skip: skip,
      limit: limit,
      sort: sort,
    ),
  );

  @override
  Future<Result<Product>> getProductDetails(int id) =>
      guard(() => _remote.getProduct(id));
}
