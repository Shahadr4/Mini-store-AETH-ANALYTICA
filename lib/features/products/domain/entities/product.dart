import 'package:equatable/equatable.dart';

import 'review.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.availabilityStatus,
    required this.thumbnail,
    required this.images,
    required this.reviews,
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;

  /// Some products have no brand.
  final String? brand;
  final String availabilityStatus;
  final String thumbnail;
  final List<String> images;
  final List<Review> reviews;

  bool get isOutOfStock =>
      stock <= 0 || availabilityStatus.toLowerCase() == 'out of stock';

  bool get hasDiscount => discountPercentage >= 1;

  /// Price before the discount was applied.
  double get originalPrice => discountPercentage >= 100
      ? price
      : price / (1 - discountPercentage / 100);

  @override
  List<Object?> get props => [id, title, price, thumbnail, stock];
}
