import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/ratings/screens/choose_category_screen.dart';
import 'package:rating/features/core/screens/app_scaffold.dart';

class ChangeCategoryDialog extends StatelessWidget {
  const ChangeCategoryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    void changeCategory() {
      Navigator.popUntil(context, ModalRoute.withName(AppScaffold.routeName));
      Navigator.pushNamed(context, ChooseCategoryScreen.routeName);
    }

    return PlatformAlertDialog(
      title: const Text("Kategorie wechseln"),
      content: const Text("Möchtest du die Kategorie wirklich wechseln? Die bisherigen Änderungen gehen verloren."),
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
          onPressed: () => Navigator.pop(context),
        ),
        PlatformDialogAction(
          child: const Text("Wechseln"),
          onPressed: () => changeCategory(),
        ),
      ],
    );
  }
}
