import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/models/app_user.dart';
import 'package:rating/features/ratings/models/item.dart';
import 'package:rating/features/ratings/models/rating.dart';
import 'package:rating/features/ratings/screens/item/zoomable_image_screen.dart';
import 'package:rating/features/ratings/widgets/item_app_bar.dart';
import 'package:rating/features/settings/provider/settings_provider.dart';

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
  // final Pattern _valuePattern = RegExp(r'^((10(\.0)?)|([0-9](\.[0-9])?)|([0-9]\.))$');
  final Pattern _valuePattern = RegExp(r'^((10(\.0)?)|([0-9](\.[0-9])?)|([0-9]\.)|(10(\,0)?)|([0-9](\,[0-9])?)|([0-9]\,))$');

  final double _minValue = Constants.noRatingValue;
  final double _maxValue = Constants.maxRatingValue;

  void _initValues() {
    _sliderValue = widget.rating?.value ?? Constants.noRatingValue;
    _image = widget.item.image;
    _commentController.text = widget.rating?.comment ?? "";
  }

  bool _isInputValid() {
    SettingsProvider settings = Provider.of<SettingsProvider>(context, listen: false);
    // * value for 0 digits = 0.5, for 1 digit = 0.05, ... (catch double to int convertion)
    return _sliderValue >= (Constants.minRatingValue - 0.5) / pow(10, settings.numberOfDecimals);
  }

  void _updateSliderValue(value) {
    try {
      double parsedValue;
      if (value is double) {
        parsedValue = value;
      } else if (value is String) {
        parsedValue = double.parse(value.replaceAll(",", "."));
      } else {
        parsedValue = double.parse(value);
      }
      if (parsedValue < _minValue || parsedValue > _maxValue) return;
      setState(() => _sliderValue = parsedValue);
    } catch (e) {
      return;
    }
  }

  void _clearValueController() {
    _dismissKeyboard();
    _valueController.clear();
  }

  void _dismissKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void _openZoomableImage() {
    context.push<Widget>(
      ZoomableImageScreen.routeName,
      extra: _image,
    );
  }

  Color _getValueColor() {
    final Color defaultColor = Theme.of(context).colorScheme.background;
    final SettingsProvider settings = Provider.of<SettingsProvider>(context, listen: false);
    if (!settings.dynamicRatingColorEnabled) return defaultColor;
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
    SettingsProvider settings = Provider.of<SettingsProvider>(context);
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
        body: SafeArea(
          child: Column(
            children: [
              ItemAppBar(
                item: widget.item,
                showEditButton: false,
                showMapButton: false,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
                  children: [
                    const SizedBox(height: Constants.normalPadding),
                    if (_image != null)
                      AspectRatio(
                        aspectRatio: 3 / 2,
                        child: Opacity(
                          opacity: 0.9,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
                            child: GestureDetector(
                              onTap: _openZoomableImage,
                              child: _image,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: Constants.largePadding),
                    TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(_valuePattern),
                      ],
                      controller: _valueController,
                      onChanged: (value) => _updateSliderValue(value),
                      onTapOutside: (_) => _clearValueController(),
                      onSubmitted: (_) => _clearValueController(),
                      onEditingComplete: () => _clearValueController(),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: "${_sliderValue.toStringAsFixed(settings.numberOfDecimals)}${Constants.ratingValueUnit}",
                        filled: false,
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                      ),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.azeretMono(
                        fontWeight: FontWeight.w500,
                        fontSize: Theme.of(context).textTheme.displayLarge?.fontSize,
                      ),
                    ),
                    const SizedBox(height: Constants.mediumPadding),
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
            ],
          ),
        ),
      ),
    );
  }
}
