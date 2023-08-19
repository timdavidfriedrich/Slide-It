import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/services/data/data_provider.dart';
import 'package:rating/features/overview/screens/category_screen.dart';
import 'package:rating/features/overview/screens/group/choose_group_screen.dart';
import 'package:rating/features/overview/screens/category/create_category_screen.dart';
import 'package:rating/features/overview/models/category.dart';
import 'package:rating/features/core/utils/shell_content.dart';
import 'package:rating/features/overview/widgets/add_item_card.dart';
import 'package:rating/features/overview/widgets/item_card.dart';
import 'package:rating/features/social/screens/group/group_screen.dart';
import 'package:rating/features/social/models/group.dart';

class OverviewScreen extends StatefulWidget implements ShellContent {
  static const routeName = "/overview";
  const OverviewScreen({Key? key}) : super(key: key);

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();

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

class _OverviewScreenState extends State<OverviewScreen> {
  final int _maxItemsPerRow = 10;
  Group? _currentGroup;

  void _changeGroup() {
    context.push(ChooseGroupScreen.routeName);
  }

  void _showCurrentGroupInfos() {
    if (_currentGroup == null) return;
    context.push(GroupScreen.routeName, extra: _currentGroup);
  }

  void _openCategory(Category category) {
    context.push(CategoryScreen.routeName, extra: category);
  }

  void _createCategory() {
    if (_currentGroup == null) return;
    context.push(CreateCategoryScreen.routeName, extra: _currentGroup!);
  }

  @override
  Widget build(BuildContext context) {
    _currentGroup = Provider.of<DataProvider>(context).selectedGroup;
    const double screenPadding = Constants.normalPadding;
    return SafeArea(
      child: ListView(
        children: [
          const SizedBox(height: Constants.normalPadding),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: screenPadding),
            child: Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsets.only(
                  left: Constants.normalPadding,
                  right: Constants.smallPadding,
                ),
                leading: _currentGroup?.avatar,
                title: Text(_currentGroup?.name ?? "Keine Gruppe ausgewählt"),
                subtitle: _currentGroup == null ? null : const Text("(Tippen zum wechseln)"),
                trailing: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _showCurrentGroupInfos(),
                  icon: Icon(PlatformIcons(context).info),
                ),
                onTap: () => _changeGroup(),
              ),
            ),
          ),
          const SizedBox(height: Constants.mediumPadding),
          if (_currentGroup != null)
            if (_currentGroup!.categories.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(Constants.mediumPadding, 0, Constants.mediumPadding, Constants.mediumPadding),
                child: Text("Keine Kategorien vorhanden."),
              )
            else
              for (Category c in _currentGroup!.categories)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: screenPadding),
                      child: InkWell(
                        onTap: () => _openCategory(c),
                        borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(child: Text(c.name, style: Theme.of(context).textTheme.headlineSmall)),
                            const SizedBox(width: Constants.normalPadding),
                            Text("Alle anzeigen", style: Theme.of(context).textTheme.labelSmall),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Constants.smallPadding),
                    if (c.items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: screenPadding),
                        child: Text("Keine Items vorhanden", style: Theme.of(context).textTheme.bodyMedium),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: IntrinsicHeight(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List<Widget>.generate(
                              min(c.items.length, _maxItemsPerRow) + 2,
                              (index) {
                                final bool isFirst = index == 0;
                                final bool isLast = index == min(c.items.length, _maxItemsPerRow) + 1;
                                if (isFirst) {
                                  return const SizedBox(width: screenPadding);
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(right: Constants.normalPadding),
                                  child: isLast ? const AddItemCard() : ItemCard(item: c.items.reversed.elementAt(index - 1)),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: Constants.mediumPadding),
                  ],
                ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
            child: TextButton.icon(
              onPressed: _currentGroup == null ? null : () => _createCategory(),
              icon: Icon(PlatformIcons(context).add),
              label: const Text("Kategorie erstellen"),
            ),
          ),
          const SizedBox(height: Constants.largePadding),
        ],
      ),
    );
  }
}
