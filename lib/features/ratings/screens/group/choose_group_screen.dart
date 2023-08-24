import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/services/data/data_provider.dart';
import 'package:rating/features/social/screens/group/group_screen.dart';
import 'package:rating/features/social/models/group.dart';
import 'package:rating/features/social/widgets/add_group_dialog.dart';

class ChooseGroupScreen extends StatelessWidget {
  static const routeName = "/ChooseGroup";

  const ChooseGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Group> userGroups = Provider.of<DataProvider>(context).userGroups;

    void chooseGroup(Group group) {
      Provider.of<DataProvider>(context, listen: false).selectGroup(group);
      context.pop();
    }

    void showCurrentGroupInfos(Group group) {
      context.push(GroupScreen.routeName, extra: group);
    }

    void addGroup() {
      showDialog(context: context, builder: (context) => const AddGroupDialog());
    }

    void cancel() {
      context.pop();
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: Constants.largePadding),
            Text("Wähle eine Gruppe", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: Constants.mediumPadding),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
                children: [
                  for (Group group in userGroups)
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.only(
                          left: Constants.normalPadding,
                          right: Constants.smallPadding,
                        ),
                        leading: group.avatar,
                        title: Text(group.name),
                        subtitle: Text(group.users.length == 1 ? "1 Mitglied" : "${group.users.length} Mitglieder"),
                        trailing: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => showCurrentGroupInfos(group),
                          icon: Icon(PlatformIcons(context).info),
                        ),
                        onTap: () => chooseGroup(group),
                      ),
                    ),
                  const SizedBox(height: Constants.normalPadding),
                  TextButton.icon(
                    onPressed: () => addGroup(),
                    icon: Icon(PlatformIcons(context).add),
                    label: const Text("Gruppe hinzufügen"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Constants.mediumPadding),
            ElevatedButton(onPressed: () => cancel(), child: const Text("Abbrechen")),
            const SizedBox(height: Constants.largePadding),
          ],
        ),
      ),
    );
  }
}
