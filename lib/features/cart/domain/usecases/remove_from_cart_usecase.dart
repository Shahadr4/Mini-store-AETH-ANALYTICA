import '../../../../core/error/result.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class RemoveFromCartUseCase {
  const RemoveFromCartUseCase(this._repository);

  final CartRepository _repository;

  Future<Result<List<CartItem>>> call(int productId) async {
    final current = await _repository.getItems();
    final items = current.dataOrNull;
    if (items == null) return current;

    final updated = items.where((item) => item.productId != productId).toList();
    final saved = await _repository.saveItems(updated);
    return saved.when(success: (_) => Success(updated), failure: Fail.new);
  }
}
