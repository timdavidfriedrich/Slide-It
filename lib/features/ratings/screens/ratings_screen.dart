import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/ratings/screens/choose_group_screen.dart';
import 'package:rating/features/ratings/screens/create_category_screen.dart';
import 'package:rating/features/ratings/services/category.dart';
import 'package:rating/features/core/services/shell_content.dart';
import 'package:rating/features/ratings/widget/item_card.dart';
import 'package:rating/features/social/services/group.dart';

class RatingsScreen extends StatefulWidget implements ShellContent {
  static const routeName = "/ratings";
  const RatingsScreen({Key? key}) : super(key: key);

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();

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

class _RatingsScreenState extends State<RatingsScreen> {
  Group? currentGroup;

  void _changeGroup() {
    context.push(ChooseGroupScreen.routeName);
  }

  void _createCategory() {
    if (currentGroup == null) return;
    context.push(CreateCategoryScreen.routeName, extra: currentGroup!);
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
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: currentGroup?.avatar,
              title: Text(currentGroup?.name ?? "Keine Gruppe ausgewählt"),
              subtitle: currentGroup == null ? null : const Text("(Tippen zum wechseln)"),
              onTap: () => _changeGroup(),
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
