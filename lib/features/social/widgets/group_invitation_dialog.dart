import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/social/services/group.dart';

class GroupInvitationDialog extends StatelessWidget {
  final Group group;
  const GroupInvitationDialog({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    void close() {
      Navigator.pop(context);
    }

    return PlatformAlertDialog(
      title: const Text("Einladen"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: Constants.normalPadding),
          const AspectRatio(aspectRatio: 1 / 1, child: Placeholder()),
          const SizedBox(height: Constants.normalPadding),
          Text("ID: ${group.id}"),
        ],
      ),
      actions: [
        PlatformDialogAction(
          onPressed: () => close(),
          child: const Text("Schließen"),
        ),
      ],
    );
  }
}
