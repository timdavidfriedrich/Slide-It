import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/services/firebase/auth_service.dart';
import 'package:rating/features/social/services/app_user.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = AppUser.user;

    void signOut() {
      AuthService.signOut();
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Constants.normalPadding, vertical: Constants.smallPadding),
      leading: CircleAvatar(
        backgroundImage: user != null && user.photoURL != null ? NetworkImage(user.photoURL!) : null,
        child: user != null && user.photoURL != null ? null : Icon(PlatformIcons(context).person),
      ),
      title: Text(user?.displayName ?? "Unbenannt"),
      subtitle: Text(user?.email ?? "Nicht angemeldet."),
      trailing: PlatformIconButton(
        onPressed: () => signOut(),
        icon: Icon(PlatformIcons(context).forward),
      ),
    );
  }
}
