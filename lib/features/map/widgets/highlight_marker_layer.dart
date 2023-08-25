import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:rating/features/map/provider/map_provider.dart';
import 'package:rating/features/map/widgets/map_item.dart';
import 'package:rating/features/ratings/models/category.dart';

class HighlightMarkerLayer extends StatelessWidget {
  final Category category;
  final double imageHeight;
  final double imageWidth;
  const HighlightMarkerLayer({
    super.key,
    required this.category,
    this.imageHeight = 80,
    this.imageWidth = 60,
  });

  @override
  Widget build(BuildContext context) {
    MapProvider map = Provider.of<MapProvider>(context);

    return MarkerLayer(
      markers: [
        if (map.selectedItem?.location != null)
          Marker(
            point: map.selectedItem!.location!,
            height: imageHeight * 2,
            width: imageWidth * 2,
            builder: ((context) {
              return MapItem(
                item: map.selectedItem!,
                highlighted: true,
              );
            }),
          ),
      ],
    );
  }
}
