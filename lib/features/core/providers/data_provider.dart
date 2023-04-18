import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rating/features/categories/services/category.dart';
import 'package:rating/features/core/services/cloud_service.dart';
import 'package:rating/features/core/services/group.dart';
import 'package:rating/features/core/services/rating.dart';

/// Manages the local data for the app to minimize the amount of requests to the cloud.
/// Note, that this is only temporary data.
class DataProvider extends ChangeNotifier {
  List<Group> groups = [];
  List<Group> get userGroups {
    final List<Group> result = [];
    String userId = FirebaseAuth.instance.currentUser!.uid;
    for (Group g in groups) {
      if (g.users.contains(userId)) {
        result.add(g);
      }
    }
    return result;
  }

  List<Category> getCategoriesFromGroup(Group group) {
    return groups.firstWhere((element) => element.id == group.id).categories;
  }

  Future<void> loadData() async {
    groups = await CloudService.getUserGroupData();
    notifyListeners();
  }

  void addGroup(Group group) {
    groups.add(group);
    notifyListeners();
  }

  void removeGroup(Group group) {
    groups.remove(group);
    notifyListeners();
  }

  void clearGroups() {
    groups.clear();
    notifyListeners();
  }

  void addCategory({required Group group, required Category category}) {
    groups.firstWhere((element) => element.id == group.id).categories.add(category);
    notifyListeners();
  }

  void removeCategory(Category category) {
    for (Group g in groups) {
      g.categories.remove(category);
    }
    notifyListeners();
  }

  void addRating({required Category category, required Rating rating}) {
    for (Group g in groups) {
      for (Category c in g.categories) {
        if (c == category) c.ratings.add(rating);
      }
    }
    notifyListeners();
  }

  void removeRating({required Category category, required Rating rating}) {
    for (Group g in groups) {
      for (Category c in g.categories) {
        if (c == category) c.ratings.remove(rating);
      }
    }
    notifyListeners();
  }
}
