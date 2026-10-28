import '../../../../core/error/result.dart';
import '../../../products/domain/entities/product_page.dart';
import '../entities/category.dart';

abstract class CategoriesRepository {
  Future<Result<List<Category>>> getCategories();

  Future<Result<ProductPage>> getProductsByCategory({
    required String slug,
    required int skip,
    required int limit,
  });
}
