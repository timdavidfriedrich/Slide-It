import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

// ! Not in use, yet.
class AppFutureBuilder extends StatelessWidget {
  final Future future;
  final Widget child;
  const AppFutureBuilder({super.key, required this.future, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Icon(PlatformIcons(context).error));
          } else if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else {
            // TODO: Find a way to pass snapshot data
            return child;
          }
        } 
      );
  }
}