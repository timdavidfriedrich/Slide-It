import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/services/app_user.dart';
import 'package:rating/features/ratings/services/item.dart';
import 'package:rating/features/ratings/services/rating.dart';

class RateItemScreen extends StatefulWidget {
  static const routeName = "/Rate";
  final Item item;
  final Rating? rating;
  const RateItemScreen({super.key, required this.item, this.rating});

  @override
  State<RateItemScreen> createState() => _RateItemScreenState();
}

class _RateItemScreenState extends State<RateItemScreen> {
  final TextEditingController _commentController = TextEditingController();
  late final Widget? _image;

  double _sliderValue = Constants.noRatingValue;

  final double _minValue = Constants.noRatingValue;
  final double _maxValue = Constants.maxRatingValue;

  bool _isInputValid() {
    // * value for 0 digits = 0.5, for 1 digit = 0.05, ... (catch double to int convertion)
    return _sliderValue >= (Constants.minRatingValue - 0.5) / pow(10, Constants.ratingValueDigit);
  }

  void _updateSliderValue(double value) {
    setState(() => _sliderValue = value);
  }

  Color _getValueColor() {
    final Color defaultColor = Theme.of(context).colorScheme.background;
    switch (_sliderValue) {
      // * Ignore statement is bugfix for dart analyzer (Dart 3.0.2)
      // ignore: non_constant_relational_pattern_expression
      case < Constants.minRatingValue:
        return Color.lerp(defaultColor, Constants.badColor, _sliderValue / Constants.minRatingValue) ?? defaultColor;
      case < 5.0:
        return Color.lerp(
                Constants.badColor, Constants.mediumColor, (_sliderValue - Constants.minRatingValue) / (5.0 - Constants.minRatingValue)) ??
            Constants.badColor;
      case < 10.0:
        return Color.lerp(Constants.mediumColor, Constants.greatColor, (_sliderValue - 5.0) / 5.0) ?? Constants.mediumColor;
      default:
        return Constants.greatColor;
    }
  }

  void _save() {
    String? text = _commentController.text.isNotEmpty ? _commentController.text : null;
    AppUser? currentUser = AppUser.current;
    if (currentUser == null) return context.pop();
    context.pop(Rating(itemId: widget.item.id, userId: currentUser.id, value: _sliderValue, comment: text));
  }

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.rating?.value ?? Constants.noRatingValue;
    _image = widget.item.image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getValueColor(),
      appBar: AppBar(
        backgroundColor: _getValueColor(),
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(widget.item.name, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            "${widget.item.category.name} (${Provider.of<DataProvider>(context).getGroupFromCategory(widget.item.category).name})",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
          children: [
            const SizedBox(height: Constants.normalPadding),
            if (_image != null)
              AspectRatio(
                aspectRatio: 3 / 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
                  child: _image,
                ),
              ),
            const SizedBox(height: Constants.mediumPadding),
            Text(
              "${_sliderValue.toStringAsFixed(Constants.ratingValueDigit)} 🔥",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Slider(
              min: _minValue,
              max: _maxValue,
              value: _sliderValue,
              onChanged: (value) => _updateSliderValue(value),
            ),
            const SizedBox(height: Constants.smallPadding),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Begründung (optional)"),
            ),
            const SizedBox(height: Constants.mediumPadding),
            ElevatedButton(
              onPressed: _isInputValid() ? () => _save() : null,
              child: const Text("Bewerten"),
            ),
          ],
        ),
      ),
    );
  }
}
