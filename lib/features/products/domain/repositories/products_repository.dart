import '../../../../core/error/result.dart';
import '../entities/product.dart';
import '../entities/product_page.dart';
import '../entities/product_sort.dart';

abstract class ProductsRepository {
  Future<Result<ProductPage>> getProducts({
    required int skip,
    required int limit,
    ProductSort sort = ProductSort.none,
  });

  Future<Result<ProductPage>> searchProducts({
    required String query,
    required int skip,
    required int limit,
    ProductSort sort = ProductSort.none,
  });

  Future<Result<Product>> getProductDetails(int id);
}
