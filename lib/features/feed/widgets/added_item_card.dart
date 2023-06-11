import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/services/firebase/cloud_service.dart';
import 'package:rating/features/feed/services/history_widget.dart';
import 'package:rating/features/ratings/screens/rate_item_screen.dart';
import 'package:rating/features/ratings/screens/view_item_screen.dart';
import 'package:rating/features/ratings/services/item.dart';
import 'package:rating/features/ratings/services/rating.dart';
import 'package:rating/features/core/services/app_user.dart';

class AddedItemCard extends StatefulWidget implements HistoryWidget {
  final Item item;
  const AddedItemCard({super.key, required this.item});

  @override
  State<AddedItemCard> createState() => _AddedItemCardState();

  @override
  Timestamp getCreatedAt() {
    return item.createdAt;
  }
}

class _AddedItemCardState extends State<AddedItemCard> {
  void _editOwnRating() async {
    AppUser? appUser = AppUser.current;
    if (appUser == null) return;
    final result = await context.push<Rating>(RateItemScreen.routeName, extra: (widget.item, widget.item.ownRating));
    if (result is! Rating) return;
    final Rating rating = result;
    if (widget.item.ownRating == null) {
      CloudService.instance.addRating(category: widget.item.category, rating: rating);
    } else {
      CloudService.instance.editRating(
        category: widget.item.category,
        rating: widget.item.ownRating!,
        value: rating.value,
        comment: rating.comment,
      );
    }
    if (!mounted) return;
    setState(() {});
  }

  void _viewItem() {
    context.push(ViewItemScreen.routeName, extra: widget.item);
  }

  @override
  Widget build(BuildContext context) {
    AppUser? appUser = Provider.of<DataProvider>(context, listen: false).getAppUserById(widget.item.createdByUserId);
    DateTime creationDate = widget.item.createdAt.toDate();
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
                    "${appUser?.name ?? "Unbenannt"} hat ein neues Objekt hinzugefügt:",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Constants.smallPadding),
            InkWell(
              onTap: () => _viewItem(),
              borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
              child: Card(
                margin: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.item.image != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Constants.normalPadding, Constants.normalPadding, Constants.normalPadding, 0),
                        child: AspectRatio(
                          aspectRatio: 1 / 1,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                Constants.defaultBorderRadius,
                              ),
                              child: widget.item.image),
                        ),
                      ),
                    ListTile(
                      // onTap: () => _viewItem(),
                      title: Text(widget.item.name),
                      subtitle: Text(widget.item.category.name),
                      trailing: Text(widget.item.group.name),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Constants.smallPadding),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                onTap: () => _editOwnRating(),
                title: Text(widget.item.ownRating == null ? "(Tippe zum Bewerten)" : "Meine Bewertung"),
                subtitle: widget.item.ownRating?.comment == null ? null : Text(widget.item.ownRating!.comment!),
                trailing: widget.item.ownRating == null
                    ? null
                    : Text("${widget.item.ownRating?.value.toStringAsFixed(Constants.ratingValueDigit)}${Constants.ratingValueUnit}"),
              ),
            ),
            const SizedBox(height: Constants.smallPadding),
            Text(
              "${creationDate.hour}:${creationDate.minute} Uhr, ${creationDate.day}.${creationDate.month}.${creationDate.year}",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
