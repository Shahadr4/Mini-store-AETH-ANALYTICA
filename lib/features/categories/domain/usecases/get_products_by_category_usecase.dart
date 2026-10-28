import '../../../../core/error/result.dart';
import '../../../products/domain/entities/product_page.dart';
import '../repositories/categories_repository.dart';

class GetProductsByCategoryUseCase {
  const GetProductsByCategoryUseCase(this._repository);

  final CategoriesRepository _repository;

  Future<Result<ProductPage>> call({
    required String slug,
    required int skip,
    required int limit,
  }) => _repository.getProductsByCategory(slug: slug, skip: skip, limit: limit);
}
