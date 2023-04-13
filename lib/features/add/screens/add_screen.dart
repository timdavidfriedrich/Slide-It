import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/screen.dart';

class AddScreen extends StatefulWidget implements Screen {
  static const routeName = "/add";
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();

  @override
  String get displayName => "Hinzufügen";

  @override
  Icon get icon => const Icon(Icons.add);

  @override
  Icon get cupertinoIcon => const Icon(CupertinoIcons.add, size: 20);
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _groupTextController = TextEditingController();
  final TextEditingController _categoryTextController = TextEditingController();

  double _sliderValue = Constants.minRating;
  final double _minValue = Constants.minRating;
  final double _maxValue = Constants.maxRating;

  void _camera() {}

  void _rebuild() {
    setState(() {});
  }

  void _save() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Theme.of(context).platform == TargetPlatform.iOS || Theme.of(context).platform == TargetPlatform.macOS
          ? CupertinoNavigationBar(middle: Text(widget.displayName))
          : AppBar(title: Text(widget.displayName)) as PreferredSizeWidget?,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Constants.largePadding),
        children: [
          AspectRatio(
            aspectRatio: 3 / 2,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
              onPressed: () => _camera(),
              child: const Icon(Icons.camera_alt_outlined, size: Constants.mediumPadding),
            ),
          ),
          const SizedBox(height: Constants.mediumPadding),
          TextField(
            controller: _nameTextController,
            onChanged: (value) => _rebuild(),
            decoration: const InputDecoration(
              labelText: "Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: Constants.normalPadding),
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              return <String>["MIB-Gang", "Familie"];
            },
            fieldViewBuilder: (
              BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted,
            ) {
              return TextField(
                controller: _groupTextController,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: "Gruppe",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (String value) {
                  onFieldSubmitted();
                },
              );
            },
          ),
          const SizedBox(height: Constants.normalPadding),
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              return <String>["Deckenrating", "Mensa-Essen", "Red Bull"];
            },
            fieldViewBuilder: (
              BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted,
            ) {
              return TextField(
                controller: _categoryTextController,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: "Kategorie",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (String value) {
                  onFieldSubmitted();
                },
              );
            },
          ),
          const SizedBox(height: Constants.mediumPadding),
          Text("Deine Bewertung: ${_sliderValue.toStringAsFixed(1)}"),
          const SizedBox(height: Constants.smallPadding),
          Slider.adaptive(
            min: _minValue,
            max: _maxValue,
            value: _sliderValue,
            onChanged: (value) => setState(() => _sliderValue = value),
          ),
          const SizedBox(height: Constants.mediumPadding),
          FilledButton(onPressed: _nameTextController.text.isEmpty ? null : () => _save(), child: const Text("Speichern")),
          const SizedBox(height: Constants.largePadding),
        ],
      ),
    );
  }
}
