import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:rating/features/social/screens/group/create_group_screen.dart';
import 'package:rating/features/social/screens/group/join_group_screen.dart';

class AddGroupDialog extends StatelessWidget {
  const AddGroupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    void cancel() {
      context.pop();
    }

    void createGroup() {
      context.pop();
      context.push(CreateGroupScreen.routeName);
    }

    void joinGroup() {
      context.pop();
      context.push(JoinGroupScreen.routeName);
    }

    return AlertDialog.adaptive(
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
