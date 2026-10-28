import '../../../../core/error/result.dart';
import '../../../products/domain/entities/product_page.dart';
import '../../../products/domain/entities/product_sort.dart';
import '../entities/category.dart';

abstract class CategoriesRepository {
  Future<Result<List<Category>>> getCategories();

  /// One page of the products in [slug]. A non-empty [query] only keeps the
  /// products of that category whose text matches it.
  Future<Result<ProductPage>> getProductsByCategory({
    required String slug,
    required int skip,
    required int limit,
    String query = '',
    ProductSort sort = ProductSort.none,
  });
}
