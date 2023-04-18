import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/services/firebase/cloud_service.dart';
import 'package:rating/features/social/services/group.dart';

class CreateCategoryDialog extends StatelessWidget {
  final Group group;
  const CreateCategoryDialog({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    void cancel() {
      Navigator.of(context).pop();
    }

    void create() {
      CloudService.createCategory(name: nameController.text, group: group);
      Navigator.of(context).pop();
    }

    return PlatformAlertDialog(
      title: const Text("Kategorie erstellen"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlatformTextField(
            controller: nameController,
            material: (context, platform) {
              return MaterialTextFieldData(
                decoration: const InputDecoration(
                  labelText: "Name der Kategorie",
                  border: OutlineInputBorder(),
                ),
              );
            },
            cupertino: (context, platform) {
              return CupertinoTextFieldData(placeholder: "Name der Kategorie");
            },
          ),
          const SizedBox(height: Constants.normalPadding),
          Text("Gruppe: ${group.name}"),
        ],
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
