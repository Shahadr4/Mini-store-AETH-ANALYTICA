import '../../../../core/error/error_handler.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._local);

  final CartLocalDataSource _local;

  @override
  Future<Result<List<CartItem>>> getItems() =>
      guard(() async => _local.getItems().cast<CartItem>());

  @override
  Future<Result<void>> saveItems(List<CartItem> items) => guard(
    () => _local.saveItems(items.map(CartItemModel.fromEntity).toList()),
  );

  @override
  Future<Result<void>> clear() => guard(_local.clear);
}
