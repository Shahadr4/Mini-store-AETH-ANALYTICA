import 'package:flutter_test/flutter_test.dart';
import 'package:mini_store/core/error/result.dart';
import 'package:mini_store/core/utils/debouncer.dart';
import 'package:mini_store/features/categories/domain/repositories/categories_repository.dart';
import 'package:mini_store/features/categories/domain/usecases/get_products_by_category_usecase.dart';
import 'package:mini_store/features/categories/presentation/provider/category_products_provider.dart';
import 'package:mini_store/features/products/domain/entities/product.dart';
import 'package:mini_store/features/products/domain/entities/product_page.dart';
import 'package:mini_store/features/products/domain/entities/product_sort.dart';
import 'package:mini_store/features/products/presentation/provider/paged_products_provider.dart';
import 'package:mocktail/mocktail.dart';

class _MockCategoriesRepository extends Mock implements CategoriesRepository {}

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

ProductPage _page(int count, {required int total}) => ProductPage(
  products: [for (var i = 1; i <= count; i++) _product(i)],
  total: total,
);

void main() {
  late _MockCategoriesRepository repository;

  CategoryProductsProvider buildProvider() => CategoryProductsProvider(
    GetProductsByCategoryUseCase(repository),
    debouncer: Debouncer(delay: const Duration(milliseconds: 10)),
    minLoadingTime: Duration.zero,
  );

  void stub({
    String query = '',
    ProductSort sort = ProductSort.none,
    required Result<ProductPage> result,
  }) {
    when(
      () => repository.getProductsByCategory(
        slug: 'beauty',
        skip: 0,
        limit: 10,
        query: query,
        sort: sort,
      ),
    ).thenAnswer((_) async => result);
  }

  setUpAll(() => registerFallbackValue(ProductSort.none));
  setUp(() => repository = _MockCategoriesRepository());

  test('loads the first page of the category', () async {
    stub(result: Success(_page(5, total: 5)));
    final provider = buildProvider();

    await provider.start('beauty');

    expect(provider.status, ListStatus.success);
    expect(provider.products, hasLength(5));
  });

  test('search asks only for this category and resets to page 1', () async {
    stub(result: Success(_page(5, total: 5)));
    stub(query: 'mas', result: Success(_page(1, total: 1)));
    final provider = buildProvider();
    await provider.start('beauty');

    provider.search(' mas ');
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(provider.query, 'mas');
    expect(provider.products, hasLength(1));
    verify(
      () => repository.getProductsByCategory(
        slug: 'beauty',
        skip: 0,
        limit: 10,
        query: 'mas',
        sort: ProductSort.none,
      ),
    ).called(1);
  });

  test('sort reloads the category with the chosen order', () async {
    stub(result: Success(_page(5, total: 5)));
    stub(sort: ProductSort.priceLowToHigh, result: Success(_page(3, total: 3)));
    final provider = buildProvider();
    await provider.start('beauty');

    provider.setSort(ProductSort.priceLowToHigh);
    await Future<void>.delayed(Duration.zero);

    expect(provider.sort, ProductSort.priceLowToHigh);
    expect(provider.products, hasLength(3));
  });

  test('search keeps the chosen sort', () async {
    stub(result: Success(_page(5, total: 5)));
    stub(sort: ProductSort.topRated, result: Success(_page(5, total: 5)));
    stub(
      query: 'x',
      sort: ProductSort.topRated,
      result: Success(_page(2, total: 2)),
    );
    final provider = buildProvider();
    await provider.start('beauty');
    provider.setSort(ProductSort.topRated);
    await Future<void>.delayed(Duration.zero);

    provider.search('x');
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(provider.products, hasLength(2));
  });

  test('clearing the search brings the full category back', () async {
    stub(result: Success(_page(5, total: 5)));
    stub(query: 'zzz', result: Success(_page(0, total: 0)));
    final provider = buildProvider();
    await provider.start('beauty');
    provider.search('zzz');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(provider.isEmpty, isTrue);

    provider.clearSearch();
    await Future<void>.delayed(Duration.zero);

    expect(provider.query, isEmpty);
    expect(provider.products, hasLength(5));
  });
}
