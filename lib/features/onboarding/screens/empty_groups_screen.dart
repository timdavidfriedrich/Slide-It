import 'package:flutter/material.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/services/firebase/auth_service.dart';
import 'package:rating/features/social/widgets/add_group_dialog.dart';

class EmptyGroupsScreen extends StatelessWidget {
  const EmptyGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void addGroup() {
      showDialog(context: context, builder: (context) => const AddGroupDialog());
    }

    void signOut() {
      AuthService.instance.signOut();
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text("Willkommen!", style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: Constants.normalPadding),
              Flexible(
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(text: "Bei "),
                      TextSpan(
                        text: "Slide It!",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: " werden Kategorien und Objekte in Gruppen organisiert, "
                            "sodass du sie gemeinsam mit deinen Freunden bewerten kannst.",
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: Constants.mediumPadding),
              Flexible(
                child: Text(
                  "Tritt einer Gruppe bei:",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: Constants.normalPadding),
              ElevatedButton(
                onPressed: () => addGroup(),
                child: const Text("Gruppe hinzufügen"),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => signOut(),
                child: const Text("Abmelden"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
