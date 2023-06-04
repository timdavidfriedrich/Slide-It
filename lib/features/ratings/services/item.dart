import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/ratings/services/category.dart';
import 'package:rating/features/ratings/services/rating.dart';
import 'package:rating/features/social/services/app_user.dart';
import 'package:rating/features/social/services/group.dart';
import 'package:uuid/uuid.dart';

class Item {
  final String id;
  final String categoryId;
  final String name;
  String? createdByUserId;
  Timestamp createdAt;
  String? imageUrl;
  List<Rating> ratings;

  Item({required this.categoryId, required this.name, List<Rating>? ratings})
      : id = "item--${const Uuid().v4()}",
        ratings = ratings ?? [],
        createdByUserId = AppUser.currentUser?.uid,
        createdAt = Timestamp.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch);

  Item.withRating({required this.categoryId, required this.name, required Rating rating})
      : id = "item--${const Uuid().v4()}",
        ratings = [rating],
        createdByUserId = AppUser.currentUser?.uid,
        createdAt = Timestamp.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch);

  Item.empty()
      : id = "empty-item--${const Uuid().v4()}",
        categoryId = "unknown",
        name = "Empty",
        ratings = [],
        createdByUserId = AppUser.currentUser?.uid,
        createdAt = Timestamp.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'imageUrl': imageUrl,
      'ratings': ratings.map((rating) => rating.toJson()).toList(),
      'createdByUserId': createdByUserId,
      'createdAt': createdAt,
    };
  }

  Item.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? "",
        categoryId = json['categoryId'] ?? "",
        name = json['name'] ?? "",
        imageUrl = json['imageUrl'],
        ratings = ((json['ratings'] ?? []) as List).map((rating) => Rating.fromJson(rating)).toList(),
        createdByUserId = json['createdByUserId'],
        createdAt = json['createdAt'] ?? Timestamp.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch);

  double get averageRating {
    if (ratings.isEmpty) return 0.0;
    double sum = 0.0;
    for (Rating r in ratings) {
      sum += r.value;
    }
    return sum / ratings.length;
  }

  Widget get image {
    if (imageUrl == null) return const Placeholder();
    return FittedBox(fit: BoxFit.cover, clipBehavior: Clip.hardEdge, child: Image.network(imageUrl!));
  }

  Rating? get ownRating {
    Rating? result;
    User? user = AppUser.currentUser;
    if (ratings.isEmpty) return null;
    if (user == null) return null;
    for (Rating r in ratings) {
      if (r.userId != user.uid) continue;
      result = r;
    }
    return result;
  }

  Category get category {
    final List<Group> userGroups = Provider.of<DataProvider>(Global.context, listen: false).userGroups;
    for (Group g in userGroups) {
      for (Category c in g.categories) {
        if (c.id != categoryId) continue;
        return c;
      }
    }
    return Category.empty();
  }

  Group get group {
    final List<Group> userGroups = Provider.of<DataProvider>(Global.context, listen: false).userGroups;
    for (Group g in userGroups) {
      for (Category c in g.categories) {
        if (c.id != categoryId) continue;
        return g;
      }
    }
    return Group.empty();
  }
}
