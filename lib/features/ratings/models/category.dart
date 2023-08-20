import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:provider/provider.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/services/data/data_provider.dart';
import 'package:rating/features/ratings/models/item.dart';
import 'package:rating/features/core/models/app_user.dart';
import 'package:rating/features/social/models/group.dart';
import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final String groupId;
  final String name;
  String? description;
  List<Item> items;
  String? createdByUserId;
  Timestamp createdAt;

  Category({required this.groupId, required this.name, this.description, List<Item>? ratings})
      : id = "category--${const Uuid().v4()}",
        items = ratings ?? [],
        createdByUserId = AppUser.currentUser?.uid,
        createdAt = Timestamp.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch);

  Category.empty()
      : id = "empty-category--${const Uuid().v4()}",
        groupId = "unknown",
        name = "Empty",
        items = [],
        createdByUserId = AppUser.currentUser?.uid,
        createdAt = Timestamp.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'name': name,
      'description': description,
      'items': items.map((rating) => rating.toJson()).toList(),
      'createdByUserId': createdByUserId,
      'createdAt': createdAt,
    };
  }

  Category.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? "",
        groupId = json['groupId'] ?? "",
        name = json['name'] ?? "",
        description = json['description'],
        items = ((json['items'] ?? []) as List).map((e) => Item.fromJson(e)).toList(),
        createdByUserId = json['createdByUserId'],
        createdAt = json['createdAt'] ?? Timestamp.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch);

  Group get group {
    final List<Group> userGroups = Provider.of<DataProvider>(Global.context, listen: false).userGroups;
    for (Group g in userGroups) {
      if (g.id != groupId) continue;
      return g;
    }
    return Group.empty();
  }
}
