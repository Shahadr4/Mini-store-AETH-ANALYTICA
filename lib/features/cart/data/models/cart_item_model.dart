import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.productId,
    required super.title,
    required super.price,
    required super.thumbnail,
    required super.quantity,
  });

  factory CartItemModel.fromEntity(CartItem item) => CartItemModel(
    productId: item.productId,
    title: item.title,
    price: item.price,
    thumbnail: item.thumbnail,
    quantity: item.quantity,
  );

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    productId: json['id'] as int,
    title: json['title'] as String,
    price: (json['price'] as num).toDouble(),
    thumbnail: json['thumbnail'] as String? ?? '',
    quantity: json['quantity'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': productId,
    'title': title,
    'price': price,
    'thumbnail': thumbnail,
    'quantity': quantity,
  };
}
