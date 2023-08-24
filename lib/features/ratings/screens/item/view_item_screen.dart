import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/services/data/data_provider.dart';
import 'package:rating/features/ratings/models/item.dart';
import 'package:rating/features/ratings/models/rating.dart';
import 'package:rating/features/core/models/app_user.dart';
import 'package:rating/features/ratings/screens/item/zoomable_image_screen.dart';
import 'package:rating/features/ratings/widgets/item_app_bar.dart';
import 'package:rating/features/ratings/widgets/my_rating_card.dart';
import 'package:rating/features/settings/provider/settings_provider.dart';

class ViewItemScreen extends StatefulWidget {
  static const String routeName = "/Item";
  final Item item;
  const ViewItemScreen({super.key, required this.item});

  @override
  State<ViewItemScreen> createState() => _ViewItemScreenState();
}

class _ViewItemScreenState extends State<ViewItemScreen> {
  void _openZoomableImage() {
    context.push<Widget>(
      ZoomableImageScreen.routeName,
      extra: widget.item.image!,
    );
  }

  @override
  Widget build(BuildContext context) {
    SettingsProvider settings = Provider.of<SettingsProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            ItemAppBar(item: widget.item),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
                children: [
                  const SizedBox(height: Constants.normalPadding),
                  if (widget.item.image != null)
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
                        child: GestureDetector(
                          onTap: _openZoomableImage,
                          child: widget.item.image,
                        ),
                      ),
                    ),
                  const SizedBox(height: Constants.mediumPadding),
                  Text("Meine Bewertung:", style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: Constants.smallPadding),
                  MyRatingCard(item: widget.item),
                  const SizedBox(height: Constants.mediumPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${widget.item.group.name}:", style: Theme.of(context).textTheme.headlineSmall),
                      Text(
                        "⌀ ${widget.item.averageRating.toStringAsFixed(settings.numberOfDecimals)} ${Constants.ratingValueUnit}",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: Constants.smallPadding),
                  if (widget.item.ratings.length == 0 + (widget.item.ownRating != null ? 1 : 0)) const Text("Noch keine Bewertungen."),
                  for (Rating r in widget.item.ratings)
                    if (r.userId != AppUser.currentUser?.uid)
                      ListTile(
                        leading: Provider.of<DataProvider>(context).getAppUserById(r.userId)?.getAvatar(),
                        title: Text(Provider.of<DataProvider>(context).getAppUserById(r.userId)?.name ?? "Unbenannt"),
                        subtitle: Text(r.comment ?? "Ohne Kommentar."),
                        trailing: Text(
                          "${r.value.toStringAsFixed(settings.numberOfDecimals)}${Constants.ratingValueUnit}",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                  const SizedBox(height: Constants.largePadding),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
