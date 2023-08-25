import 'package:flutter/material.dart';
import 'package:log/log.dart';
import 'package:rating/features/ratings/models/category.dart';
import 'package:rating/features/core/services/data/cloud_data_service.dart';
import 'package:rating/features/ratings/models/item.dart';
import 'package:rating/features/core/models/app_user.dart';
import 'package:rating/features/social/models/group.dart';
import 'package:rating/features/ratings/models/rating.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the local data for the app to minimize the amount of requests to the cloud.
/// Note, that this is only temporary data.
class DataProvider extends ChangeNotifier {
  late SharedPreferences sharedPreferences;

  Group? _selectedGroup;
  List<Group> userGroups = [];
  List<AppUser> knownUsers = [];
  bool _dataHasBeenInitialized = false;

  bool get dataHasBeenInitialized => _dataHasBeenInitialized;

  Group? get selectedGroup => _selectedGroup;

  int refreshCounter = 0;

  Future<void> loadData() async {
    await CloudService.instance.loadUserData();
    userGroups = await CloudService.instance.getUserGroups();
    knownUsers = await CloudService.instance.getKnownUsers();
    _dataHasBeenInitialized = true;
    initSelectedGroup();
    notifyListeners();
    Log.hint("Loaded ${userGroups.length} groups to runtime storage.");
  }

  void initSelectedGroup() async {
    if (userGroups.isEmpty) return;
    sharedPreferences = await SharedPreferences.getInstance();
    String? selectedGroupId = sharedPreferences.getString("selectedGroup");
    if (selectedGroupId != null) {
      selectGroup(getGroupById(selectedGroupId));
      return;
    }
    selectGroup(userGroups.first);
  }

  Future<void> reloadData() async {
    await CloudService.instance.loadRawData();
    await loadData();
    notifyListeners();
  }

  void selectGroup(Group group) async {
    _selectedGroup = group;
    notifyListeners();
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString("selectedGroup", _selectedGroup?.id ?? "");
    Log.hint("Selected Group \"${group.name}\" (ID: ${group.id}).");
  }

  AppUser? getAppUserById(String? id) {
    if (id == null) return null;
    try {
      return knownUsers.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Category> getCategoriesFromGroup(Group group) {
    if (userGroups.isEmpty) return [];
    return userGroups.firstWhere((element) => element.id == group.id).categories;
  }

  Group getGroupById(String groupId) {
    if (userGroups.isEmpty) return Group.empty();
    try {
      return userGroups.firstWhere((element) => element.id == groupId);
    } catch (e) {
      return Group.empty();
    }
  }

  Group getGroupFromCategory(Category category) {
    if (userGroups.isEmpty) return Group.empty();
    return userGroups.firstWhere((element) => element.id == category.groupId);
  }

  void addGroup(Group group) {
    userGroups.add(group);
    notifyListeners();
    Log.hint("Added Group \"${group.name}\" (ID: ${group.id}) to runtime storage.");
  }

  void addGroupById(String groupId) {
    userGroups.add(getGroupById(groupId));
    notifyListeners();
    Log.hint("Added Group by ID $groupId to runtime storage.");
  }

  void removeGroup(Group group) {
    userGroups.remove(group);
    notifyListeners();
    Log.hint("Removed Group \"${group.name}\" (ID: ${group.id}) from runtime storage.");
  }

  void clearGroups() {
    _selectedGroup = null;
    userGroups.clear();
    notifyListeners();
    Log.hint("Cleared all groups from runtime storage.");
  }

  void addCategory({required Group group, required Category category}) {
    userGroups.firstWhere((element) => element.id == group.id).categories.add(category);
    notifyListeners();
    Log.hint("Added Category \"${category.name}\" (ID: ${category.id}) to runtime storage.");
  }

  void removeCategory(Category category) {
    for (Group g in userGroups) {
      if (g.id != category.groupId) continue;
      g.categories.remove(category);
      notifyListeners();
      Log.hint("Removed Category \"${category.name}\" (ID: ${category.id}) from runtime storage.");
    }
  }

  void addItem({required Category category, required Item item}) {
    for (Group g in userGroups) {
      if (g.id != category.groupId) continue;
      for (Category c in g.categories) {
        if (c.id != category.id) continue;
        c.items.add(item);
        notifyListeners();
        Log.hint("Added item \"${item.name}\" (ID: ${item.id}) to runtime storage.");
      }
    }
  }

  void editItem({required Category category, required Item item, String? name, String? imageUrl}) {
    for (Group g in userGroups) {
      if (g.id != category.groupId) continue;
      for (Category c in g.categories) {
        if (c.id != category.id) continue;
        for (Item i in c.items) {
          if (i.id != item.id) continue;
          i.name = name ?? i.name;
          i.firebaseImageUrl = imageUrl;
          notifyListeners();
          Log.hint("Edited item \"${item.name}\" (ID: ${item.id}) to runtime storage.");
        }
      }
    }
  }

  void removeItem({required Category category, required Item item}) {
    for (Group g in userGroups) {
      if (g.id != category.groupId) continue;
      for (Category c in g.categories) {
        if (c.id != category.id) continue;
        c.items.remove(item);
        notifyListeners();
        Log.hint("Removed item \"${item.name}\" (ID: ${item.id}) from runtime storage.");
      }
    }
  }

  void addRating({required Category category, required Rating rating}) {
    for (Group g in userGroups) {
      if (g.id != category.groupId) continue;
      for (Category c in g.categories) {
        if (c.id != category.id) continue;
        for (Item i in c.items) {
          if (i.id != rating.itemId) continue;
          i.ratings.add(rating);
          notifyListeners();
          Log.hint("Added Rating (ID: ${rating.id}) to an item (Item ID: ${rating.itemId}) to runtime storage.");
        }
      }
    }
  }

  void editRating({required Category category, required Rating rating, required double value, required String? comment}) {
    for (Group g in userGroups) {
      if (g.id != category.groupId) continue;
      for (Category c in g.categories) {
        if (c.id != category.id) continue;
        for (Item i in c.items) {
          if (i.id != rating.itemId) continue;
          for (int r = 0; r < i.ratings.length; r++) {
            if (i.ratings[r].id != rating.id) continue;
            i.ratings[r].value = value;
            i.ratings[r].comment = comment;
            notifyListeners();
            Log.hint("Edited Rating (ID: ${rating.id}) of an item (Item ID: ${rating.itemId}) and saved changes to runtime storage.");
          }
        }
      }
    }
  }

  void removeRating({required Category category, required Rating rating}) {
    for (Group g in userGroups) {
      if (g.id != category.groupId) continue;
      for (Category c in g.categories) {
        if (c != category) continue;
        for (Item i in c.items) {
          if (i.id != rating.itemId) continue;
          i.ratings.remove(rating);
          notifyListeners();
          Log.hint("Removed Rating (ID: ${rating.id}) from an item (Item ID: ${rating.itemId}) from runtime storage.");
        }
      }
    }
  }
}
