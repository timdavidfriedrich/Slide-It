import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/utils/shell_content.dart';
import 'package:rating/features/social/screens/group/group_screen.dart';
import 'package:rating/features/social/models/group.dart';
import 'package:rating/features/social/widgets/add_group_dialog.dart';
import 'package:rating/features/social/widgets/profile_card.dart';

class SocialScreen extends StatefulWidget implements ShellContent {
  static const routeName = "/social";
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();

  @override
  String get displayName => "Soziales";

  @override
  Icon get icon {
    bool isIos = Theme.of(Global.context).platform == TargetPlatform.iOS;
    bool isMacOs = Theme.of(Global.context).platform == TargetPlatform.macOS;
    return isIos || isMacOs ? cupertinoIcon : materialIcon;
  }

  @override
  Icon get materialIcon => const Icon(Icons.group_outlined);

  @override
  Icon get cupertinoIcon => const Icon(CupertinoIcons.group);
}

class _SocialScreenState extends State<SocialScreen> {
  void _goToGroupDetails(Group group) {
    context.push(GroupScreen.routeName, extra: group);
  }

  void _addGroup() {
    showDialog(context: context, builder: (context) => const AddGroupDialog());
  }

  @override
  Widget build(BuildContext context) {
    List<Group> userGroups = Provider.of<DataProvider>(context).userGroups;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
        children: [
          const ProfileCard(),
          const SizedBox(height: Constants.mediumPadding),
          Text("Meine Gruppen", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: Constants.smallPadding),
          const SizedBox(height: Constants.normalPadding),
          for (Group group in userGroups)
            Card(
              // ? Keep color ?
              // color: group.color,
              margin: const EdgeInsets.only(bottom: Constants.smallPadding),
              child: ListTile(
                onTap: () => _goToGroupDetails(group),
                leading: group.avatar,
                title: Text(group.name),
                subtitle: Text(group.users.length == 1 ? "1 Mitglied" : "${group.users.length} Mitglieder"),
              ),
            ),
          TextButton.icon(
            onPressed: () => _addGroup(),
            icon: Icon(PlatformIcons(context).add),
            label: const Text("Gruppe hinzufügen"),
          ),
          const SizedBox(height: Constants.mediumPadding),
        ],
      ),
    );
  }
}
