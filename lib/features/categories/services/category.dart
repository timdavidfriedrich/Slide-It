import 'package:rating/features/core/services/rating.dart';
import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final String name;
  final String? description;
  List<Rating> ratings;

  Category({required this.name, this.description, List<Rating>? ratings})
      : id = const Uuid().v4(),
        ratings = ratings ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ratings': ratings.map((rating) => rating.toJson()).toList(),
    };
  }

  Category.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        ratings = (json['ratings'] as List).map((rating) => Rating.fromJson(rating)).toList();
}
