import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/ratings/models/item.dart';
import 'package:rating/features/ratings/screens/item/zoomable_image_screen.dart';
import 'package:rating/features/ratings/widgets/group_rating_section.dart';
import 'package:rating/features/ratings/widgets/item_app_bar.dart';
import 'package:rating/features/ratings/widgets/my_rating_card.dart';

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
                  GroupRatingSection(item: widget.item),
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
