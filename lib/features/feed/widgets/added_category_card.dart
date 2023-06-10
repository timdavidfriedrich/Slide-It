import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/feed/services/history_widget.dart';
import 'package:rating/features/ratings/screens/category_screen.dart';
import 'package:rating/features/ratings/services/category.dart';
import 'package:rating/features/core/services/app_user.dart';

class AddedCategoryCard extends StatelessWidget implements HistoryWidget {
  final Category category;
  const AddedCategoryCard({super.key, required this.category});

  @override
  Timestamp getCreatedAt() {
    return category.createdAt;
  }

  @override
  Widget build(BuildContext context) {
    void openCategory() {
      context.push(CategoryScreen.routeName, extra: category);
    }

    AppUser? appUser = Provider.of<DataProvider>(context, listen: false).getAppUserById(category.createdByUserId);
    DateTime creationDate = category.createdAt.toDate();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                if (appUser != null) appUser.getAvatar(radius: 8),
                const SizedBox(width: Constants.smallPadding),
                Flexible(
                  child: Text(
                    "${appUser?.name ?? "Unbenannt"} hat eine neue Kategorie hinzugefügt:",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Constants.smallPadding),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                onTap: () => openCategory(),
                title: Text(category.name),
                trailing: Text(category.group.name),
              ),
            ),
            const SizedBox(height: Constants.smallPadding),
            Text(
              "${creationDate.hour}:${creationDate.minute} Uhr, ${creationDate.day}.${creationDate.month}.${creationDate.year}",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
    );
  }
}
