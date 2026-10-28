import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({required super.slug, required super.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    slug: json['slug'] as String,
    name: json['name'] as String? ?? json['slug'] as String,
  );
}
