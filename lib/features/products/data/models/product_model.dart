import '../../domain/entities/product.dart';
import 'review_model.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.price,
    required super.discountPercentage,
    required super.rating,
    required super.stock,
    required super.brand,
    required super.availabilityStatus,
    required super.thumbnail,
    required super.images,
    required super.reviews,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final stock = (json['stock'] as num?)?.toInt() ?? 0;
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: stock,
      brand: json['brand'] as String?,
      availabilityStatus:
          json['availabilityStatus'] as String? ??
          (stock > 0 ? 'In Stock' : 'Out of Stock'),
      thumbnail: json['thumbnail'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      reviews: (json['reviews'] as List<dynamic>? ?? const [])
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
