import '../../../../core/error/result.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

/// Changes a quantity by [delta]. Going below 1 removes the item.
class ChangeQuantityUseCase {
  const ChangeQuantityUseCase(this._repository);

  final CartRepository _repository;

  Future<Result<List<CartItem>>> call(int productId, int delta) async {
    final current = await _repository.getItems();
    final items = current.dataOrNull;
    if (items == null) return current;

    final updated = <CartItem>[];
    for (final item in items) {
      if (item.productId != productId) {
        updated.add(item);
        continue;
      }
      final quantity = item.quantity + delta;
      if (quantity >= 1) updated.add(item.copyWith(quantity: quantity));
    }

    final saved = await _repository.saveItems(updated);
    return saved.when(success: (_) => Success(updated), failure: Fail.new);
  }
}
