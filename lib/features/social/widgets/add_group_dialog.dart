import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/features/social/screens/create_group_screen.dart';
import 'package:rating/features/social/screens/join_group_screen.dart';

class AddGroupDialog extends StatelessWidget {
  const AddGroupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    void cancel() {
      Navigator.pop(context);
    }

    void createGroup() {
      Navigator.pop(context);
      Navigator.pushNamed(context, CreateGroupScreen.routeName);
    }

    void joinGroup() {
      Navigator.pop(context);
      Navigator.pushNamed(context, JoinGroupScreen.routeName);
    }

    return PlatformAlertDialog(
      title: const Text("Gruppe hinzufügen"),
      content: const Text("Möchtest du einer Gruppe beitreten oder eine neue erstellen?"),
      actions: [
        PlatformDialogAction(
          child: const Text("Beitreten"),
          onPressed: () => joinGroup(),
        ),
        PlatformDialogAction(
          child: const Text("Erstellen"),
          onPressed: () => createGroup(),
        ),
        PlatformDialogAction(
          child: const Text("Abbrechen"),
          onPressed: () => cancel(),
        ),
      ],
    );
  }
}
