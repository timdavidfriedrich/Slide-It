import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/services/app_scaffold_arguments.dart';
import 'package:rating/features/ratings/providers/selected_provider.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/screens/app_scaffold.dart';
import 'package:rating/features/social/screens/profile_screen.dart';
import 'package:rating/features/social/services/group.dart';

class ChooseGroupScreen extends StatelessWidget {
  static const routeName = "/ChooseGroup";

  const ChooseGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Group> userGroups = Provider.of<DataProvider>(context).userGroups;

    void chooseGroup(Group group) {
      Provider.of<SelectedProvider>(context, listen: false).selectGroup(group);
      Navigator.pop(context);
    }

    void addGroup() {
      Navigator.pushNamedAndRemoveUntil(context, AppScaffold.routeName, (route) => false,
          arguments: const AppScaffoldArguments(selectedScreen: ProfileScreen()));
    }

    void cancel() {
      Navigator.popUntil(context, ModalRoute.withName(AppScaffold.routeName));
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
                        leading: group.avatar,
                        title: Text(group.name),
                        subtitle: Text(group.users.length == 1 ? "1 Mitglied" : "${group.users.length} Mitglieder"),
                        onTap: () => chooseGroup(group),
                      ),
                    ),
                  Card(
                    child: ListTile(
                      leading: Icon(PlatformIcons(context).add),
                      title: const Text("Neue Gruppe erstellen"),
                      onTap: () => addGroup(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Constants.mediumPadding),
            PlatformElevatedButton(onPressed: () => cancel(), child: const Text("Abbrechen")),
            const SizedBox(height: Constants.largePadding),
          ],
        ),
      ),
    );
  }
}
