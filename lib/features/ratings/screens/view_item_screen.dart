import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/services/firebase/cloud_service.dart';
import 'package:rating/features/ratings/screens/edit_item_screen.dart';
import 'package:rating/features/ratings/screens/rate_item_screen.dart';
import 'package:rating/features/ratings/services/item.dart';
import 'package:rating/features/ratings/services/rating.dart';
import 'package:rating/features/social/services/app_user.dart';

class ViewItemScreen extends StatefulWidget {
  static const String routeName = "/Item";
  final Item item;
  const ViewItemScreen({super.key, required this.item});

  @override
  State<ViewItemScreen> createState() => _ViewItemScreenState();
}

class _ViewItemScreenState extends State<ViewItemScreen> {
  void _edit() {
    context.push(EditItemScreen.routeName, extra: widget.item);
  }

  void _editOwnRating() async {
    User? user = AppUser.currentUser;
    if (user == null) return;
    final result = await context.push<(double, String?)>(
      RateItemScreen.routeName,
      extra: (widget.item, widget.item.ownRating?.value, widget.item.ownRating?.comment),
    );
    if (result == null) return;
    final (ratingValue, comment) = result;
    Rating rating = Rating(
      value: ratingValue,
      comment: comment,
      userId: user.uid,
      itemId: widget.item.id,
    );
    if (widget.item.ownRating == null) {
      CloudService.instance.addRating(category: widget.item.category, rating: rating);
    } else {
      CloudService.instance.editRating(rating: rating);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(widget.item.name, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(
              "${widget.item.category.name} (${Provider.of<DataProvider>(context).getGroupFromCategory(widget.item.category).name})",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          actions: [
            IconButton(onPressed: () => _edit(), icon: Icon(PlatformIcons(context).edit)),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
          children: [
            const SizedBox(height: Constants.normalPadding),
            Stack(
              clipBehavior: Clip.none,
              children: [
                AspectRatio(
                    aspectRatio: 4 / 3,
                    child: ClipRRect(borderRadius: BorderRadius.circular(Constants.defaultBorderRadius), child: widget.item.image)),
                Positioned(
                  bottom: -Constants.mediumPadding / 2,
                  right: -Constants.mediumPadding / 2,
                  child: Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.background,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Constants.normalPadding, vertical: Constants.smallPadding),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.item.averageRating.toStringAsFixed(Constants.ratingValueDigit),
                              style: Theme.of(context).textTheme.displaySmall),
                          const SizedBox(width: Constants.smallPadding),
                          const Text("🔥"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Constants.mediumPadding),
            Text("Meine Bewertung:", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: Constants.smallPadding),
            widget.item.ownRating == null
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
                        "${widget.item.ownRating!.value.toStringAsFixed(Constants.ratingValueDigit)} 🔥",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
            const SizedBox(height: Constants.mediumPadding),
            Text("${widget.item.group.name}:", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: Constants.smallPadding),
            if (widget.item.ratings.length == 0 + (widget.item.ownRating != null ? 1 : 0)) const Text("Noch keine Bewertungen."),
            for (Rating r in widget.item.ratings)
              if (r.userId != AppUser.currentUser?.uid)
                ListTile(
                  leading: Provider.of<DataProvider>(context).getAppUserById(r.userId)?.getAvatar(),
                  title: Text(Provider.of<DataProvider>(context).getAppUserById(r.userId)?.name ?? "Unbenannt"),
                  subtitle: Text(r.comment ?? "Ohne Kommentar."),
                  trailing: Text(
                    "${r.value.toStringAsFixed(Constants.ratingValueDigit)} 🔥",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
            const SizedBox(height: Constants.largePadding),
          ],
        ),
      ),
    );
  }
}
