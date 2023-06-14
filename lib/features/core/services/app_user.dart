import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/constants/global.dart';

class AppUser {
  String id;
  String? name;
  String? avatarUrl;
  bool isBlocked;
  // List<String> firebaseMessagingTokens;
  List<String> groupIds;

  static AppUser? current;

  AppUser({
    required this.id,
    this.name = "Unbenannt",
    this.avatarUrl,
    this.isBlocked = false,
    // this.firebaseMessagingTokens = const [],
    this.groupIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'isBlocked': isBlocked,
      // ! only gets called when the user is signed in for the first time (or when the user data is deleted)
      // ! => token is always the same and no newer tokens are added
      // TODO: Implement a way to update the token.
      // 'firebaseMessagingTokens': firebaseMessagingTokens,
      'groupIds': groupIds,
    };
  }

  AppUser.empty() : this(id: "empty");

  AppUser.fromJson(Map<String, dynamic>? json)
      : id = json?['id'] ?? "",
        name = json?['name'],
        avatarUrl = json?['avatarUrl'],
        isBlocked = json?['isBlocked'] ?? false,
        // firebaseMessagingTokens = ((json?['firebaseMessagingTokens'] ?? []) as List<dynamic>).map((e) => e.toString()).toList(),
        groupIds = ((json?['groupIds'] ?? []) as List<dynamic>).map((e) => e.toString()).toList();

  Widget getAvatar({double? radius}) {
    bool hasAvatar = avatarUrl != null;
    return CircleAvatar(
      radius: radius,
      backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
      child: hasAvatar ? null : Icon(PlatformIcons(Global.context).person, size: radius),
    );
  }

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

  @override
  String toString() {
    return "AppUser(id: $id, name: $name, avatarUrl: $avatarUrl, isBlocked: $isBlocked, groupIds: $groupIds)";
  }
}
