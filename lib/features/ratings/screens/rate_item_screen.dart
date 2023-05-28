import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/ratings/services/item.dart';
import 'package:rating/features/ratings/services/rate_item_screen_arguments.dart';

class RateItemScreen extends StatefulWidget {
  static const routeName = "/Rate";
  const RateItemScreen({super.key});

  @override
  State<RateItemScreen> createState() => _RateItemScreenState();
}

class _RateItemScreenState extends State<RateItemScreen> {
  final TextEditingController _commentController = TextEditingController();

  double _ratingValue = Constants.noRatingValue;
  final double _minValue = Constants.noRatingValue;
  final double _maxValue = Constants.maxRatingValue;

  void _loadArguments() {
    final RateItemScreenArguments? arguments = ModalRoute.of(context)?.settings.arguments as RateItemScreenArguments?;
    if (arguments == null) return;
    if (arguments.ratingValue == null) return;
    setState(() => _ratingValue = arguments.ratingValue!);
    if (arguments.comment == null) return;
    setState(() => _commentController.text = arguments.comment!);
  }

  Future<Item> _getItem() async {
    final RateItemScreenArguments arguments = ModalRoute.of(context)?.settings.arguments as RateItemScreenArguments;
    return arguments.item;
  }

  bool _isInputValid() {
    // * value for 0 digits = 0.5, for 1 digit = 0.05, ... (catch double to int convertion)
    return _ratingValue >= (Constants.minRatingValue - 0.5) / pow(10, Constants.ratingValueDigit);
  }

  void _updateSliderValue(double value) {
    setState(() => _ratingValue = value);
  }

  Color _getValueColor() {
    final Color defaultColor = Theme.of(context).colorScheme.background;
    switch (_ratingValue) {
      // * Ignore statement is bugfix for dart analyzer (Dart 3.0.2)
      // ignore: non_constant_relational_pattern_expression
      case < Constants.minRatingValue:
        return Color.lerp(defaultColor, Constants.badColor, _ratingValue / Constants.minRatingValue) ?? defaultColor;
      case < 5.0:
        return Color.lerp(
                Constants.badColor, Constants.mediumColor, (_ratingValue - Constants.minRatingValue) / (5.0 - Constants.minRatingValue)) ??
            Constants.badColor;
      case < 10.0:
        return Color.lerp(Constants.mediumColor, Constants.greatColor, (_ratingValue - 5.0) / 5.0) ?? Constants.mediumColor;
      default:
        return Constants.greatColor;
    }
  }

  void _save() {
    String? text = _commentController.text.isNotEmpty ? _commentController.text : null;
    Navigator.pop(context, (_ratingValue, text));
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadArguments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getItem(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator.adaptive();
        } else {
          Item item = snapshot.data!;
          return Scaffold(
            backgroundColor: _getValueColor(),
            appBar: AppBar(
              backgroundColor: _getValueColor(),
              title: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text(
                  "${item.category.name} (${Provider.of<DataProvider>(context).getGroupFromCategory(item.category).name})",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
                children: [
                  const SizedBox(height: Constants.normalPadding),
                  const AspectRatio(aspectRatio: 3 / 2, child: Placeholder()),
                  const SizedBox(height: Constants.mediumPadding),
                  Text(
                    "${_ratingValue.toStringAsFixed(Constants.ratingValueDigit)} 🔥",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Slider(
                    min: _minValue,
                    max: _maxValue,
                    value: _ratingValue,
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
      },
    );
  }
}
