import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/constants/constants.dart';

class JoinGroupDialog extends StatelessWidget {
  const JoinGroupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformAlertDialog(
      title: const Text("Gruppe beitreten"),
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        PlatformDialogAction(
          child: const Text("Beitreten"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
