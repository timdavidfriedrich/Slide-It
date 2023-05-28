import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/widgets/error_info.dart';
import 'package:rating/features/social/services/group.dart';
import 'package:rating/features/social/services/group_screen_arguments.dart';
import 'package:rating/features/social/widgets/group_invitation_dialog.dart';

class GroupScreen extends StatelessWidget {
  static const String routeName = "/Group";
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<Group> getGroup() async {
      GroupScreenArguments arguments = ModalRoute.of(context)!.settings.arguments as GroupScreenArguments;
      return arguments.group;
    }

    void showGroupInvitation(Group group) {
      showDialog(context: context, builder: ((context) => GroupInvitationDialog(group: group)));
    }

    return FutureBuilder(
        future: getGroup(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorInfo(message: snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return const CircularProgressIndicator.adaptive();
          }
          if (snapshot.data is! Group) return const ErrorInfo();
          Group group = snapshot.data as Group;
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text(group.name),
                actions: [
                  IconButton(
                    onPressed: () => showGroupInvitation(group),
                    icon: Icon(PlatformIcons(context).personAdd),
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
                      title: Text(userId),
                    )
                ],
              ),
            ),
          );
        });
  }
}
