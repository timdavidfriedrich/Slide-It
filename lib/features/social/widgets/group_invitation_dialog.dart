import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/social/models/group.dart';

class GroupInvitationDialog extends StatelessWidget {
  final Group group;
  const GroupInvitationDialog({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    void copyGroupId() async {
      await Clipboard.setData(ClipboardData(text: group.id));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gruppen-ID wurde in die Zwischenablage kopiert."),
          duration: Duration(seconds: 5),
        ),
      );
    }

    void close() {
      context.pop();
    }

    return PlatformAlertDialog(
      title: const Text("Einladen"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: Constants.smallPadding),
          Flexible(
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: QrImageView(
                data: group.id,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          ),
          const SizedBox(height: Constants.smallPadding),
          Row(
            children: [
              Flexible(
                child: SelectableText(
                  group.id,
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(width: Constants.smallPadding),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: copyGroupId,
              ),
            ],
          ),
        ],
      ),
      actions: [
        PlatformDialogAction(
          onPressed: close,
          child: const Text("Schließen"),
        ),
      ],
    );
  }
}
