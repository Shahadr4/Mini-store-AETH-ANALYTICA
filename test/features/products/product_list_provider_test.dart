import 'package:flutter_test/flutter_test.dart';
import 'package:mini_store/core/error/failures.dart';
import 'package:mini_store/core/error/result.dart';
import 'package:mini_store/core/utils/debouncer.dart';
import 'package:mini_store/features/products/domain/entities/product.dart';
import 'package:mini_store/features/products/domain/entities/product_page.dart';
import 'package:mini_store/features/products/domain/entities/product_sort.dart';
import 'package:mini_store/features/products/domain/repositories/products_repository.dart';
import 'package:mini_store/features/products/domain/usecases/get_products_usecase.dart';
import 'package:mini_store/features/products/domain/usecases/search_products_usecase.dart';
import 'package:mini_store/features/products/presentation/provider/product_list_provider.dart';
import 'package:mini_store/features/products/presentation/provider/paged_products_provider.dart';
import 'package:mocktail/mocktail.dart';

class _MockProductsRepository extends Mock implements ProductsRepository {}

Product _product(int id) => Product(
  id: id,
  title: 'Product $id',
  description: '',
  category: 'beauty',
  price: 1,
  discountPercentage: 0,
  rating: 4,
  stock: 1,
  brand: null,
  availabilityStatus: 'In Stock',
  thumbnail: '',
  images: const [],
  reviews: const [],
);

ProductPage _page(int from, int count, {required int total}) => ProductPage(
  products: [for (var i = 0; i < count; i++) _product(from + i)],
  total: total,
);

void main() {
  late _MockProductsRepository repository;

  ProductListProvider buildProvider() => ProductListProvider(
    getProducts: GetProductsUseCase(repository),
    searchProducts: SearchProductsUseCase(repository),
    debouncer: Debouncer(delay: const Duration(milliseconds: 10)),
    minLoadingTime: Duration.zero,
  );

  void stubProducts({required int skip, required Result<ProductPage> result}) {
    when(
      () => repository.getProducts(
        skip: skip,
        limit: 10,
        sort: any(named: 'sort'),
      ),
    ).thenAnswer((_) async => result);
  }

  setUpAll(() => registerFallbackValue(ProductSort.none));
  setUp(() => repository = _MockProductsRepository());

  test('loads the first page', () async {
    stubProducts(skip: 0, result: Success(_page(1, 10, total: 25)));
    final provider = buildProvider();

    await provider.loadFirstPage();

    expect(provider.status, ListStatus.success);
    expect(provider.products, hasLength(10));
    expect(provider.hasReachedMax, isFalse);
    provider.dispose();
  });

  test('next skip equals the number of loaded products', () async {
    stubProducts(skip: 0, result: Success(_page(1, 10, total: 15)));
    stubProducts(skip: 10, result: Success(_page(11, 5, total: 15)));
    final provider = buildProvider();

    await provider.loadFirstPage();
    await provider.loadMore();

    verify(
      () =>
          repository.getProducts(skip: 10, limit: 10, sort: any(named: 'sort')),
    ).called(1);
    expect(provider.products, hasLength(15));
    expect(provider.hasReachedMax, isTrue);
    provider.dispose();
  });

  test('does not call the API again once everything is loaded', () async {
    stubProducts(skip: 0, result: Success(_page(1, 5, total: 5)));
    final provider = buildProvider();

    await provider.loadFirstPage();
    await provider.loadMore();

    verify(
      () => repository.getProducts(
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
        sort: any(named: 'sort'),
      ),
    ).called(1);
    provider.dispose();
  });

  test('ignores loadMore while a page is already loading', () async {
    stubProducts(skip: 0, result: Success(_page(1, 10, total: 30)));
    stubProducts(skip: 10, result: Success(_page(11, 10, total: 30)));
    final provider = buildProvider();
    await provider.loadFirstPage();

    await Future.wait([provider.loadMore(), provider.loadMore()]);

    verify(
      () =>
          repository.getProducts(skip: 10, limit: 10, sort: any(named: 'sort')),
    ).called(1);
    expect(provider.products, hasLength(20));
    provider.dispose();
  });

  test('a failed next page keeps the items and allows retry', () async {
    stubProducts(skip: 0, result: Success(_page(1, 10, total: 30)));
    stubProducts(skip: 10, result: const Fail(NetworkFailure()));
    final provider = buildProvider();
    await provider.loadFirstPage();

    await provider.loadMore();

    expect(provider.products, hasLength(10));
    expect(provider.loadMoreFailed, isTrue);
    expect(provider.isLoadingMore, isFalse);

    stubProducts(skip: 10, result: Success(_page(11, 10, total: 30)));
    await provider.loadMore();

    expect(provider.products, hasLength(20));
    expect(provider.loadMoreFailed, isFalse);
    provider.dispose();
  });

  test('first page failure ends in the failure state', () async {
    stubProducts(skip: 0, result: const Fail(NetworkFailure()));
    final provider = buildProvider();

    await provider.loadFirstPage();

    expect(provider.status, ListStatus.failure);
    expect(provider.errorMessage, const NetworkFailure().message);
    provider.dispose();
  });

  test('refresh shows the skeleton, then the new items', () async {
    stubProducts(skip: 0, result: Success(_page(1, 10, total: 30)));
    final provider = buildProvider();
    await provider.loadFirstPage();
    final statuses = <ListStatus>[];
    provider.addListener(() => statuses.add(provider.status));

    stubProducts(skip: 0, result: Success(_page(100, 10, total: 30)));
    final error = await provider.refresh();

    expect(statuses, [ListStatus.loading, ListStatus.success]);
    expect(error, isNull);
    expect(provider.products.first.id, 100);
    provider.dispose();
  });

  test('a failed refresh brings the old items back', () async {
    stubProducts(skip: 0, result: Success(_page(1, 10, total: 30)));
    final provider = buildProvider();
    await provider.loadFirstPage();

    stubProducts(skip: 0, result: const Fail(NetworkFailure()));
    final error = await provider.refresh();

    expect(error, const NetworkFailure().message);
    expect(provider.status, ListStatus.success);
    expect(provider.products, hasLength(10));
    provider.dispose();
  });

  test('search runs once after the debounce and resets the list', () async {
    when(
      () => repository.searchProducts(
        query: 'phone',
        skip: 0,
        limit: 10,
        sort: any(named: 'sort'),
      ),
    ).thenAnswer((_) async => Success(_page(1, 2, total: 2)));
    final provider = buildProvider();

    provider
      ..search('p')
      ..search('ph')
      ..search('phone');
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(provider.query, 'phone');
    expect(provider.products, hasLength(2));
    verify(
      () => repository.searchProducts(
        query: any(named: 'query'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
        sort: any(named: 'sort'),
      ),
    ).called(1);
    provider.dispose();
  });

  test('empty search result is an empty (not error) state', () async {
    when(
      () => repository.searchProducts(
        query: 'zzz',
        skip: 0,
        limit: 10,
        sort: any(named: 'sort'),
      ),
    ).thenAnswer(
      (_) async => const Success(ProductPage(products: [], total: 0)),
    );
    final provider = buildProvider();

    provider.search('zzz');
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(provider.isEmpty, isTrue);
    provider.dispose();
  });
}
