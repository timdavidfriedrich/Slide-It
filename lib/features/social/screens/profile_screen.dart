import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/services/screen.dart';
import 'package:rating/features/social/services/group.dart';
import 'package:rating/features/social/widgets/create_group_dialog.dart';
import 'package:rating/features/social/widgets/profile_card.dart';

class ProfileScreen extends StatefulWidget implements Screen {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();

  @override
  String get displayName => "Soziales";

  @override
  Icon get icon {
    bool isIos = Theme.of(Global.context).platform == TargetPlatform.iOS;
    bool isMacOs = Theme.of(Global.context).platform == TargetPlatform.macOS;
    return isIos || isMacOs ? cupertinoIcon : materialIcon;
  }

  @override
  Icon get materialIcon => const Icon(Icons.person_outlined);

  @override
  Icon get cupertinoIcon => const Icon(CupertinoIcons.person);
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _createGroup() {
    showDialog(context: context, builder: (context) => const CreateGroupDialog());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
        children: [
          const SizedBox(height: Constants.normalPadding),
          Text("Mein Profil", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: Constants.smallPadding),
          const ProfileCard(),
          const SizedBox(height: Constants.mediumPadding),
          Text("Meine Gruppen", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: Constants.smallPadding),
          PlatformElevatedButton(
            onPressed: () => _createGroup(),
            child: const Text("Gruppe erstellen"),
          ),
          const SizedBox(height: Constants.normalPadding),
          for (Group group in Provider.of<DataProvider>(context).userGroups)
            Card(
              // ? Keep color ?
              // color: group.color,
              child: ListTile(
                leading: group.avatar,
                title: Text(group.name),
                subtitle: Text(group.users.length == 1 ? "1 Mitglied" : "${group.users.length} Mitglieder"),
              ),
            ),
          const SizedBox(height: Constants.mediumPadding),
        ],
      ),
    );
  }
}