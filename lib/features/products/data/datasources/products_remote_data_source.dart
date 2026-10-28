import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/product_sort.dart';
import '../models/product_model.dart';
import '../models/product_page_model.dart';

abstract class ProductsRemoteDataSource {
  Future<ProductPageModel> getProducts({
    required int skip,
    required int limit,
    ProductSort sort = ProductSort.none,
  });

  Future<ProductPageModel> searchProducts({
    required String query,
    required int skip,
    required int limit,
    ProductSort sort = ProductSort.none,
  });

  Future<ProductModel> getProduct(int id);
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  const ProductsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<ProductPageModel> getProducts({
    required int skip,
    required int limit,
    ProductSort sort = ProductSort.none,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.products,
      queryParameters: _query(skip: skip, limit: limit, sort: sort),
    );
    return ProductPageModel.fromJson(response.data!);
  }

  @override
  Future<ProductPageModel> searchProducts({
    required String query,
    required int skip,
    required int limit,
    ProductSort sort = ProductSort.none,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.searchProducts,
      queryParameters: {
        'q': query,
        ..._query(skip: skip, limit: limit, sort: sort),
      },
    );
    return ProductPageModel.fromJson(response.data!);
  }

  @override
  Future<ProductModel> getProduct(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.productById(id),
    );
    return ProductModel.fromJson(response.data!);
  }

  Map<String, dynamic> _query({
    required int skip,
    required int limit,
    required ProductSort sort,
  }) => {
    'limit': limit,
    'skip': skip,
    if (sort.sortBy != null) 'sortBy': sort.sortBy,
    if (sort.order != null) 'order': sort.order,
  };
}
