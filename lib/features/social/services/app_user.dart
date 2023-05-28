import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/constants/global.dart';

class AppUser {
  static Widget get currentAvatar {
    final User? user = FirebaseAuth.instance.currentUser;
    bool hasAvatar = user != null && user.photoURL != null;
    return CircleAvatar(
      backgroundImage: hasAvatar ? NetworkImage(user.photoURL!) : null,
      child: hasAvatar ? null : Icon(PlatformIcons(Global.context).person),
    );
  }

  static User? get currentUser {
    return FirebaseAuth.instance.currentUser;
  }

  List<String> firebaseMessagingTokens = [];
  List<String> groupIds = [];

  // AppUser({required this.groupIds});

  AppUser.fromJson(Map<String, dynamic> json) {
    for (String groupId in json['groups']) {
      groupIds.add(groupId);
    }
  }
}
