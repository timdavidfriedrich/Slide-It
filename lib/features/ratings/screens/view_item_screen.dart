import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:log/log.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/services/firebase/cloud_service.dart';
import 'package:rating/features/core/widgets/error_info.dart';
import 'package:rating/features/ratings/screens/edit_item_screen.dart';
import 'package:rating/features/ratings/screens/rate_item_screen.dart';
import 'package:rating/features/ratings/services/edit_item_screen_arguments.dart';
import 'package:rating/features/ratings/services/item.dart';
import 'package:rating/features/ratings/services/view_item_screen_arguments.dart';
import 'package:rating/features/ratings/services/rate_item_screen_arguments.dart';
import 'package:rating/features/ratings/services/rating.dart';
import 'package:rating/features/social/services/app_user.dart';

class ViewItemScreen extends StatefulWidget {
  static const String routeName = "/Item";
  const ViewItemScreen({super.key});

  @override
  State<ViewItemScreen> createState() => _ViewItemScreenState();
}

class _ViewItemScreenState extends State<ViewItemScreen> {
  Item? _item;

  Future<Item> _loadItem() async {
    ViewItemScreenArguments arguments = ModalRoute.of(context)!.settings.arguments as ViewItemScreenArguments;
    return arguments.item;
  }

  void _edit() {
    Log.error(_item?.name ?? "Item is null");
    Navigator.pushNamed(context, EditItemScreen.routeName, arguments: EditItemScreenArguments(itemToEdit: _item));
  }

  void _editOwnRating() async {
    if (_item == null) return;
    User? user = AppUser.currentUser;
    if (user == null) return;
    final result = await Navigator.pushNamed(
      context,
      RateItemScreen.routeName,
      arguments: RateItemScreenArguments(
        item: _item!,
        ratingValue: _item!.ownRating?.value,
        comment: _item!.ownRating?.comment,
      ),
    );
    if (result is! (double, String?)) return;
    final (ratingValue, comment) = result;
    Rating rating = Rating(
      value: ratingValue,
      comment: comment,
      userId: user.uid,
      itemId: _item!.id,
    );
    if (_item!.ownRating == null) {
      CloudService.instance.addRating(category: _item!.category, rating: rating);
    } else {
      CloudService.instance.editRating(rating: rating);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadItem(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorInfo(message: snapshot.error.toString());
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (snapshot.data is! Item) return const ErrorInfo();
        _item = snapshot.data as Item;
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_item!.name, style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text(
                  "${_item!.category.name} (${Provider.of<DataProvider>(context).getGroupFromCategory(_item!.category).name})",
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
                    AspectRatio(aspectRatio: 4 / 3, child: _item!.image),
                    Positioned(
                      bottom: -Constants.mediumPadding / 2,
                      right: -Constants.mediumPadding / 2,
                      child: Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.background,
                        child: Padding(
                          padding: const EdgeInsets.all(Constants.smallPadding),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_item!.averageRating.toStringAsFixed(Constants.ratingValueDigit),
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
                _item!.ownRating == null
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
                          subtitle: Text(_item!.ownRating!.comment ?? "Ohne Kommentar."),
                          trailing: Text(
                            "${_item!.ownRating!.value.toStringAsFixed(Constants.ratingValueDigit)} 🔥",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ),
                const SizedBox(height: Constants.mediumPadding),
                Text("${_item!.group.name}:", style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: Constants.smallPadding),
                if (_item!.ratings.length == 0 + (_item!.ownRating != null ? 1 : 0)) const Text("Noch keine Bewertungen."),
                for (Rating r in _item!.ratings)
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
      },
    );
  }
}
