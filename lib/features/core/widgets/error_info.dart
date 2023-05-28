import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/constants/constants.dart';

class ErrorInfo extends StatelessWidget {
  final String message;
  const ErrorInfo({super.key, this.message = "Ein Fehler ist aufgetreten."});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(PlatformIcons(context).error, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: Constants.smallPadding),
        Text(message, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ],
    );
  }
}
