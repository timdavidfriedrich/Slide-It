import 'package:rating/features/ratings/services/rating.dart';
import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final String groupId;
  final String name;
  final String? description;
  List<Rating> ratings;

  Category({required this.groupId, required this.name, this.description, List<Rating>? ratings})
      : id = "category--${const Uuid().v4()}",
        ratings = ratings ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'name': name,
      'description': description,
      'ratings': ratings.map((rating) => rating.toJson()).toList(),
    };
  }

  Category.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        groupId = json['groupId'],
        name = json['name'],
        description = json['description'],
        ratings = (json['ratings'] as List).map((rating) => Rating.fromJson(rating)).toList();
}
