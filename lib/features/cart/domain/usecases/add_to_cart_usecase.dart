import '../../../../core/error/result.dart';
import '../../../products/domain/entities/product.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

/// Adds a product, or increases its quantity if it is already in the cart.
class AddToCartUseCase {
  const AddToCartUseCase(this._repository);

  final CartRepository _repository;

  Future<Result<List<CartItem>>> call(Product product) async {
    final current = await _repository.getItems();
    final items = current.dataOrNull;
    if (items == null) return current;

    final index = items.indexWhere((item) => item.productId == product.id);
    final updated = [...items];
    if (index >= 0) {
      updated[index] = updated[index].copyWith(
        quantity: updated[index].quantity + 1,
      );
    } else {
      updated.add(
        CartItem(
          productId: product.id,
          title: product.title,
          price: product.price,
          thumbnail: product.thumbnail,
          quantity: 1,
        ),
      );
    }
    return _save(updated);
  }

  Future<Result<List<CartItem>>> _save(List<CartItem> items) async {
    final saved = await _repository.saveItems(items);
    return saved.when(success: (_) => Success(items), failure: Fail.new);
  }
}
