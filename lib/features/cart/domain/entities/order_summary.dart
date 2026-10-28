import 'package:equatable/equatable.dart';

/// Result of the (dummy) order, shown on the Order Success screen.
class OrderSummary extends Equatable {
  const OrderSummary({
    required this.orderNumber,
    required this.itemCount,
    required this.totalPaid,
  });

  final String orderNumber;
  final int itemCount;
  final double totalPaid;

  @override
  List<Object?> get props => [orderNumber, itemCount, totalPaid];
}
