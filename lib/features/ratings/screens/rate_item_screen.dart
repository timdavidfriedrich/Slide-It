import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final TextEditingController _valueController = TextEditingController();
  final Pattern _valuePattern = RegExp(r'^((10(\.0)?)|([0-9](\.[0-9])?)|([0-9]\.))$');

  final double _minValue = Constants.noRatingValue;
  final double _maxValue = Constants.maxRatingValue;

  void _initValues() {
    _sliderValue = widget.rating?.value ?? Constants.noRatingValue;
    _image = widget.item.image;
    _commentController.text = widget.rating?.comment ?? "";
  }

  bool _isInputValid() {
    // * value for 0 digits = 0.5, for 1 digit = 0.05, ... (catch double to int convertion)
    return _sliderValue >= (Constants.minRatingValue - 0.5) / pow(10, Constants.ratingValueDigit);
  }

  void _updateSliderValue(double value) {
    setState(() => _sliderValue = value);
  }

  void _clearValueController() {
    _valueController.clear();
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
    _initValues();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.background, _getValueColor()],
          begin: Alignment(0, -0.5 * _sliderValue),
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
            child: Column(
              children: [
                const SizedBox(height: Constants.normalPadding),
                if (_image != null)
                  AspectRatio(
                    aspectRatio: 3 / 2,
                    child: Opacity(
                      opacity: 0.9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
                        child: _image,
                      ),
                    ),
                  ),
                const SizedBox(height: Constants.mediumPadding),
                Expanded(
                  child: TextField(
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(_valuePattern),
                    ],
                    controller: _valueController,
                    onChanged: (value) => _updateSliderValue(double.parse(value)),
                    onTapOutside: (_) => _clearValueController(),
                    onSubmitted: (_) => _clearValueController(),
                    onEditingComplete: () => _clearValueController(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "${_sliderValue.toStringAsFixed(Constants.ratingValueDigit)}${Constants.ratingValueUnit}",
                      filled: false,
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                    ),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.azeretMono(
                      fontWeight: FontWeight.w500,
                      fontSize: Theme.of(context).textTheme.displayLarge?.fontSize,
                    ),
                  ),
                ),
                const SizedBox(height: Constants.normalPadding),
                Slider(
                  min: _minValue,
                  max: _maxValue,
                  value: _sliderValue,
                  onChanged: (value) => _updateSliderValue(value),
                ),
                const SizedBox(height: Constants.mediumPadding),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                  decoration: InputDecoration(
                    fillColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.2),
                    labelText: "Begründung (optional)",
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                  ),
                ),
                const SizedBox(height: Constants.mediumPadding),
                ElevatedButton(
                  onPressed: _isInputValid() ? () => _save() : null,
                  child: const Text("Bewerten"),
                ),
                const SizedBox(height: Constants.largePadding),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
