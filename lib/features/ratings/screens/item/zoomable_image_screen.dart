import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:rating/constants/constants.dart';

class ZoomableImageScreen extends StatefulWidget {
  static const String routeName = "/ZoomableImage";
  final Widget image;
  const ZoomableImageScreen({super.key, required this.image});

  @override
  State<ZoomableImageScreen> createState() => _ZoomableImageScreenState();
}

class _ZoomableImageScreenState extends State<ZoomableImageScreen> {
  final double _maxScale = 5;
  final double _boundaryMargin = Constants.mediumPadding;
  final TransformationController _zoomController = TransformationController();

  void _close() {
    context.pop();
  }

  void _resetZoomLevel(details) {
    setState(() => _zoomController.value = Matrix4.identity());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: false,
                boundaryMargin: EdgeInsets.all(_boundaryMargin),
                clipBehavior: Clip.none,
                maxScale: _maxScale,
                transformationController: _zoomController,
                onInteractionEnd: _resetZoomLevel,
                child: widget.image,
              ),
            ),
            Positioned(
              top: Constants.normalPadding,
              right: Constants.normalPadding,
              child: IconButton.filled(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.background,
                    ),
                    foregroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.onBackground,
                    )),
                onPressed: _close,
                icon: Icon(PlatformIcons(context).clear),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
