import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/services/data/data_provider.dart';
import 'package:rating/features/core/services/notification_service.dart';
import 'package:rating/features/social/models/group.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences sharedPreferences;

  int _numberOfDecimals = 1;
  bool _dynamicRatingColorEnabled = true;
  bool _dontAskForLocation = false;
  bool _allowNotifications = true;
  List<String> _mutedGroupIds = [];

  get maxRatingValueDecimal => null;

  set numberOfDecimals(int numberOfDecimals) {
    _numberOfDecimals = numberOfDecimals;
    save();
    notifyListeners();
  }

  set dynamicRatingColorEnabled(bool dynamicRatingColorEnabled) {
    _dynamicRatingColorEnabled = dynamicRatingColorEnabled;
    save();
    notifyListeners();
  }

  set dontAskForLocation(bool dontAskForLocation) {
    _dontAskForLocation = dontAskForLocation;
    save();
    notifyListeners();
  }

  set allowNotifications(bool allowNotifications) {
    _allowNotifications = allowNotifications;
    if (_allowNotifications) {
      _initNotifications();
    } else {
      _unsubscribeFromAll();
    }
    save();
    notifyListeners();
  }

  void muteGroupWithId(String groupId) {
    _mutedGroupIds.add(groupId);
    save();
    notifyListeners();
  }

  void unmuteGroupWithId(String groupId) {
    _mutedGroupIds.remove(groupId);
    save();
    notifyListeners();
  }

  int get numberOfDecimals => _numberOfDecimals;
  bool get dynamicRatingColorEnabled => _dynamicRatingColorEnabled;
  bool get dontAskForLocation => _dontAskForLocation;
  bool get allowNotifications => _allowNotifications;
  List<String> get mutedGroupIds => _mutedGroupIds;

  Future<void> save() async {
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt('numberOfDecimals', _numberOfDecimals);
    await sharedPreferences.setBool('dynamicRatingColorEnabled', _dynamicRatingColorEnabled);
    await sharedPreferences.setBool('dontAskForLocation', _dontAskForLocation);
    await sharedPreferences.setBool('allowNotifications', _allowNotifications);
    await sharedPreferences.setStringList('mutedGroupIds', _mutedGroupIds);
  }

  Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    _numberOfDecimals = sharedPreferences.getInt('numberOfDecimals') ?? _numberOfDecimals;
    _dynamicRatingColorEnabled = sharedPreferences.getBool('dynamicRatingColorEnabled') ?? _dynamicRatingColorEnabled;
    _dontAskForLocation = sharedPreferences.getBool('dontAskForLocation') ?? _dontAskForLocation;
    _allowNotifications = sharedPreferences.getBool('allowNotifications') ?? _allowNotifications;
    _mutedGroupIds = sharedPreferences.getStringList('mutedGroupIds') ?? _mutedGroupIds;
    _initNotifications();
    notifyListeners();
  }

  void _initNotifications() async {
    List<Group> userGroups = Provider.of<DataProvider>(Global.context, listen: false).userGroups;
    if (!_allowNotifications) {
      _unsubscribeFromAll();
      return;
    }
    for (final Group group in userGroups) {
      NotificationService.instance.subscribeToTopic(group.id);
    }
    for (final String groupId in _mutedGroupIds) {
      NotificationService.instance.unsubscribeFromTopic(groupId);
    }
  }

  void _unsubscribeFromAll() {
    List<Group> userGroups = Provider.of<DataProvider>(Global.context, listen: false).userGroups;
    for (final Group group in userGroups) {
      NotificationService.instance.unsubscribeFromTopic(group.id);
    }
  }
}
