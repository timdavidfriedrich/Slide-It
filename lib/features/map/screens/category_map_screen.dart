import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/map/provider/map_provider.dart';
import 'package:rating/features/map/widgets/highlight_marker_layer.dart';
import 'package:rating/features/map/widgets/item_sheet.dart';
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
    const int spiderfyCircleRadius = 48;
    const EdgeInsets fitBoundsPadding = EdgeInsets.all(50);
    const int maxClusterRadius = 45;
    const Size clusterSize = Size(40, 40);

    final MapController mapContronller = MapController();
    MapProvider map = Provider.of<MapProvider>(context);

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

    void moveToItem(Item item) {
      mapContronller.move(
        LatLng(item.location!.latitude - 0.0005, item.location!.longitude),
        maxZoomLevel,
      );
    }

    void openItemSheet(BuildContext context) {
      showBottomSheet(
        context: context,
        builder: (context) => ItemSheet(
          onHorizontalSwipe: (details) {
            if (details.primaryVelocity?.isNegative ?? false) {
              map.selectNextItemWithLocation(itemsWithLocation.reversed.toList());
            } else {
              map.selectNextItemWithLocation(itemsWithLocation);
            }
            if (map.selectedItem?.location == null) return;
            moveToItem(map.selectedItem!);
          },
          onClose: () {
            map.selectedItem = null;
            context.pop();
            mapContronller.move(medianLatLng(), zoomLevel);
          },
        ),
      );
      if (map.selectedItem?.location == null) return;
      moveToItem(map.selectedItem!);
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(category.name),
        ),
        body: Stack(
          children: [
            Builder(builder: (context) {
              return FlutterMap(
                mapController: mapContronller,
                options: MapOptions(
                  center: itemToHighlight?.location ?? medianLatLng(),
                  zoom: itemsWithLocation.isNotEmpty ? zoomLevel : minZoomLevel,
                  minZoom: minZoomLevel,
                  maxZoom: itemsWithLocation.isNotEmpty ? maxZoomLevel : minZoomLevel,
                  interactiveFlags: ~InteractiveFlag.rotate & (itemsWithLocation.isEmpty ? ~InteractiveFlag.all : InteractiveFlag.all),
                  onMapReady: () {
                    if (itemToHighlight != null) {
                      map.selectedItem = itemToHighlight;
                      moveToItem(map.selectedItem!);
                      openItemSheet(context);
                      return;
                    }
                    mapContronller.centerZoomFitBounds(
                      LatLngBounds(mapContronller.bounds!.northWest, mapContronller.bounds!.southEast),
                    );
                  },
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
                      spiderfyCluster: map.selectedItem == null,
                      spiderfyCircleRadius: spiderfyCircleRadius,
                      fitBoundsOptions: const FitBoundsOptions(
                        padding: fitBoundsPadding,
                        maxZoom: maxZoomLevel,
                      ),
                      markers: List<Marker>.generate(itemsWithLocation.length, (index) {
                        return Marker(
                          point: itemsWithLocation[index].location!,
                          height: imageHeight,
                          width: imageWidth,
                          builder: (context) {
                            return MapItem(
                              item: itemsWithLocation[index],
                              onTap: () {
                                map.selectedItem = itemsWithLocation[index];
                                openItemSheet(context);
                              },
                            );
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
                  HighlightMarkerLayer(category: category),
                ],
              );
            }),
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
                        "Kein Objekt in\ndieser Kategorie enthält\nStandort-Angaben.",
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
