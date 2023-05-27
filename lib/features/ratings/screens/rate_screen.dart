import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/ratings/services/rate_screen_arguments.dart';

class RateScreen extends StatefulWidget {
  static const routeName = "/Rate";
  const RateScreen({super.key});

  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  final TextEditingController _commentController = TextEditingController();

  double _ratingValue = Constants.minRating;
  final double _minValue = Constants.minRating;
  final double _maxValue = Constants.maxRating;

  void _loadArguments() {
    final RateScreenArguments? arguments = ModalRoute.of(context)?.settings.arguments as RateScreenArguments?;
    if (arguments == null) return;
    if (arguments.ratingValue == null) return;
    setState(() => _ratingValue = arguments.ratingValue!);
    if (arguments.comment == null) return;
    setState(() => _commentController.text = arguments.comment!);
  }

  bool _isInputValid() {
    return _ratingValue >= 0.1;
  }

  void _updateSliderValue(double value) {
    setState(() => _ratingValue = value);
  }

  Color _getValueColor() {
    const Color greatColor = Color(0xFF20BF6B);
    const Color mediumColor = Color(0xFFF7B731);
    const Color badColor = Color(0xFFEB3B5A);
    final Color defaultColor = Theme.of(context).colorScheme.background;
    if (_ratingValue < 0.5) return Color.lerp(defaultColor, badColor, _ratingValue / 0.5) ?? defaultColor;
    if (_ratingValue < 5.0) return Color.lerp(badColor, mediumColor, _ratingValue / 5.0) ?? badColor;
    if (_ratingValue < 10.0) return Color.lerp(mediumColor, greatColor, (_ratingValue - 5.0) / 5.0) ?? mediumColor;
    return greatColor;
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
    return Scaffold(
      backgroundColor: _getValueColor(),
      appBar: AppBar(
        backgroundColor: _getValueColor(),
        titleSpacing: 0,
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text("item!.name", style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            // "${item!.category.name} (${Provider.of<DataProvider>(context).getGroupFromCategory(item!.category).name})",
            "item!.category.name",
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
              "${_ratingValue.toStringAsFixed(1)} 🔥",
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
}
