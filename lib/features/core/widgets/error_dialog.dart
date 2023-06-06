import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ErrorDialog extends StatelessWidget {
  final String? message;
  const ErrorDialog({super.key, this.message});

  static void show(BuildContext context, {String? message}) {
    showDialog(context: context, builder: (context) => ErrorDialog(message: message));
  }

  @override
  Widget build(BuildContext context) {
    return PlatformAlertDialog(
      title: Align(
          alignment: Alignment.topCenter,
          child: Icon(
            PlatformIcons(context).error,
            color: Theme.of(context).colorScheme.error,
          )),
      content: Text(
        message ?? "Es ist ein Fehler aufgetreten.",
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      actions: [
        PlatformDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Okay"),
        )
      ],
    );
  }
}
