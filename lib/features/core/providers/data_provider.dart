import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rating/features/core/services/cloud_service.dart';
import 'package:rating/features/core/services/group.dart';

class DataProvider extends ChangeNotifier {
  List<Group> allGroups = [];
  final List<Group> _userGroups = [];
  List<Group> get userGroups => _userGroups;

  Future<void> loadData() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    allGroups = await CloudService.getGroupData();
    String userId = FirebaseAuth.instance.currentUser!.uid;
    for (Group group in allGroups) {
      if (group.users.contains(userId)) {
        _userGroups.add(group);
      }
    }
    notifyListeners();
  }

  void addGroup(Group group) {
    _userGroups.add(group);
    notifyListeners();
  }

  void removeGroup(Group group) {
    _userGroups.remove(group);
    notifyListeners();
  }

  void clearGroups() {
    _userGroups.clear();
    notifyListeners();
  }
}
