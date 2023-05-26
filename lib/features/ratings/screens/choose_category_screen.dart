import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/services/app_scaffold_arguments.dart';
import 'package:rating/features/ratings/screens/categories_screen.dart';
import 'package:rating/features/ratings/services/category.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/screens/app_scaffold.dart';
import 'package:rating/features/social/services/group.dart';

class ChooseCategoryScreen extends StatelessWidget {
  static const routeName = "/ChooseCategory";

  const ChooseCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Group> userGroups = Provider.of<DataProvider>(context).userGroups;

    void chooseCategory(Category category) {
      Navigator.pop(context, category);
    }

    void addCategory() {
      Navigator.pushNamedAndRemoveUntil(context, AppScaffold.routeName, (route) => false,
          arguments: const AppScaffoldArguments(selectedScreen: CategoriesScreen()));
    }

    void cancel() {
      Navigator.pop(context);
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
                          onTap: () => chooseCategory(category),
                        ),
                      ),
                  const SizedBox(height: Constants.normalPadding),
                  TextButton.icon(
                    onPressed: () => addCategory(),
                    icon: Icon(PlatformIcons(context).add),
                    label: const Text("Neue Kategorie erstellen"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Constants.mediumPadding),
            ElevatedButton(onPressed: () => cancel(), child: const Text("Abbrechen")),
            const SizedBox(height: Constants.largePadding),
          ],
        ),
      ),
    );
  }
}
