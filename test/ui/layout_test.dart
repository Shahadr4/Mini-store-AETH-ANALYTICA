import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_store/core/theme/app_theme.dart';
import 'package:mini_store/features/cart/domain/entities/cart_item.dart';
import 'package:mini_store/features/cart/presentation/provider/cart_provider.dart';
import 'package:mini_store/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:mini_store/features/products/domain/entities/product.dart';
import 'package:mini_store/core/error/failures.dart';
import 'package:mini_store/core/error/result.dart';
import 'package:mini_store/features/products/domain/entities/product_page.dart';
import 'package:mini_store/features/products/presentation/provider/paged_products_provider.dart';
import 'package:mini_store/features/products/presentation/widgets/paged_product_grid.dart';
import 'package:mini_store/features/products/presentation/widgets/product_card.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class _MockCartProvider extends Mock
    with ChangeNotifier
    implements CartProvider {}

const _longTitle =
    'An extremely long product title that should never overflow the card';

final _products = List.generate(
  10,
  (i) => Product(
    id: i + 1,
    title: _longTitle,
    description: 'desc',
    category: 'beauty',
    price: 12345.67,
    discountPercentage: 12.5,
    rating: 4.5,
    stock: 3,
    brand: null,
    availabilityStatus: 'In Stock',
    thumbnail: '',
    images: const [],
    reviews: const [],
  ),
);

Widget _app(Widget child, {double textScale = 1}) {
  final router = GoRouter(
    routes: [GoRoute(path: '/', builder: (_, _) => child)],
  );
  final cart = _MockCartProvider();
  when(() => cart.quantityOf(any())).thenReturn(0);
  return ChangeNotifierProvider<CartProvider>.value(
    value: cart,
    child: MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: app!,
      ),
      routerConfig: router,
    ),
  );
}

/// Provider whose "server" is a function the test controls.
class _FakeProducts extends PagedProductsProvider {
  _FakeProducts(this._onFetch) : super(minLoadingTime: Duration.zero);

  final Future<Result<ProductPage>> Function(int skip) _onFetch;

  @override
  Future<Result<ProductPage>> fetchPage(int skip) => _onFetch(skip);
}

Widget _grid(PagedProductsProvider provider) => Scaffold(
  body: PagedProductGrid(
    provider: provider,
    onRefresh: () async {},
    emptyTitle: 'Nothing here',
  ),
);

/// Loads the first page of [_products], then keeps "load more" pending.
///
/// `runAsync` is needed to `await` real futures inside a widget test.
Future<PagedProductsProvider> _providerWithProducts(WidgetTester tester) async {
  final provider = _FakeProducts(
    (skip) => skip == 0
        ? Future.value(Success(ProductPage(products: _products, total: 20)))
        : Completer<Result<ProductPage>>().future,
  );
  await tester.runAsync(provider.loadFirstPage);
  provider.loadMore();
  return provider;
}

void main() {
  const sizes = {
    'small phone': Size(320, 568),
    'phone': Size(390, 844),
    'tablet': Size(800, 1280),
  };

  for (final entry in sizes.entries) {
    for (final scale in [1.0, 1.5]) {
      testWidgets(
        'product grid has no overflow on ${entry.key} at ${scale}x text',
        (tester) async {
          tester.view.physicalSize = entry.value;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            _app(_grid(await _providerWithProducts(tester)), textScale: scale),
          );
          await tester.pump();

          expect(tester.takeException(), isNull);
          expect(find.text(_longTitle), findsWidgets);
        },
      );
    }
  }

  testWidgets('grid shows loading skeleton, error and empty states', (
    tester,
  ) async {
    // Loading: the server never answers.
    final loading = _FakeProducts(
      (_) => Completer<Result<ProductPage>>().future,
    )..loadFirstPage();
    await tester.pumpWidget(_app(_grid(loading)));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(ProductCardSkeleton), findsWidgets);

    // Error.
    final failed = _FakeProducts((_) async => const Fail(NetworkFailure()));
    await tester.runAsync(failed.loadFirstPage);
    await tester.pumpWidget(_app(_grid(failed)));
    await tester.pump();
    expect(find.text(const NetworkFailure().message), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    // Empty.
    final empty = _FakeProducts(
      (_) async => const Success(ProductPage(products: [], total: 0)),
    );
    await tester.runAsync(empty.loadFirstPage);
    await tester.pumpWidget(_app(_grid(empty)));
    await tester.pump();
    expect(find.text('Nothing here'), findsOneWidget);
  });

  testWidgets('cart tile has no overflow on a small phone with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        Scaffold(
          body: CartItemTile(
            item: const CartItem(
              productId: 1,
              title: _longTitle,
              price: 12345.67,
              thumbnail: '',
              quantity: 12,
            ),
            onIncrement: () {},
            onDecrement: () {},
            onRemove: () {},
          ),
        ),
        textScale: 1.5,
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
