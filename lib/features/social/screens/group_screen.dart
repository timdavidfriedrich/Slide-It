import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/services/notification_service.dart';
import 'package:rating/features/social/services/group.dart';
import 'package:rating/features/social/widgets/group_invitation_dialog.dart';

class GroupScreen extends StatelessWidget {
  static const String routeName = "/Group";
  final Group group;
  const GroupScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    void subscribe() {
      NotificationService.instance.subscribeToTopic(group.id);
    }

    void showGroupInvitation(Group group) {
      showDialog(context: context, builder: ((context) => GroupInvitationDialog(group: group)));
    }

    void edit() {
      // context.push(EditGroupScreen.routeName, extra: widget.category);
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(group.name),
          actions: [
            IconButton(
              onPressed: () => showGroupInvitation(group),
              icon: Icon(PlatformIcons(context).personAdd),
            ),
            IconButton(
              onPressed: () => subscribe(),
              icon: Icon(PlatformIcons(context).volumeOff),
            ),
            IconButton(
              onPressed: () => edit(),
              icon: Icon(PlatformIcons(context).edit),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
          children: [
            const SizedBox(height: Constants.mediumPadding),
            Text("Mitglieder:", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: Constants.normalPadding),
            for (String userId in group.users)
              ListTile(
                leading: CircleAvatar(child: Icon(PlatformIcons(context).person)),
                title: Text(Provider.of<DataProvider>(context).getAppUserById(userId)?.name ?? "Unbenannt"),
              )
          ],
        ),
      ),
    );
  }
}
