import 'package:flutter_test/flutter_test.dart';
import 'package:mini_store/core/error/result.dart';
import 'package:mini_store/features/cart/domain/entities/cart_item.dart';
import 'package:mini_store/features/cart/domain/repositories/cart_repository.dart';
import 'package:mini_store/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:mini_store/features/cart/domain/usecases/change_quantity_usecase.dart';
import 'package:mini_store/features/cart/domain/usecases/place_order_usecase.dart';
import 'package:mini_store/features/products/domain/entities/product.dart';

class _InMemoryCartRepository implements CartRepository {
  List<CartItem> items = [];

  @override
  Future<Result<List<CartItem>>> getItems() async => Success(items);

  @override
  Future<Result<void>> saveItems(List<CartItem> items) async {
    this.items = items;
    return const Success(null);
  }

  @override
  Future<Result<void>> clear() async {
    items = [];
    return const Success(null);
  }
}

const _product = Product(
  id: 1,
  title: 'Mascara',
  description: '',
  category: 'beauty',
  price: 10,
  discountPercentage: 0,
  rating: 4.5,
  stock: 5,
  brand: null,
  availabilityStatus: 'In Stock',
  thumbnail: 'thumb.png',
  images: [],
  reviews: [],
);

void main() {
  late _InMemoryCartRepository repository;

  setUp(() => repository = _InMemoryCartRepository());

  group('AddToCartUseCase', () {
    test('adds a new product with quantity 1', () async {
      final result = await AddToCartUseCase(repository)(_product);

      expect(result.dataOrNull, hasLength(1));
      expect(repository.items.single.quantity, 1);
      expect(repository.items.single.title, 'Mascara');
    });

    test('adding the same product again increases its quantity', () async {
      final add = AddToCartUseCase(repository);
      await add(_product);
      await add(_product);

      expect(repository.items, hasLength(1));
      expect(repository.items.single.quantity, 2);
    });
  });

  group('ChangeQuantityUseCase', () {
    test('decreasing from 1 removes the item', () async {
      await AddToCartUseCase(repository)(_product);

      final result = await ChangeQuantityUseCase(repository)(_product.id, -1);

      expect(result.dataOrNull, isEmpty);
      expect(repository.items, isEmpty);
    });

    test('increasing raises the quantity', () async {
      await AddToCartUseCase(repository)(_product);

      await ChangeQuantityUseCase(repository)(_product.id, 1);

      expect(repository.items.single.quantity, 2);
    });
  });

  group('PlaceOrderUseCase', () {
    test('returns a summary and clears the cart', () async {
      final add = AddToCartUseCase(repository);
      await add(_product);
      await add(_product);

      final result = await PlaceOrderUseCase(
        repository,
        processingTime: Duration.zero,
      )();

      final order = result.dataOrNull!;
      expect(order.orderNumber, matches(RegExp(r'^#MS-\d{5}$')));
      expect(order.itemCount, 2);
      expect(order.totalPaid, 20);
      expect(repository.items, isEmpty);
    });

    test('fails when the cart is empty', () async {
      final result = await PlaceOrderUseCase(
        repository,
        processingTime: Duration.zero,
      )();

      expect(result.failureOrNull?.message, 'Your cart is empty.');
    });
  });
}
