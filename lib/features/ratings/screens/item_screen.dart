import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/services/firebase/cloud_service.dart';
import 'package:rating/features/core/services/screen.dart';
import 'package:rating/features/ratings/screens/add_screen.dart';
import 'package:rating/features/ratings/screens/rate_screen.dart';
import 'package:rating/features/ratings/services/add_screen_arguments.dart';
import 'package:rating/features/ratings/services/item.dart';
import 'package:rating/features/ratings/services/item_screen_arguments.dart';
import 'package:rating/features/ratings/services/rating.dart';
import 'package:rating/features/social/services/app_user.dart';

class ItemScreen extends StatefulWidget implements Screen {
  static const String routeName = "/Item";
  const ItemScreen({super.key});

  @override
  String get displayName => "Item";

  @override
  Icon get icon {
    bool isIos = Theme.of(Global.context).platform == TargetPlatform.iOS;
    bool isMacOs = Theme.of(Global.context).platform == TargetPlatform.macOS;
    return isIos || isMacOs ? cupertinoIcon : materialIcon;
  }

  @override
  Icon get materialIcon => const Icon(Icons.folder);

  @override
  Icon get cupertinoIcon => const Icon(CupertinoIcons.folder);

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  Item? item;

  Future<Item> _loadArguments() async {
    ItemScreenArguments arguments = ModalRoute.of(context)!.settings.arguments as ItemScreenArguments;
    return arguments.item;
  }

  void _edit() {
    Navigator.pushNamed(context, AddScreen.routeName, arguments: AddScreenArguments(itemToEdit: item));
  }

  void _addOwnRating() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final result = await Navigator.pushNamed(context, RateScreen.routeName);
    if (result is! (double, String?)) return;
    final (ratingValue, comment) = result;
    Rating rating = Rating(
      value: ratingValue,
      comment: comment,
      userId: user.uid,
      itemId: item!.id,
    );
    // item!.ratings.add(rating);
    CloudService.addRating(category: item!.category, rating: rating);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadArguments(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Icon(PlatformIcons(context).error));
          } else if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else {
            item = snapshot.data!;
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  titleSpacing: 0,
                  title: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item!.name, style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text(
                      "${item!.category.name} (${Provider.of<DataProvider>(context).getGroupFromCategory(item!.category).name})",
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
                        AspectRatio(aspectRatio: 4 / 3, child: item!.image),
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
                                  Text(item!.averageRating.toStringAsFixed(1), style: Theme.of(context).textTheme.displaySmall),
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
                    item!.ownRating == null
                        ? Card(
                            child: ListTile(
                              title: const Text("(Klicken zum Bewerten)"),
                              onTap: () => _addOwnRating(),
                            ),
                          )
                        : Card(
                            child: ListTile(
                              leading: AppUser.avatar,
                              title: const Text("Ich"),
                              subtitle: Text(item!.ownRating!.comment ?? "Ohne Kommentar."),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(item!.ownRating!.value.toStringAsFixed(1)),
                                  const SizedBox(width: Constants.smallPadding),
                                  const Text("🔥"),
                                ],
                              ),
                            ),
                          ),
                    const SizedBox(height: Constants.mediumPadding),
                    Text("${item!.group.name}:", style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: Constants.smallPadding),
                    for (Rating r in item!.ratings)
                      ListTile(
                        leading: AppUser.avatar,
                        title: Text(AppUser.user?.displayName ?? "Unbenannt"),
                        subtitle: Text(r.comment ?? "Ohne Kommentar."),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(r.value.toStringAsFixed(1)),
                            const SizedBox(width: Constants.smallPadding),
                            const Text("🔥"),
                          ],
                        ),
                      ),
                    const SizedBox(height: Constants.largePadding),
                  ],
                ),
              ),
            );
          }
        });
  }
}
