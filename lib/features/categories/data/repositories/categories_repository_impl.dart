import '../../../../core/error/error_handler.dart';
import '../../../../core/error/result.dart';
import '../../../products/domain/entities/product_page.dart';
import '../../../products/domain/entities/product_sort.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/categories_repository.dart';
import '../datasources/categories_remote_data_source.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  const CategoriesRepositoryImpl(this._remote);

  final CategoriesRemoteDataSource _remote;

  @override
  Future<Result<List<Category>>> getCategories() =>
      guard(() async => (await _remote.getCategories()).cast<Category>());

  @override
  Future<Result<ProductPage>> getProductsByCategory({
    required String slug,
    required int skip,
    required int limit,
    String query = '',
    ProductSort sort = ProductSort.none,
  }) => guard(
    () => _remote.getProductsByCategory(
      slug: slug,
      skip: skip,
      limit: limit,
      query: query,
      sort: sort,
    ),
  );
}
