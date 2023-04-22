import 'package:rating/features/ratings/services/item.dart';
import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final String groupId;
  final String name;
  final String? description;
  List<Item> items;

  Category({required this.groupId, required this.name, this.description, List<Item>? ratings})
      : id = "category--${const Uuid().v4()}",
        items = ratings ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'name': name,
      'description': description,
      'items': items.map((rating) => rating.toJson()).toList(),
    };
  }

  Category.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? "",
        groupId = json['groupId'] ?? "",
        name = json['name'] ?? "",
        description = json['description'],
        items = ((json['items'] ?? []) as List).map((e) => Item.fromJson(e)).toList();
}
