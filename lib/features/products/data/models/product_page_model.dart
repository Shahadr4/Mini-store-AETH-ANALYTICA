import '../../domain/entities/product_page.dart';
import 'product_model.dart';

/// Response shape of every list endpoint: `{products, total, skip, limit}`.
class ProductPageModel extends ProductPage {
  const ProductPageModel({required super.products, required super.total});

  factory ProductPageModel.fromJson(Map<String, dynamic> json) =>
      ProductPageModel(
        products: (json['products'] as List<dynamic>? ?? const [])
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: (json['total'] as num?)?.toInt() ?? 0,
      );
}
