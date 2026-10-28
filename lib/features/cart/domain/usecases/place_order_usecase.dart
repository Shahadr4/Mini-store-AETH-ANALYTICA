import 'dart:math';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/order_summary.dart';
import '../repositories/cart_repository.dart';

/// Dummy order: waits a moment (no API call), builds a local order number
/// and clears the cart.
class PlaceOrderUseCase {
  PlaceOrderUseCase(
    this._repository, {
    this.processingTime = const Duration(milliseconds: 1500),
    Random? random,
  }) : _random = random ?? Random();

  final CartRepository _repository;
  final Duration processingTime;
  final Random _random;

  Future<Result<OrderSummary>> call() async {
    final current = await _repository.getItems();
    final items = current.dataOrNull;
    if (items == null) return Fail(current.failureOrNull!);
    if (items.isEmpty) return const Fail(UnknownFailure('Your cart is empty.'));

    await Future<void>.delayed(processingTime);

    final summary = OrderSummary(
      orderNumber: '#MS-${10000 + _random.nextInt(90000)}',
      itemCount: items.fold(0, (sum, item) => sum + item.quantity),
      totalPaid: items.fold(0.0, (sum, item) => sum + item.total),
    );
    final cleared = await _repository.clear();
    return cleared.when(success: (_) => Success(summary), failure: Fail.new);
  }
}
