import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/ratings/screens/create_category_screen.dart';
import 'package:rating/features/ratings/services/category.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/social/services/group.dart';

class ChooseCategoryScreen extends StatelessWidget {
  static const routeName = "/ChooseCategory";

  const ChooseCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Group> userGroups = Provider.of<DataProvider>(context).userGroups;

    void chooseCategory(Category category) {
      context.pop(category);
    }

    void addCategory() {
      context.push(CreateCategoryScreen.routeName);
    }

    void cancel() {
      context.pop();
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
