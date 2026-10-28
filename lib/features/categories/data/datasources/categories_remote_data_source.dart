import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../products/data/models/product_page_model.dart';
import '../../../products/domain/entities/product_sort.dart';
import '../models/category_model.dart';

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getCategories();

  Future<ProductPageModel> getProductsByCategory({
    required String slug,
    required int skip,
    required int limit,
    String query = '',
    ProductSort sort = ProductSort.none,
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
    String query = '',
    ProductSort sort = ProductSort.none,
  }) async {
    if (query.isEmpty) {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.productsByCategory(slug),
        queryParameters: {'limit': limit, 'skip': skip, ..._sortQuery(sort)},
      );
      return ProductPageModel.fromJson(response.data!);
    }
    return _searchInCategory(
      slug: slug,
      query: query,
      skip: skip,
      limit: limit,
      sort: sort,
    );
  }

  /// The API cannot search inside one category, so ask for every match
  /// (`limit=0`), keep the ones of this category and cut the page here. The
  /// result has the same shape as any other page, so the paging logic of the
  /// list does not change.
  Future<ProductPageModel> _searchInCategory({
    required String slug,
    required String query,
    required int skip,
    required int limit,
    required ProductSort sort,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.searchProducts,
      queryParameters: {'q': query, 'limit': 0, ..._sortQuery(sort)},
    );
    final matches = ProductPageModel.fromJson(
      response.data!,
    ).products.where((product) => product.category == slug).toList();
    final end = (skip + limit).clamp(0, matches.length);
    return ProductPageModel(
      products: matches.sublist(skip.clamp(0, end), end),
      total: matches.length,
    );
  }

  Map<String, dynamic> _sortQuery(ProductSort sort) => {
    if (sort.sortBy != null) 'sortBy': sort.sortBy,
    if (sort.order != null) 'order': sort.order,
  };
}
