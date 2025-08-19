import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'marker_info.dart';
import 'FavoriteManager.dart';

class ClothingBinBottomSheet extends StatefulWidget {
  final double minSheetSize;
  final double sheetExtent;
  final List<marker_info> nearbyMarkers;
  final List<marker_info> searchResults;
  final NLatLng? currentPosition;
  final NaverMapController? mapController;
  final double Function(double, double, double, double) calculateDistance;

  const ClothingBinBottomSheet({
    super.key,
    required this.minSheetSize,
    required this.sheetExtent,
    required this.nearbyMarkers,
    required this.searchResults,
    required this.currentPosition,
    required this.mapController,
    required this.calculateDistance,
  });

  @override
  State<ClothingBinBottomSheet> createState() => _ClothingBinBottomSheetState();
}

class _ClothingBinBottomSheetState extends State<ClothingBinBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        return true;
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.25,
        minChildSize: widget.minSheetSize,
        maxChildSize: 0.85,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.currentPosition != null
                              ? "현재 위치: ${widget.currentPosition!.latitude.toStringAsFixed(5)}, ${widget.currentPosition!.longitude.toStringAsFixed(5)}"
                              : "위치 정보 없음",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: const Text(
                    "주변 의류수거함 (500m 이내)",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                if (widget.nearbyMarkers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "주변에 아무것도 없습니다.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...widget.nearbyMarkers.map((bin) {
                    final dist = widget
                        .calculateDistance(
                          widget.currentPosition!.latitude,
                          widget.currentPosition!.longitude,
                          bin.lat,
                          bin.lng,
                        )
                        .toStringAsFixed(0);
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.checkroom,
                          color: Colors.deepPurple,
                        ),
                        title: Text(bin.caption),
                        subtitle: Text('약 ${dist}m'),
                        trailing: IconButton(
                          icon: Icon(
                            FavoriteManager.isFavorite(bin)
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              if (FavoriteManager.isFavorite(bin)) {
                                FavoriteManager.remove(bin);
                              } else {
                                FavoriteManager.add(bin);
                              }
                            });
                          },
                          tooltip: "즐겨찾기 추가/해제",
                        ),
                        onTap: () {
                          widget.mapController?.updateCamera(
                            NCameraUpdate.fromCameraPosition(
                              NCameraPosition(
                                target: NLatLng(bin.lat, bin.lng),
                                zoom: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),

                const Divider(height: 28),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: const Text(
                    "검색 결과",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                if (widget.searchResults.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "검색된 결과가 없습니다.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...widget.searchResults.map((bin) {
                    final dist = widget.currentPosition != null
                        ? widget
                              .calculateDistance(
                                widget.currentPosition!.latitude,
                                widget.currentPosition!.longitude,
                                bin.lat,
                                bin.lng,
                              )
                              .toStringAsFixed(0)
                        : "-";
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.checkroom,
                          color: Colors.deepPurple.shade200,
                        ),
                        title: Text(bin.caption),
                        subtitle: Text('약 ${dist}m'),
                        onTap: () {
                          widget.mapController?.updateCamera(
                            NCameraUpdate.fromCameraPosition(
                              NCameraPosition(
                                target: NLatLng(bin.lat, bin.lng),
                                zoom: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
