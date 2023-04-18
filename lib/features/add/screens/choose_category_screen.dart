import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/add/screens/add_screen.dart';
import 'package:rating/features/add/services/add_screen_arguments.dart';
import 'package:rating/features/categories/services/category.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/screens/app_scaffold.dart';
import 'package:rating/features/core/services/group.dart';

class ChooseCategoryScreen extends StatelessWidget {
  static const routeName = "/ChooseCategory";

  const ChooseCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Group> userGroups = Provider.of<DataProvider>(context).userGroups;

    void chooseCategory(Group group, Category category) {
      Navigator.pop(context);
      Navigator.pushNamed(
        context,
        AddScreen.routeName,
        arguments: AddScreenArguments(group: group, category: category),
      );
    }

    void cancel() {
      Navigator.popUntil(context, ModalRoute.withName(AppScaffold.routeName));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: Constants.largePadding),
            Text("Wähle eine Kategorie", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: Constants.mediumPadding),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
                children: [
                  for (Group group in userGroups)
                    for (Category category in group.categories)
                      Card(
                        child: ListTile(
                          title: Text(category.name),
                          trailing: Text(group.name),
                          onTap: () => chooseCategory(group, category),
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(height: Constants.mediumPadding),
            PlatformElevatedButton(onPressed: () => cancel(), child: const Text("Abbrechen")),
            const SizedBox(height: Constants.largePadding),
          ],
        ),
      ),
    );
  }
}
