import 'package:flutter/material.dart';
import 'package:rating/features/core/services/cloud_service.dart';
import 'package:rating/features/core/services/group.dart';

class DataProvider extends ChangeNotifier {
  List<Group> _groups = [];
  List<Group> get groups => _groups;

  Future<void> loadData() async {
    _groups = await CloudService.getGroupData();
    notifyListeners();
  }

  void addGroup(Group group) {
    _groups.add(group);
    notifyListeners();
  }

  void removeGroup(Group group) {
    _groups.remove(group);
    notifyListeners();
  }

  void clearGroups() {
    _groups.clear();
    notifyListeners();
  }
}
