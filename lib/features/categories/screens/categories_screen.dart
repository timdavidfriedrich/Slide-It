import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/categories/services/category.dart';
import 'package:rating/features/categories/widgets/create_category_dialog.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/screens/screen.dart';
import 'package:rating/features/core/services/group.dart';

class CategoriesScreen extends StatefulWidget implements Screen {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();

  @override
  String get displayName => "Kategorien";

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

  void _createCategory() {
    showDialog(context: context, builder: (context) => CreateCategoryDialog(group: currentGroup!));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentGroup = Provider.of<DataProvider>(context, listen: false).groups.first;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
        children: [
          const SizedBox(height: Constants.normalPadding),
          Card(
            child: ListTile(
              leading: currentGroup?.avatar,
              title: Text(currentGroup?.name ?? "Keine Gruppe ausgewählt"),
              subtitle: Text(currentGroup?.users.length == 1 ? "1 Mitglied" : "${currentGroup?.users.length ?? 0} Mitglieder"),
            ),
          ),
          const SizedBox(height: Constants.smallPadding),
          PlatformElevatedButton(
            child: const Text("Kategorie erstellen"),
            onPressed: () => _createCategory(),
          ),
          const SizedBox(height: Constants.normalPadding),
          for (Category c in Provider.of<DataProvider>(context).getCategoriesFromGroup(currentGroup!))
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: Constants.smallPadding),
                AspectRatio(
                  aspectRatio: 4 / 1,
                  child: Card(child: Center(child: Text("${c.ratings.length}"))),
                ),
                const SizedBox(height: Constants.normalPadding),
              ],
            ),
        ],
      ),
    );
  }
}
