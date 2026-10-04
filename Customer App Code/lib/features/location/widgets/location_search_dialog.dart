import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/prediction_model.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class LocationSearchDialog extends StatefulWidget {
  final GoogleMapController? mapController;
  final String? pickedLocation;
  final Widget? child;
  final Function(Position)? callBack;
  final bool? fromAddress;
  final bool enabled;
  const LocationSearchDialog({
    super.key,
    required this.mapController,
    this.pickedLocation,
    this.child,
    this.callBack,
    this.fromAddress = false,
    this.enabled = true,
  });

  @override
  State<LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<LocationSearchDialog> {
  final SearchController controller = SearchController();
  String? _searchingWithQuery;
  late Iterable<Widget> _lastOptions = <Widget>[];
  List<PredictionModel> _predictionList = [];
  List<String> _predictList = <String>[];
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();

    controller.text = widget.pickedLocation ?? '';
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.isAttached && !controller.isOpen) {
      controller.text = widget.pickedLocation ?? '';
    }
    return GetBuilder<LocationController>(
      builder: (lController) {
        return SearchAnchor(
          searchController: controller,
          viewSurfaceTintColor: Theme.of(context).cardColor,
          isFullScreen: false,
          viewLeading: IconButton(
            onPressed: () => controller.closeView(''),
            icon: const BackButtonIcon(),
          ),
          viewTrailing: [
            IconButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  controller.text = '';
                } else {
                  controller.closeView('');
                }
              },
              icon: const Icon(Icons.clear),
            ),
          ],
          viewConstraints: const BoxConstraints(minHeight: 100, maxHeight: 300),

          builder: (BuildContext context, SearchController controller) {
            final Widget anchor =
                widget.child ??
                Container(
                  height: 50,
                  width: 500,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 25,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(
                        child: Text(
                          controller.text.isNotEmpty
                              ? controller.text
                              : 'search_location'.tr,
                          style: robotoRegular.copyWith(
                            color: controller.text.isEmpty
                                ? Theme.of(context).disabledColor
                                : Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      Icon(
                        Icons.search,
                        color: Theme.of(context).disabledColor,
                      ),
                    ],
                  ),
                );
            return Semantics(
              button: true,
              enabled: widget.enabled,
              label: 'search_location'.tr,
              child: InkWell(
                onTap: widget.enabled ? controller.openView : null,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                child: anchor,
              ),
            );
          },
          suggestionsBuilder:
              (BuildContext context, SearchController controller) async {
                _searchingWithQuery = controller.text;
                final List<String> options = (await _search(
                  _searchingWithQuery!,
                  lController,
                )).toList();
                if (_searchingWithQuery != controller.text) {
                  return _lastOptions;
                }

                if (options.isEmpty) {
                  _lastOptions = <Widget>[
                    ListTile(
                      enabled: false,
                      leading: const Icon(Icons.location_off_outlined),
                      title: Text('no_address_found'.tr),
                    ),
                  ];
                  return _lastOptions;
                }

                _lastOptions = List<ListTile>.generate(options.length, (
                  int index,
                ) {
                  final String location = options[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(location),
                    onTap: () async {
                      final int selectedIndex = _predictList.indexOf(location);
                      if (selectedIndex < 0 ||
                          selectedIndex >= _predictionList.length) {
                        return;
                      }
                      final PredictionModel suggestion =
                          _predictionList[selectedIndex];
                      if (suggestion.placeId == null) return;
                      final Position position = await lController.setLocation(
                        suggestion.placeId!,
                        suggestion.description,
                        widget.mapController,
                      );
                      if (widget.fromAddress == true &&
                          widget.callBack != null) {
                        widget.callBack!(position);
                      }
                      controller.closeView(location);
                    },
                  );
                });

                return _lastOptions;
              },
        );
      },
    );
  }

  Future<Iterable<String>> _search(
    String query,
    LocationController locationController,
  ) async {
    final String trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      _predictionList = [];
      _predictList = [];
      return const Iterable<String>.empty();
    }
    _predictionList = (await locationController.searchLocation(trimmedQuery))
        .where(
          (prediction) =>
              prediction.description?.isNotEmpty == true &&
              prediction.placeId?.isNotEmpty == true,
        )
        .toList();
    _predictList = _predictionList
        .map((prediction) => prediction.description!)
        .toList();
    return _predictList;
  }
}
