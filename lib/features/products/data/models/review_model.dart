import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.reviewerName,
    required super.rating,
    required super.comment,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    reviewerName: json['reviewerName'] as String? ?? 'Anonymous',
    rating: (json['rating'] as num?)?.toInt() ?? 0,
    comment: json['comment'] as String? ?? '',
  );
}
