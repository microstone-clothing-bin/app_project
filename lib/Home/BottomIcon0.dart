import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'MarkerDetailPage.dart';
import 'package:http/http.dart' as http;
import 'marker_info.dart';
import 'package:geolocator/geolocator.dart';
import 'clothing_bin_bottom_sheet.dart'; // ✅ 새 파일 import

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
  final double _sheetExtent = 0.25;

  @override
  void initState() {
    super.initState();
    _initLocationAndData();

    _positionStreamSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((position) {
          final NLatLng newPos = NLatLng(position.latitude, position.longitude);
          setState(() {
            _currentPosition = newPos;
          });
          if (_mapController != null) {
            final overlay = _mapController!.getLocationOverlay();
            overlay.setPosition(newPos);
            overlay.setIsVisible(true);
          }
        });
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    super.dispose();
  }

  Future<void> _initLocationAndData() async {
    try {
      final pos = await _determinePosition();
      _currentPosition = NLatLng(pos.latitude, pos.longitude);
    } catch (_) {
      _currentPosition = NLatLng(37.5666, 126.979);
    }
    await _loadClothingBins();
    _updateNearbyMarkers();
    if (_mapController != null && _currentPosition != null) {
      _moveToMyLocation();
    }
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 지도
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: _currentPosition ?? NLatLng(37.5666, 126.979),
                zoom: 14,
              ),
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
                _moveToMyLocation();
              }
            },
          ),

          // 내 위치 버튼
          if (showLocationButton)
            Positioned(
              right: 18,
              bottom: (screenHeight * _sheetExtent) + 16,
              child: FloatingActionButton(
                onPressed: _moveToMyLocation,
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.my_location,
                  color: Color.fromARGB(255, 34, 80, 207),
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
                  prefixIcon: const Icon(Icons.search),
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

          // ✅ 바텀시트 분리
          ClothingBinBottomSheet(
            minSheetSize: minSheetSize,
            sheetExtent: _sheetExtent,
            nearbyMarkers: nearbyMarkers,
            searchResults: searchResults,
            currentPosition: _currentPosition,
            mapController: _mapController,
            calculateDistance: _calculateDistance,
          ),
        ],
      ),
    );
  }
}
