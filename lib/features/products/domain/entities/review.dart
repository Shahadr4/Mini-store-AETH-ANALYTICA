import 'package:equatable/equatable.dart';

class Review extends Equatable {
  const Review({
    required this.reviewerName,
    required this.rating,
    required this.comment,
  });

  final String reviewerName;
  final int rating;
  final String comment;

  @override
  List<Object?> get props => [reviewerName, rating, comment];
}
