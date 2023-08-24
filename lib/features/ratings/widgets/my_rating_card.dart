import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/models/app_user.dart';
import 'package:rating/features/core/services/data/cloud_data_service.dart';
import 'package:rating/features/ratings/models/item.dart';
import 'package:rating/features/ratings/models/rating.dart';
import 'package:rating/features/ratings/screens/item/rate_item_screen.dart';
import 'package:rating/features/settings/provider/settings_provider.dart';

class MyRatingCard extends StatefulWidget {
  final Item item;
  const MyRatingCard({super.key, required this.item});

  @override
  State<MyRatingCard> createState() => _MyRatingCardState();
}

class _MyRatingCardState extends State<MyRatingCard> {
  void _editOwnRating() async {
    User? user = AppUser.currentUser;
    if (user == null) return;
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SettingsProvider settings = Provider.of<SettingsProvider>(context);

    return widget.item.ownRating == null
        ? Card(
            child: ListTile(
              title: const Text("(Klicken zum Bewerten)"),
              onTap: () => _editOwnRating(),
            ),
          )
        : Card(
            child: ListTile(
              onTap: () => _editOwnRating(),
              leading: AppUser.currentAvatar,
              title: const Text("Ich"),
              subtitle: Text(widget.item.ownRating!.comment ?? "Ohne Kommentar."),
              trailing: Text(
                "${widget.item.ownRating!.value.toStringAsFixed(settings.numberOfDecimals)}${Constants.ratingValueUnit}",
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          );
  }
}
