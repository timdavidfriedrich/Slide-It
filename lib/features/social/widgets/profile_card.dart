import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/services/firebase/auth_service.dart';
import 'package:rating/features/core/services/app_user.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = AppUser.currentUser;
    final AppUser? currentUser = AppUser.current;

    void signOut() {
      Provider.of<DataProvider>(context, listen: false).clearGroups();
      AuthService.instance.signOut();
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Constants.smallPadding, vertical: Constants.smallPadding),
      leading: CircleAvatar(
        backgroundImage: currentUser != null && currentUser.avatarUrl != null ? NetworkImage(currentUser.avatarUrl!) : null,
        child: currentUser != null && currentUser.avatarUrl != null ? null : Icon(PlatformIcons(context).person),
      ),
      title: Text(currentUser?.name ?? "Unbenannt"),
      subtitle: Text(user?.email ?? "Nicht angemeldet."),
      trailing: IconButton(
        onPressed: () => signOut(),
        icon: Icon(PlatformIcons(context).forward),
      ),
    );
  }
}
