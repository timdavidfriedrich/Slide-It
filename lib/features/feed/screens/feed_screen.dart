import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:log/log.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/services/shell_content.dart';
import 'package:rating/features/core/widgets/error_info.dart';
import 'package:rating/features/feed/services/history_widget.dart';
import 'package:rating/features/feed/widgets/added_category_card.dart';
import 'package:rating/features/feed/widgets/added_item_card.dart';
import 'package:rating/features/ratings/services/category.dart';
import 'package:rating/features/ratings/services/item.dart';
import 'package:rating/features/social/services/group.dart';

class FeedScreen extends StatefulWidget implements ShellContent {
  static const routeName = "/feed";
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();

  @override
  String get displayName => "Aktivitäten";

  @override
  Icon get icon {
    bool isIos = Theme.of(Global.context).platform == TargetPlatform.iOS;
    bool isMacOs = Theme.of(Global.context).platform == TargetPlatform.macOS;
    return isIos || isMacOs ? cupertinoIcon : materialIcon;
  }

  @override
  Icon get materialIcon => const Icon(Icons.newspaper);

  @override
  Icon get cupertinoIcon => const Icon(CupertinoIcons.news);
}

class _FeedScreenState extends State<FeedScreen> {
  Future<List<HistoryWidget>> _loadFeed() async {
    List<Group> groups = Provider.of<DataProvider>(context).userGroups;
    List<Category> categories = [];
    List<Item> items = [];
    List<HistoryWidget> result = [];
    for (Group g in groups) {
      for (Category c in g.categories) {
        categories.add(c);
        for (Item i in c.items) {
          items.add(i);
        }
      }
    }
    for (Category c in categories) {
      result.add(AddedCategoryCard(category: c));
    }
    for (Item i in items) {
      result.add(AddedItemCard(item: i));
    }
    result.sort((a, b) => b.getCreatedAt().compareTo(a.getCreatedAt()));
    Log.hint("Feed has been loaded.");
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadFeed(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorInfo(message: snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.data is! List<HistoryWidget>) {
            return const ErrorInfo();
          }
          final List<HistoryWidget> widgets = snapshot.data as List<HistoryWidget>;
          return Scaffold(
            body: widgets.isEmpty
                ? const Center(
                    child: Text(
                      "Wenn du oder deine Freunde\n"
                      "Objekte oder Kategorien erstellt,\n"
                      "werden diese hier angezeigt.",
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: Constants.normalPadding),
                    children: List.generate(widgets.length + 1, (index) {
                      if (index == widgets.length) return const SizedBox(height: Constants.largePadding * 2);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: Constants.normalPadding),
                        child: widgets[index],
                      );
                    }),
                  ),
          );
        });
  }
}
