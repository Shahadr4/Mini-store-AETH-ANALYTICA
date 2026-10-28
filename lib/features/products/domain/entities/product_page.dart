import 'package:equatable/equatable.dart';

import 'product.dart';

/// One page of products plus the total number on the server.
class ProductPage extends Equatable {
  const ProductPage({required this.products, required this.total});

  final List<Product> products;
  final int total;

  @override
  List<Object?> get props => [products, total];
}
