import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_store/features/categories/data/datasources/categories_remote_data_source.dart';
import 'package:mini_store/features/products/domain/entities/product_sort.dart';

/// Answers every request with [body] and remembers the last request.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.body);

  final Map<String, dynamic> body;
  late RequestOptions last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _json(int id, String category) => {
  'id': id,
  'title': 'Product $id',
  'category': category,
  'price': 1.0,
};

void main() {
  test(
    'without a query it uses the category endpoint with sort and paging',
    () async {
      final adapter = _FakeAdapter({
        'products': [_json(1, 'beauty')],
        'total': 1,
      });
      final source = CategoriesRemoteDataSourceImpl(
        Dio()..httpClientAdapter = adapter,
      );

      await source.getProductsByCategory(
        slug: 'beauty',
        skip: 10,
        limit: 10,
        sort: ProductSort.priceHighToLow,
      );

      expect(adapter.last.path, '/products/category/beauty');
      expect(adapter.last.queryParameters, {
        'limit': 10,
        'skip': 10,
        'sortBy': 'price',
        'order': 'desc',
      });
    },
  );

  test(
    'with a query it searches, keeps only this category and counts them',
    () async {
      final adapter = _FakeAdapter({
        'products': [
          _json(1, 'beauty'),
          _json(2, 'fragrances'),
          _json(3, 'beauty'),
        ],
        'total': 3,
      });
      final source = CategoriesRemoteDataSourceImpl(
        Dio()..httpClientAdapter = adapter,
      );

      final page = await source.getProductsByCategory(
        slug: 'beauty',
        skip: 0,
        limit: 10,
        query: 'mas',
      );

      expect(adapter.last.path, '/products/search');
      expect(adapter.last.queryParameters, {'q': 'mas', 'limit': 0});
      expect(page.products.map((p) => p.id), [1, 3]);
      expect(page.total, 2);
    },
  );

  test('search results are cut into pages by skip and limit', () async {
    final adapter = _FakeAdapter({
      'products': [for (var i = 1; i <= 25; i++) _json(i, 'beauty')],
      'total': 25,
    });
    final source = CategoriesRemoteDataSourceImpl(
      Dio()..httpClientAdapter = adapter,
    );

    final second = await source.getProductsByCategory(
      slug: 'beauty',
      skip: 10,
      limit: 10,
      query: 'p',
    );
    final past = await source.getProductsByCategory(
      slug: 'beauty',
      skip: 30,
      limit: 10,
      query: 'p',
    );

    expect(second.products.map((p) => p.id), [
      for (var i = 11; i <= 20; i++) i,
    ]);
    expect(second.total, 25);
    expect(past.products, isEmpty);
  });
}
