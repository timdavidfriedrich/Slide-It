import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/services/firebase/cloud_service.dart';

class CreateGroupDialog extends StatelessWidget {
  const CreateGroupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    void cancel() {
      Navigator.of(context).pop();
    }

    void create() {
      CloudService.createGroup(nameController.text);
      Navigator.of(context).pop();
    }

    return PlatformAlertDialog(
      title: const Text("Gruppe erstellen"),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(
          labelText: "Name der Gruppe",
        ),
      ),
      material: (context, platform) {
        return MaterialAlertDialogData(
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: Constants.normalPadding,
            vertical: Constants.smallPadding,
          ),
        );
      },
      actions: [
        PlatformDialogAction(
          child: const Text("Abbrechen"),
          onPressed: () => cancel(),
        ),
        PlatformDialogAction(
          child: const Text("Erstellen"),
          onPressed: () => create(),
        ),
      ],
    );
  }
}
