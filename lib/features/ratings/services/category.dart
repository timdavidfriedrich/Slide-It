import 'package:provider/provider.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/ratings/services/item.dart';
import 'package:rating/features/social/services/group.dart';
import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final String groupId;
  final String name;
  String? description;
  List<Item> items;

  Category({required this.groupId, required this.name, this.description, List<Item>? ratings})
      : id = "category--${const Uuid().v4()}",
        items = ratings ?? [];

  Category.empty()
      : id = "empty-category--${const Uuid().v4()}",
        groupId = "unknown",
        name = "Empty",
        items = [];

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

  Group get group {
    final List<Group> userGroups = Provider.of<DataProvider>(Global.context, listen: false).userGroups;
    for (Group g in userGroups) {
      if (g.id != groupId) continue;
      return g;
    }
    return Group.empty();
  }
}
