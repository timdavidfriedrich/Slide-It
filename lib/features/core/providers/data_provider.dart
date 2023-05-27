import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:log/log.dart';
import 'package:rating/features/ratings/services/category.dart';
import 'package:rating/features/core/services/firebase/cloud_service.dart';
import 'package:rating/features/ratings/services/item.dart';
import 'package:rating/features/social/services/app_user.dart';
import 'package:rating/features/social/services/group.dart';
import 'package:rating/features/ratings/services/rating.dart';

/// Manages the local data for the app to minimize the amount of requests to the cloud.
/// Note, that this is only temporary data.
class DataProvider extends ChangeNotifier {
  Group? _selectedGroup;
  List<Group> groups = [];
  List<Group> get userGroups {
    final List<Group> result = [];
    final User? user = AppUser.user;
    if (user == null) return result;
    for (Group g in groups) {
      if (!g.users.contains(user.uid)) continue;
      result.add(g);
    }
    return result;
  }

  Group? get selectedGroup => _selectedGroup;

  void selectGroup(Group group) {
    _selectedGroup = group;
    notifyListeners();
  }

  List<Category> getCategoriesFromGroup(Group group) {
    if (groups.isEmpty) return [];
    return groups.firstWhere((element) => element.id == group.id).categories;
  }

  Group getGroupFromCategory(Category category) {
    if (groups.isEmpty) return Group.empty();
    return groups.firstWhere((element) => element.id == category.groupId);
  }

  Future<void> loadData() async {
    groups = await CloudService.getUserGroupData();
    if (userGroups.isEmpty) return;
    _selectedGroup = userGroups.first;
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
    for (Group g in userGroups) {
      if (g.id != category.groupId) continue;
      g.categories.remove(category);
    }
    notifyListeners();
  }

  void addItem({required Category category, required Item item}) {
    for (Group g in userGroups) {
      if (g.id != category.groupId) continue;
      for (Category c in g.categories) {
        if (c.id != category.id) continue;
        c.items.add(item);
      }
      Log.warning("added item:\n${g.toJson()}");
    }
    notifyListeners();
  }

  void removeItem({required Category category, required Item item}) {
    for (Group g in userGroups) {
      if (g.id != category.groupId) continue;
      for (Category c in g.categories) {
        if (c.id != category.id) continue;
        c.items.remove(item);
      }
      Log.warning("removed item:\n${g.toJson()}");
    }
    notifyListeners();
  }

  void addRating({required Category category, required Rating rating}) {
    for (Group g in userGroups) {
      if (g.id != category.groupId) continue;
      for (Category c in g.categories) {
        if (c.id != category.id) continue;
        for (Item i in c.items) {
          if (i.id != rating.itemId) continue;
          i.ratings.add(rating);
        }
      }
      Log.warning("added rating:\n${g.toJson()}");
    }
    notifyListeners();
  }

  void removeRating({required Category category, required Rating rating}) {
    for (Group g in userGroups) {
      if (g.id != category.groupId) continue;
      for (Category c in g.categories) {
        if (c != category) continue;
        for (Item i in c.items) {
          if (i.id != rating.itemId) continue;
          i.ratings.remove(rating);
        }
      }
      Log.warning("removed rating:\n${g.toJson()}");
    }
    notifyListeners();
  }
}
