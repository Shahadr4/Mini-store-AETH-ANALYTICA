import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../products/data/models/product_page_model.dart';
import '../models/category_model.dart';

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getCategories();

  Future<ProductPageModel> getProductsByCategory({
    required String slug,
    required int skip,
    required int limit,
  });
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  const CategoriesRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<CategoryModel>> getCategories() async {
    // The endpoint returns a plain list, not a wrapped object.
    final response = await _dio.get<List<dynamic>>(ApiConstants.categories);
    return response.data!
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductPageModel> getProductsByCategory({
    required String slug,
    required int skip,
    required int limit,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.productsByCategory(slug),
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return ProductPageModel.fromJson(response.data!);
  }
}
