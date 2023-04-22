import 'package:rating/features/ratings/services/rating.dart';
import 'package:uuid/uuid.dart';

class Item {
  final String id;
  final String categoryId;
  final String name;
  List<Rating> ratings;

  Item({required this.categoryId, required this.name, List<Rating>? ratings})
      : id = "item--${const Uuid().v4()}",
        ratings = ratings ?? [];

  Item.withRating({required this.categoryId, required this.name, required Rating rating})
      : id = "item--${const Uuid().v4()}",
        ratings = [rating];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'ratings': ratings.map((rating) => rating.toJson()).toList(),
    };
  }

  Item.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? "",
        categoryId = json['categoryId'] ?? "",
        name = json['name'] ?? "",
        ratings = ((json['ratings'] ?? []) as List).map((rating) => Rating.fromJson(rating)).toList();

  double get averageRating {
    if (ratings.isEmpty) return 0.0;
    double sum = 0.0;
    for (Rating rating in ratings) {
      sum += rating.value;
    }
    return sum / ratings.length;
  }
}
