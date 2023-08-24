import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:latlong2/latlong.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/map/widgets/map_item.dart';
import 'package:rating/features/ratings/models/category.dart';
import 'package:rating/features/ratings/models/item.dart';
import 'package:url_launcher/url_launcher.dart';

class CategoryMapScreen extends StatelessWidget {
  static const String routeName = "/CategoryMap";
  final Category category;
  final Item? itemToHighlight;
  const CategoryMapScreen({super.key, required this.category, this.itemToHighlight});

  @override
  Widget build(BuildContext context) {
    const double zoomLevel = 12;
    const double minZoomLevel = 2;
    const double maxZoomLevel = 18;
    const double imageHeight = 80;
    const double imageWidth = 60;
    const EdgeInsets fitBoundsPadding = EdgeInsets.all(50);
    const int maxClusterRadius = 45;
    const Size clusterSize = Size(40, 40);
    final MapController mapContronller = MapController();

    final List<Item> itemsWithLocation = category.items.where((item) {
      return item.location != null;
    }).toList();

    LatLng medianLatLng() {
      if (itemsWithLocation.isEmpty) return LatLng(0, 0);
      final double medianLatitude = itemsWithLocation.map((item) {
        return item.location!.latitude;
      }).elementAt(itemsWithLocation.length ~/ 2);
      final double medianLongitude = itemsWithLocation.map((item) {
        return item.location!.longitude;
      }).elementAt(itemsWithLocation.length ~/ 2);
      return LatLng(medianLatitude, medianLongitude);
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(category.name),
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: mapContronller,
              options: MapOptions(
                center: itemToHighlight?.location ?? medianLatLng(),
                zoom: itemsWithLocation.isNotEmpty ? zoomLevel : minZoomLevel,
                minZoom: minZoomLevel,
                maxZoom: itemsWithLocation.isNotEmpty ? maxZoomLevel : minZoomLevel,
                interactiveFlags: ~InteractiveFlag.rotate & (itemsWithLocation.isEmpty ? ~InteractiveFlag.all : InteractiveFlag.all),
                onMapReady: () => mapContronller.centerZoomFitBounds(
                  LatLngBounds(mapContronller.bounds!.northWest, mapContronller.bounds!.southEast),
                ),
              ),
              nonRotatedChildren: [
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                    ),
                  ],
                ),
              ],
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: maxClusterRadius,
                    size: clusterSize,
                    anchor: AnchorPos.align(AnchorAlign.center),
                    fitBoundsOptions: const FitBoundsOptions(
                      padding: fitBoundsPadding,
                      maxZoom: maxZoomLevel,
                    ),
                    markers: List.generate(itemsWithLocation.length, (index) {
                      return Marker(
                        point: itemsWithLocation[index].location!,
                        height: imageHeight,
                        width: imageWidth,
                        builder: (context) {
                          if (itemsWithLocation[index].id == itemToHighlight?.id) {
                            return Container();
                          }
                          return MapItem(item: itemsWithLocation[index]);
                        },
                      );
                    }),
                    builder: (context, markers) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "${markers.length}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (itemToHighlight != null && itemToHighlight!.location != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: itemToHighlight!.location!,
                        height: imageHeight,
                        width: imageWidth,
                        builder: ((context) {
                          return MapItem(item: itemToHighlight!, highlighted: true);
                        }),
                      ),
                    ],
                  )
              ],
            ),
            if (itemsWithLocation.isEmpty)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(Constants.normalPadding),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PlatformIcons(context).error,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      const SizedBox(width: Constants.normalPadding),
                      Text(
                        "Keines der Objekte in\ndieser Kategorie enthält\nStandort-Angaben.",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
