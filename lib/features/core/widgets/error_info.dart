import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/constants/constants.dart';

class ErrorInfo extends StatelessWidget {
  final String? message;
  const ErrorInfo({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PlatformIcons(context).error, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: Constants.smallPadding),
          Flexible(
            child: Text(
              message ?? "Es ist ein Fehler aufgetreten.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
