import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/constants/global.dart';

class AppUser {
  static Widget get avatar {
    final User? user = FirebaseAuth.instance.currentUser;
    bool hasAvatar = user != null && user.photoURL != null;
    return CircleAvatar(
      backgroundImage: hasAvatar ? NetworkImage(user.photoURL!) : null,
      child: hasAvatar ? null : Icon(PlatformIcons(Global.context).person),
    );
  }

  static User? get user {
    return FirebaseAuth.instance.currentUser;
  }

}