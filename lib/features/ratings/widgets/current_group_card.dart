import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/services/data/data_provider.dart';
import 'package:rating/features/ratings/screens/group/choose_group_screen.dart';
import 'package:rating/features/social/models/group.dart';
import 'package:rating/features/social/screens/group/group_screen.dart';

class CurrentGroupCard extends StatelessWidget {
  const CurrentGroupCard({super.key});

  @override
  Widget build(BuildContext context) {
    final Group? currentGroup = Provider.of<DataProvider>(context).selectedGroup;

    void changeGroup() {
      context.push(ChooseGroupScreen.routeName);
    }

    void showCurrentGroupInfos() {
      if (currentGroup == null) return;
      context.push(GroupScreen.routeName, extra: currentGroup);
    }

    return Card(
      margin: EdgeInsets.zero,
      child: currentGroup == null
          ? ListTile(
              tileColor: Theme.of(context).colorScheme.secondary,
              titleAlignment: ListTileTitleAlignment.center,
              title: Text(
                "Gruppe auswählen",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              onTap: () => changeGroup(),
            )
          : ListTile(
              contentPadding: const EdgeInsets.only(
                left: Constants.normalPadding,
                right: Constants.smallPadding,
              ),
              leading: currentGroup.avatar,
              title: Text(currentGroup.name),
              subtitle: const Text("(Tippen zum wechseln)"),
              trailing: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => showCurrentGroupInfos(),
                icon: Icon(PlatformIcons(context).info),
              ),
              onTap: () => changeGroup(),
            ),
    );
  }
}
