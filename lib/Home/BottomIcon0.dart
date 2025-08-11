import 'dart:async'; // StreamSubscription 사용을 위해 추가
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'MarkerDetailPage.dart';
import 'package:http/http.dart' as http;
import 'marker_info.dart';
import 'package:geolocator/geolocator.dart';

// ==== 서버에서 마커 데이터 불러오기 ====
Future<List<marker_info>> fetchClothingBins() async {
  final response = await http.get(
    Uri.parse('https://marker-url.onrender.com/api/clothing-bins'),
  );
  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((json) => marker_info.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load clothing bins');
  }
}

class BottomIcon0 extends StatefulWidget {
  const BottomIcon0({super.key});
  @override
  State<BottomIcon0> createState() => _BottomIcon0State();
}

class _BottomIcon0State extends State<BottomIcon0> {
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<Position>? _positionStreamSub;

  List<marker_info> clothingBins = [];
  Set<NClusterableMarker> clusterMarkers = {};
  List<marker_info> nearbyMarkers = [];
  List<marker_info> searchResults = [];
  NaverMapController? _mapController;

  bool showLocationButton = true;
  NLatLng? _currentPosition;
  final double minSheetSize = 0.12;
  double _sheetExtent = 0.25; // NotificationListener로 추적한 바텀시트 비율

  @override
  void initState() {
    super.initState();
    _initLocationAndData();

    // 위치 변경 스트림 시작
    _positionStreamSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5, // 5m 이상 이동 시만 콜백
          ),
        ).listen((position) {
          final NLatLng newPos = NLatLng(position.latitude, position.longitude);
          setState(() {
            _currentPosition = newPos;
          });
          // 지도 오버레이 갱신
          if (_mapController != null) {
            final overlay = _mapController!.getLocationOverlay();
            overlay.setPosition(newPos);
            overlay.setIsVisible(true);
          }
        });
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel(); // 구독 해제
    super.dispose();
  }

  // 현재 위치 권한 및 데이터 로드
  Future<void> _initLocationAndData() async {
    try {
      final pos = await _determinePosition();
      _currentPosition = NLatLng(pos.latitude, pos.longitude);
    } catch (_) {
      _currentPosition = NLatLng(37.5666, 126.979);
    }
    await _loadClothingBins();
    _updateNearbyMarkers();
  }

  Future<Position> _determinePosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) throw ('위치 서비스 꺼짐');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw ('위치 권한 거부됨');
    }
    if (permission == LocationPermission.deniedForever) throw ('위치 권한 영구 거부됨');
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _loadClothingBins() async {
    try {
      final bins = await fetchClothingBins();
      clothingBins = bins;
      clusterMarkers = bins.map((bin) {
        return NClusterableMarker(
          id: bin.id,
          position: NLatLng(bin.lat, bin.lng),
          caption: NOverlayCaption(text: bin.caption),
        )..setOnTapListener((overlay) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MarkerDetailPage(binInfo: bin),
            ),
          );
        });
      }).toSet();
      if (_mapController != null) {
        await _mapController!.clearOverlays();
        await _mapController!.addOverlayAll(clusterMarkers);
      }
      setState(() {});
    } catch (e) {
      setState(() {});
    }
  }

  void _updateNearbyMarkers() {
    if (_currentPosition == null) return;
    final lat = _currentPosition!.latitude;
    final lng = _currentPosition!.longitude;
    List<marker_info> filtered = clothingBins.where((bin) {
      return _calculateDistance(lat, lng, bin.lat, bin.lng) <= 500;
    }).toList();
    filtered.sort(
      (a, b) => _calculateDistance(
        lat,
        lng,
        a.lat,
        a.lng,
      ).compareTo(_calculateDistance(lat, lng, b.lat, b.lng)),
    );
    nearbyMarkers = filtered;
    setState(() {});
  }

  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const R = 6371000;
    double dLat = _deg2rad(lat2 - lat1);
    double dLng = _deg2rad(lng2 - lng1);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  Future<void> _addMarkers() async {
    if (_mapController != null) {
      await _mapController!.clearOverlays();
      await _mapController!.addOverlayAll(clusterMarkers);
    }
  }

  void _searchMarkers(String keyword) {
    String kw = keyword.toLowerCase();
    searchResults = clothingBins.where((bin) {
      return bin.caption.toLowerCase().contains(kw) ||
          ((bin.address ?? '').toLowerCase().contains(kw));
    }).toList();

    if (_currentPosition != null) {
      searchResults.sort((a, b) {
        final distA = _calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          a.lat,
          a.lng,
        );
        final distB = _calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          b.lat,
          b.lng,
        );
        return distA.compareTo(distB);
      });
    }
    setState(() {});
  }

  void _moveToMyLocation() {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.updateCamera(
        NCameraUpdate.fromCameraPosition(
          NCameraPosition(target: _currentPosition!, zoom: 15),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _currentPosition ?? NLatLng(37.5666, 126.979);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 지도
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(target: center, zoom: 14),
              locationButtonEnable: false,
            ),
            clusterOptions: NaverMapClusteringOptions(
              mergeStrategy: NClusterMergeStrategy(),
              clusterMarkerBuilder: (info, marker) =>
                  marker.setCaption(NOverlayCaption(text: '${info.size}개')),
            ),
            onMapReady: (controller) async {
              _mapController = controller;
              await _addMarkers();
              if (_currentPosition != null) {
                final overlay = _mapController!.getLocationOverlay();
                overlay.setPosition(_currentPosition!);
                overlay.setIsVisible(true);
                _mapController!.updateCamera(
                  NCameraUpdate.fromCameraPosition(
                    NCameraPosition(target: _currentPosition!, zoom: 14),
                  ),
                );
              }
            },
          ),

          // 내 위치 버튼 - 바텀시트 위에서 같이 움직이게
          if (showLocationButton)
            Positioned(
              right: 18,
              bottom: (screenHeight * _sheetExtent) + 16,
              child: FloatingActionButton(
                onPressed: _moveToMyLocation,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.my_location,
                  color: const Color.fromARGB(255, 34, 80, 207),
                ),
              ),
            ),

          // 검색창
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '장소 또는 주소 검색',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                ),
                onSubmitted: _searchMarkers,
              ),
            ),
          ),

          // 바텀시트 + NotificationListener로 extent 추적
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              setState(() {
                _sheetExtent = notification.extent;
              });
              return true;
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.25,
              minChildSize: minSheetSize,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 8),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
                    children: [
                      // 현재 위치
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.my_location, color: Colors.deepPurple),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _currentPosition != null
                                    ? "현재 위치: ${_currentPosition!.latitude.toStringAsFixed(5)}, ${_currentPosition!.longitude.toStringAsFixed(5)}"
                                    : "위치 정보 없음",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(),

                      // 주변 의류수거함
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: Text(
                          "주변 의류수거함 (500m 이내)",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (nearbyMarkers.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "주변에 아무것도 없습니다.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...nearbyMarkers.map((bin) {
                          final dist = _calculateDistance(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                            bin.lat,
                            bin.lng,
                          ).toStringAsFixed(0);
                          return Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.checkroom,
                                color: Colors.deepPurple,
                              ),
                              title: Text(bin.caption),
                              subtitle: Text('약 ${dist}m'),
                              onTap: () {
                                _mapController?.updateCamera(
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

                      Divider(height: 28),

                      // 검색 결과
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: Text(
                          "검색 결과",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (searchResults.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "검색된 결과가 없습니다.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...searchResults.map((bin) {
                          final dist = _currentPosition != null
                              ? _calculateDistance(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                  bin.lat,
                                  bin.lng,
                                ).toStringAsFixed(0)
                              : "-";
                          return Card(
                            margin: EdgeInsets.symmetric(
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
                                _mapController?.updateCamera(
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
          ),
        ],
      ),
    );
  }
}
