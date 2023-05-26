import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/ratings/screens/choose_group_screen.dart';
import 'package:rating/features/ratings/services/category.dart';
import 'package:rating/features/ratings/widget/create_category_dialog.dart';
import 'package:rating/features/core/services/screen.dart';
import 'package:rating/features/ratings/widget/item_card.dart';
import 'package:rating/features/social/services/group.dart';

class CategoriesScreen extends StatefulWidget implements Screen {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();

  @override
  String get displayName => "Bewertungen";

  @override
  Icon get icon {
    bool isIos = Theme.of(Global.context).platform == TargetPlatform.iOS;
    bool isMacOs = Theme.of(Global.context).platform == TargetPlatform.macOS;
    return isIos || isMacOs ? cupertinoIcon : materialIcon;
  }

  @override
  Icon get materialIcon => const Icon(Icons.category_outlined);

  @override
  Icon get cupertinoIcon => const Icon(CupertinoIcons.list_bullet);
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  Group? currentGroup;

  void _navigateToGroupSelection() {
    Navigator.pushNamed(context, ChooseGroupScreen.routeName);
  }

  void _createCategory() {
    if (currentGroup == null) return;
    showDialog(context: context, builder: (context) => CreateCategoryDialog(group: currentGroup!));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    currentGroup = Provider.of<DataProvider>(context).selectedGroup;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
        children: [
          const SizedBox(height: Constants.normalPadding),
          Card(
            child: ListTile(
              leading: currentGroup?.avatar,
              title: Text(currentGroup?.name ?? "Keine Gruppe ausgewählt"),
              subtitle: currentGroup == null ? null : const Text("(Tippen zum wechseln)"),
              onTap: () => _navigateToGroupSelection(),
            ),
          ),
          const SizedBox(height: Constants.mediumPadding),
          if (currentGroup != null)
            if (currentGroup!.categories.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: Constants.mediumPadding),
                child: Text("Keine Kategorien vorhanden."),
              )
            else
              for (Category c in currentGroup!.categories)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: Constants.smallPadding),
                    if (c.items.isEmpty)
                      Text("Keine Items vorhanden", style: Theme.of(context).textTheme.bodyMedium)
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            c.items.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(right: Constants.normalPadding),
                              child: ItemCard(item: c.items.elementAt(index)),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: Constants.mediumPadding),
                  ],
                ),
          TextButton.icon(
            onPressed: currentGroup == null ? null : () => _createCategory(),
            icon: Icon(PlatformIcons(context).add),
            label: const Text("Kategorie erstellen"),
          ),
          const SizedBox(height: Constants.largePadding),
        ],
      ),
    );
  }
}
